import 'package:flutter/material.dart';
import "package:madcamp_week2/component/speech_recognition.dart";
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

class FirstTab extends StatefulWidget {
  final GoogleSignInAccount user;

  FirstTab({required this.user});

  @override
  _FirstTabState createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _todoList = [];
  final SpeechRecognitionService _speechRecognitionService = SpeechRecognitionService();
  bool _isMySelected = true;
  bool _isRecording = false;
  String? _currentRecordingPath;
  String? _currentType;

  @override
  void initState() {
    super.initState();
    _loadTodoList();
    _fetchTodosForSelectedDay(_selectedDate);
  }

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

  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String todoListString = json.encode(_todoList);
    await prefs.setString('todoList', todoListString);
  }

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
  }

  void _toggleCheck(int index) {
    setState(() {
      _todoList[index]['complete'] = !_todoList[index]['complete'];
    });

    _saveTodoList();
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
        title: const Text('To-Do-Listener',
            style: TextStyle(fontSize: 25, color: Colors.green)),
        actions: [
          ToggleButtons(
            children: [
              Text(
                'My',
                style: TextStyle(color: _isMySelected ? Colors.pink : Colors.white),
              ),
              Text(
                'Mates',
                style: TextStyle(color: !_isMySelected ? Colors.pink : Colors.white),
              ),
            ],
            isSelected: [_isMySelected, !_isMySelected],
            onPressed: (index) {
              setState(() {
                _isMySelected = index == 0;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: Color(0xFF004FA0),
        child: Column(
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
                '${DateFormat('yyyy-MM-dd').format(_selectedDate)}',
                style: TextStyle(fontSize: 24, decoration: TextDecoration.underline, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _toggleRecording('Work'),
                  child: Text(_isRecording && _currentType == 'Work' ? 'Done' : 'Work'),
                ),
                ElevatedButton(
                  onPressed: () => _toggleRecording('Life'),
                  child: Text(_isRecording && _currentType == 'Life' ? 'Done' : 'Life'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _todoList.length,
                itemBuilder: (context, index) {
                  final item = _todoList[index];
                  return GestureDetector(
                    onLongPress: () => _deleteItem(index),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                      padding: EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: item['complete'],
                          onChanged: (value) => _toggleCheck(index),
                        ),
                        title: Text(
                          item['content'],
                          style: TextStyle(
                            decoration: item['complete'] ? TextDecoration.lineThrough : null,
                            color: item['type'] == 'Work' ? Color(0xFFFFC1C1) : Color(0xFFB0E0E6),
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
