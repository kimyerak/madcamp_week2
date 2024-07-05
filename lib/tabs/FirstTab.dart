import 'package:flutter/material.dart';
import 'package:kaist_week2/speech_recognition_service.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위한 패키지 추가

class FirstTab extends StatefulWidget {
  @override
  _FirstTabState createState() => _FirstTabState();
}

class _FirstTabState extends State<FirstTab> {
  late SpeechRecognitionService _speechRecognitionService;
  String _recognizedText = "Press the button and start speaking";
  DateTime _selectedDate = DateTime.now();
  List<String> _todoList = [];

  @override
  void initState() {
    super.initState();
    _speechRecognitionService = SpeechRecognitionService();
    _speechRecognitionService.initRecorder(); // 음성 녹음 초기화
  }

  // 음성을 녹음하고 인식하는 함수
  Future<void> _recognizeSpeech() async {
    setState(() {
      _recognizedText = "Recognizing...";
    });

    // 음성 녹음 시작
    String? filePath = await _speechRecognitionService.record();
    if (filePath != null) {
      // 녹음된 음성을 텍스트로 변환
      String? recognizedText = await _speechRecognitionService.recognizeSpeech(filePath);
      setState(() {
        if (recognizedText != null && recognizedText.isNotEmpty) {
          _todoList.add(recognizedText); // 인식된 텍스트를 ToDoList에 추가
          _recognizedText = "Added to ToDo List";
        } else {
          _recognizedText = "Failed to recognize speech";
        }
      });
    } else {
      setState(() {
        _recognizedText = "Failed to record speech";
      });
    }
  }

  // 날짜 선택 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate); // 날짜 형식을 지정하여 표시

    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Selected Date:',
                style: Theme.of(context).textTheme.titleLarge, // headline6 대신 titleLarge 사용
              ),
              SizedBox(height: 10),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.headlineMedium, // headline4 대신 headlineMedium 사용
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _selectDate(context),
                child: Text('Select Date'),
              ),
              SizedBox(height: 20),
              Text(
                _recognizedText,
                style: Theme.of(context).textTheme.bodyLarge, // bodyText1 대신 bodyLarge 사용
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _recognizeSpeech,
                child: Text('Start Speaking'),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _todoList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_todoList[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}