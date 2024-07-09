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
  final SpeechRecognitionService _speechRecognitionService = SpeechRecognitionService();

  @override
  void initState() {
    super.initState();
    _loadTodoList();  // 앱 실행 시 저장된 투두리스트를 로드
  }

  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // SharedPreferences 인스턴스 가져오기
    String? todoListString = prefs.getString('todoList');  // 저장된 투두리스트 데이터를 JSON 형식으로 가져오기
    if (todoListString != null) {
      Map<String, dynamic> todoMap = json.decode(todoListString);
      todoMap.forEach((key, value) {
        DateTime date = DateTime.parse(key);
        List<Map<String, dynamic>> todos = List<Map<String, dynamic>>.from(value);
        Provider.of<TodoProvider>(context, listen: false).setTodosForDate(date, todos);
      });
    }
  }

  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // SharedPreferences 인스턴스 가져오기
    var provider = Provider.of<TodoProvider>(context, listen: false);
    Map<String, dynamic> todoMap = provider.todos.map((key, value) => MapEntry(key.toIso8601String(), value));
    String todoListString = json.encode(todoMap);  // _todoList 데이터를 JSON 형식으로 변환
    await prefs.setString('todoList', todoListString);  // 변환된 JSON 데이터를 SharedPreferences에 저장
  }

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;  // _selectedDate를 새로운 날짜로 변경
    });
  }

  Future<void> _recordAndRecognize(String type) async {
    String? filePath = await _speechRecognitionService.record();
    if (filePath != null) {
      String? recognizedText = await _speechRecognitionService.recognizeSpeech(filePath);
      if (recognizedText != null) {
        final newTodo = {'type': type, 'text': recognizedText, 'isChecked': false};
        setState(() {
          Provider.of<TodoProvider>(context, listen: false).addTodoItem(_selectedDate, newTodo);
          _saveTodoList();
        });
        await addTodoToDB(widget.user.displayName ?? '', _selectedDate, newTodo);
      }
    }
  }

  void _toggleCheck(DateTime date, int index) {
    setState(() {
      Provider.of<TodoProvider>(context, listen: false).toggleCheck(date, index);
      _saveTodoList();
    });
  }

  void _deleteItem(DateTime date, int index) async {
    final item = Provider.of<TodoProvider>(context, listen: false).getTodosForDate(date)[index];
    await deleteTodoFromDB(widget.user.displayName ?? '', date, item['text']);
    setState(() {
      Provider.of<TodoProvider>(context, listen: false).removeTodoItem(date, index);
      _saveTodoList();
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<TodoProvider>(context);
    List<Map<String, dynamic>> filteredTodoList = provider.getTodosForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF023047),
        title: const Text('To-Do list', style: TextStyle(fontSize: 25, color: Colors.white)),
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
              style: TextStyle(fontSize: 24, decoration: TextDecoration.underline),
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
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: filteredTodoList.length,
              itemBuilder: (context, index) {
                final item = filteredTodoList[index];
                return GestureDetector(
                  onLongPress: () => _deleteItem(_selectedDate, index), // 여기에서 delete 호출
                  child: ListTile(
                    leading: Checkbox(
                      value: item['isChecked'],
                      onChanged: (value) => _toggleCheck(_selectedDate, index),
                    ),
                    title: Text(
                      item['text'],
                      style: TextStyle(
                        decoration: item['isChecked'] ? TextDecoration.lineThrough : null,
                        color: item['type'] == 'Work' ? Colors.blue : Colors.green,
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
