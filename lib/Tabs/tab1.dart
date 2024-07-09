import 'package:flutter/material.dart';
import 'package:madcamp_week2/component/speech_recognition.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위한 패키지 추가
import 'package:madcamp_week2/component/datepicker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madcamp_week2/api/google_signin_api.dart';
import 'package:madcamp_week2/api/user_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:madcamp_week2/component/todo_provider.dart';

class FirstTab extends StatefulWidget {
  final GoogleSignInAccount user;

  FirstTab({required this.user});

  @override
  _FirstTabState createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _todoList = [];
  final SpeechRecognitionService _speechRecognitionService =
      SpeechRecognitionService();


  @override
  void initState() {
    super.initState();
    _loadTodoList();  // 앱 실행 시 저장된 투두리스트를 로드
    _fetchTodosForSelectedDay(_selectedDate);
  }

  //방법1. shared prefernece로 불러오기
  Future<void> _loadTodoList() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    String? todoListString =
        prefs.getString('todoList'); // 저장된 투두리스트 데이터를 JSON 형식으로 가져오기
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
      List<Map<String, dynamic>> todos =
          await getTodosByDate(widget.user.displayName!, day);
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
    SharedPreferences prefs =
        await SharedPreferences.getInstance(); // SharedPreferences 인스턴스 가져오기
    String todoListString = json.encode(_todoList);
    await prefs.setString(
        'todoList', todoListString); // 변환된 JSON 데이터를 SharedPreferences에 저장
  }

  // 선택된 날짜를 변경하는 메서드
  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate; // _selectedDate를 새로운 날짜로 변경
    });
    _fetchTodosForSelectedDay(_selectedDate);
  }

  Future<void> _recordAndRecognize(String type) async {
    String? filePath = await _speechRecognitionService.record();
    if (filePath != null) {
      String? recognizedText =
          await _speechRecognitionService.recognizeSpeech(filePath);
      if (recognizedText != null) {
        final newTodo = {
          'type': type,
          'content': recognizedText,
          'complete': false
        };
        setState(() {
          _todoList.add({'type': type, 'content': recognizedText, 'complete': false //여기에 post 호출
        });
        });
        await addTodoToDB(
            widget.user.displayName ?? '', _selectedDate, newTodo);
        Provider.of<TodoProvider>(context, listen: false).addTodoItem(
            _selectedDate,
            {'type': type, 'content': recognizedText, 'complete': false});
        _saveTodoList();
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF023047),
        title: const Text('To-Do list',
            style: TextStyle(fontSize: 25, color: Colors.white)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showCupertinoDatePicker(
                context: context,
                onDateChanged: _onDateChanged,
                initialDateTime: _selectedDate,
              );
            },
            child: Text(
              'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
              style:
                  TextStyle(fontSize: 24, decoration: TextDecoration.underline),
            ),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _recordAndRecognize('Work'),
                child: Text('Work'),
              ),
              ElevatedButton(
                onPressed: () => _recordAndRecognize('Life'),
                child: Text('Life'),
              ),
            ],
          ),
          // ElevatedButton(
          //   onPressed: () => _fetchTodosForSelectedDay(_selectedDate),
          //   child: Text('DB todo 불러오기'),
          // ),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final item = _todoList[index];
                return GestureDetector(
                  onLongPress: () => _deleteItem(index),
                  child: ListTile(
                    leading: Checkbox(
                      value: item['complete'],
                      onChanged: (value) => _toggleCheck(index),
                    ),
                    title: Text(
                      item['content'],
                      style: TextStyle(
                        decoration: item['complete']
                            ? TextDecoration.lineThrough
                            : null,
                        color:
                            item['type'] == 'Work' ? Colors.blue : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
