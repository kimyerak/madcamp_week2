import 'package:flutter/material.dart';
import 'package:madcamp_week2/component/speech_recognition.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위한 패키지 추가
import 'package:madcamp_week2/component/datepicker.dart';

class FirstTab extends StatefulWidget {
  @override
  _FirstTabState createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> {
  DateTime _selectedDate = DateTime.now();
  List<Map<String, dynamic>> _todoList = [];
  final SpeechRecognitionService _speechRecognitionService = SpeechRecognitionService();

  void _onDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
  }

  Future<void> _recordAndRecognize(String type) async {
    String? filePath = await _speechRecognitionService.record();
    if (filePath != null) {
      String? recognizedText = await _speechRecognitionService.recognizeSpeech(filePath);
      if (recognizedText != null) {
        setState(() {
          _todoList.add({'type': type, 'text': recognizedText, 'isChecked': false});
        });
      }
    }
  }

  void _toggleCheck(int index) {
    setState(() {
      _todoList[index]['isChecked'] = !_todoList[index]['isChecked'];
    });
  }

  void _deleteItem(int index) {
    setState(() {
      _todoList.removeAt(index);
    });
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
            itemCount: _todoList.length,
            itemBuilder: (context, index) {
              final item = _todoList[index];
              return GestureDetector(
                onLongPress: () => _deleteItem(index),
                child: ListTile(
                  leading: Checkbox(
                    value: item['isChecked'],
                    onChanged: (value) => _toggleCheck(index),
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
    );
  }
}
