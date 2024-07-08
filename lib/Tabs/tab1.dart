import 'dart:convert';  // JSON 인코딩 및 디코딩을 위해 import
import 'package:flutter/material.dart';
import 'package:madcamp_week2_youngminyerak0/component/speech_recognition.dart';  // 음성 인식 기능을 위한 import
import 'package:intl/intl.dart';  // 날짜 형식을 위한 패키지 import
import 'package:madcamp_week2_youngminyerak0/component/datepicker.dart';  // DatePicker 기능을 위한 import
import 'package:shared_preferences/shared_preferences.dart';  // SharedPreferences 패키지 import
import 'package:provider/provider.dart';  // Provider 패키지 import
import 'package:madcamp_week2_youngminyerak0/component/todo_provider.dart';  // TodoProvider 파일 import

class FirstTab extends StatefulWidget {
  @override
  _FirstTabState createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> {
  DateTime _selectedDate = DateTime.now();  // 선택된 날짜를 저장
  List<Map<String, dynamic>> _todoList = [];  // 투두리스트를 저장
  final SpeechRecognitionService _speechRecognitionService = SpeechRecognitionService();  // 음성 인식 서비스 초기화

  @override
  void initState() {
    super.initState();
    _loadTodoList();  // 앱 실행 시 저장된 투두리스트를 로드
  }

  // SharedPreferences에서 투두리스트를 불러오는 메서드
  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // SharedPreferences 인스턴스 가져오기
    String? todoListString = prefs.getString('todoList');  // 저장된 투두리스트 데이터를 JSON 형식으로 가져오기
    if (todoListString != null) {
      setState(() {
        _todoList = List<Map<String, dynamic>>.from(json.decode(todoListString));  // JSON 데이터를 Map 리스트로 변환하여 _todoList에 저장
      });
    }
  }

  // 투두리스트를 SharedPreferences에 저장하는 메서드
  Future<void> _saveTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();  // SharedPreferences 인스턴스 가져오기
    String todoListString = json.encode(_todoList);  // _todoList 데이터를 JSON 형식으로 변환
    await prefs.setString('todoList', todoListString);  // 변환된 JSON 데이터를 SharedPreferences에 저장
  }

  // 선택된 날짜를 변경하는 메서드
  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;  // _selectedDate를 새로운 날짜로 변경
    });
  }

  // 음성 인식을 통해 투두리스트를 생성하는 메서드
  Future<void> _recordAndRecognize(String type) async {
    String? filePath = await _speechRecognitionService.record();  // 음성 녹음을 시작하고 파일 경로를 반환
    if (filePath != null) {
      String? recognizedText = await _speechRecognitionService.recognizeSpeech(filePath);  // 음성 파일을 텍스트로 변환
      if (recognizedText != null) {
        setState(() {
          _todoList.add({'type': type, 'text': recognizedText, 'isChecked': false});  // 변환된 텍스트를 투두리스트에 추가
        });
        await _saveTodoList();  // 변경된 투두리스트를 저장
        Provider.of<TodoProvider>(context, listen: false).addTodoItem(_selectedDate, {'type': type, 'text': recognizedText, 'isChecked': false});  // Provider를 통해 다른 탭에 변경사항 반영
      }
    }
  }

  // 투두리스트 항목의 체크 상태를 토글하는 메서드
  void _toggleCheck(int index) {
    setState(() {
      _todoList[index]['isChecked'] = !_todoList[index]['isChecked'];  // 체크 상태를 반전
    });
    _saveTodoList();  // 변경된 투두리스트를 저장
  }

  // 투두리스트 항목을 삭제하는 메서드
  void _deleteItem(int index) {
    setState(() {
      _todoList.removeAt(index);  // 해당 인덱스의 항목을 삭제
    });
    _saveTodoList();  // 변경된 투두리스트를 저장
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}',  // 선택된 날짜를 텍스트로 표시
            style: TextStyle(fontSize: 24, decoration: TextDecoration.underline),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => _recordAndRecognize('Work'),  // 'Work' 타입의 투두리스트 항목 생성
              child: Text('Work'),
            ),
            ElevatedButton(
              onPressed: () => _recordAndRecognize('Life'),  // 'Life' 타입의 투두리스트 항목 생성
              child: Text('Life'),
            ),
          ],
        ),
        SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: _todoList.length,  // 투두리스트 항목의 개수를 반환
            itemBuilder: (context, index) {
              final item = _todoList[index];  // 현재 인덱스의 항목을 가져옴
              return GestureDetector(
                onLongPress: () => _deleteItem(index),  // 항목을 길게 누르면 삭제
                child: ListTile(
                  leading: Checkbox(
                    value: item['isChecked'],  // 체크 상태를 표시
                    onChanged: (value) => _toggleCheck(index),  // 체크 상태를 변경
                  ),
                  title: Text(
                    item['text'],  // 투두리스트 텍스트를 표시
                    style: TextStyle(
                      decoration: item['isChecked'] ? TextDecoration.lineThrough : null,  // 체크된 항목은 취소선 표시
                      color: item['type'] == 'Work' ? Colors.blue : Colors.green,  // 타입에 따라 글자 색상 변경
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
