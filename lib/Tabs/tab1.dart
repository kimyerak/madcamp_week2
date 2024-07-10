import 'package:flutter/material.dart';
import 'package:madcamp_week2/component/speech_recognition.dart';
import 'package:intl/intl.dart';
import 'package:madcamp_week2/component/datepicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madcamp_week2/api/google_signin_api.dart';
import 'package:madcamp_week2/api/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:madcamp_week2/component/todo_provider.dart';
import 'package:flutter/cupertino.dart';

class FirstTab extends StatefulWidget {//
  final GoogleSignInAccount user;

  FirstTab({required this.user});

  @override
  _FirstTabState createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> with SingleTickerProviderStateMixin {

  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _todoList = [];
  final SpeechRecognitionService _speechRecognitionService = SpeechRecognitionService();
  bool _isMySelected = true;
  bool _isRecording = false;
  String? _currentRecordingPath;
  String? _currentType;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _loadTodoList();
    _fetchTodosForSelectedDay(_selectedDate);

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();//애니메이션 허용??
    super.dispose();
  }

  //방법1. shared prefernece로 불러오기
  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      Map<String, dynamic> decodedMap = json.decode(todoListString);
      setState(() {
        _todoList = List<Map<String, dynamic>>.from(json.decode(todoListString));
      });
    }
  }

  //방법2. DB에서 불러오기
  void _fetchTodosForSelectedDay(DateTime day) async {
    try {
      print("api함수 호출하는중");
      List<Map<String, dynamic>> todos = await getTodosByDate(widget.user.displayName!, day);
      print("Todos fetched: $todos");
      setState(() {
        _todoList = todos;
      });
    } catch (e) {
      print('Failed to load todos: $e');
    }
  }

  // 투두리스트를 SharedPreferences에 저장하는 메서드
  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todoListString = json.encode(_todoList);
    await prefs.setString('todoList', todoListString);
  }

  // 선택된 날짜를 변경하는 메서드
  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _fetchTodosForSelectedDay(_selectedDate);
  }

  Future<void> _toggleRecording(String type) async {
    if (_isRecording && _currentType == type) {
      await _stopRecording();
    } else {
      await _startRecording(type);
    }
  }

  Future<void> _startRecording(String type) async {
    _currentRecordingPath = await _speechRecognitionService.startRecording();
    setState(() {
      _isRecording = true;
      _currentType = type;
    });
    _animationController.repeat(reverse: true);//애니메이션 시작시점
  }

  Future<void> _stopRecording() async {
    await _speechRecognitionService.stopRecording();
    if (_currentRecordingPath != null) {
      String? recognizedText = await _speechRecognitionService.recognizeSpeech(_currentRecordingPath!);
      if (recognizedText != null) {
        final newTodo = {
          'type': _currentType,
          'content': recognizedText,
          'complete': false
        };
        setState(() {
          _todoList.add(newTodo);
        });
        await addTodoToDB(widget.user.displayName ?? '', _selectedDate, newTodo);
        Provider.of<TodoProvider>(context, listen: false).addTodoItem(_selectedDate, newTodo);
        _saveTodoList();
      }
    }
    setState(() {
      _isRecording = false;
      _currentType = null;
    });
    _animationController.stop();//애니메이션 종료시점 설정
  }

  void _toggleCheck(int index) async {
    setState(() {
      _todoList[index]['complete'] = !_todoList[index]['complete'];
    });
    await _updateTodoStatus(_todoList[index]);
    _saveTodoList();
  }

  Future<void> _updateTodoStatus(Map<String, dynamic> todo) async {
    print("update투두 함수가 호출됨");
    try {
      await updateTodoInDB(widget.user.displayName ?? '', _selectedDate, todo);
    } catch (e) {
      print('Failed to update todo: $e');
    }
  }

  void _deleteItem(int index) async {
    final item = _todoList[index];
    await deleteTodoFromDB(widget.user.displayName ?? '', _selectedDate, item['content']);
    setState(() {
      _todoList.removeAt(index);
    });
    _saveTodoList();
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _selectedDate,
            onDateTimeChanged: (DateTime newDate) {
              _onDateChanged(newDate);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004FA0),
        title: const Text('To-Do-Listener',
            style: TextStyle(fontSize: 25, color: Colors.white)),


      ),
      body: Container(
        color: Color(0xFF004FA0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _showDatePicker,
              child: Text(
                '${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                style: TextStyle(fontSize: 24, color: Colors.white), // 밑줄 제거
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _toggleRecording('Work'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFFFFD9D9)),
                  ),
                  child: Text(_isRecording && _currentType == 'Work' ? 'Done' : 'ADD Work'),//타입오류 제발주의...
                ),
                ElevatedButton(
                  onPressed: () => _toggleRecording('Life'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Color(0xFFAEDFF7)),
                  ),
                  child: Text(_isRecording && _currentType == 'Life' ? 'Done' : 'ADD Life'),//여기도
                ),
              ],
            ),
            SizedBox(height: 20),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1 + _animationController.value * 0.1,
                  child: child,
                );
              },
              child: Image.asset(
                'assets/image/record.png',
                width: 100, // 이미지의 가로 길이
                height: 100, // 이미지의 세로 길이
                fit: BoxFit.contain, // 이미지가 영역을 넘어가지 않도록 조정
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  final item = _todoList[index];
                  return GestureDetector(
                    onLongPress: () => _deleteItem(index),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                        color: Color(0x33FFFFFF), // 푸른색 배경,
                        borderRadius: BorderRadius.circular(12),
                        // border: Border.all(color: Colors.white), // 테두리를 흰색으로 설정
                      ),
                      child: ListTile(
                        leading: Theme(
                          data: ThemeData(
                            unselectedWidgetColor: Colors.white, // 체크박스의 기본 색상을 흰색으로 설정
                          ),
                          child: Checkbox(
                            value: item['complete'],
                            onChanged: (value) => _toggleCheck(index),
                            activeColor: Colors.white, // 선택된 상태의 체크박스 색상
                            checkColor: Colors.black, // 체크박스 내부의 체크표시 색상
                            side: BorderSide(color: Colors.white), // 체크박스 테두리 색상
                          ),
                        ),
                        title: Text(
                          item['content'],
                          style: TextStyle(
                            decoration: item['complete'] ? TextDecoration.lineThrough : null,
                            decorationThickness: item['complete'] ? 4.0 : null, // 밑줄 두께 설정
                            decorationColor: item['complete'] ? Colors.white : null, // 밑줄 색상 설정
                            color: item['type'] == 'Work' ? Color(0xFFFFD9D9) : Color(0xFFAEDFF7),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
