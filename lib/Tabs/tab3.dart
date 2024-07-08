import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:text_analysis/text_analysis.dart';
import 'package:word_cloud/word_cloud.dart';
import 'package:madcamp_week2/component/buildDailyAnalysis.dart';
import 'package:madcamp_week2/component/buildweeklyAnalysis.dart';
import 'package:madcamp_week2/component/buildmonthlyAnalysis.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});


  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> userDayTodoList = [];
  int selectedIndex = 0;


  @override
  void initState() {
    super.initState();
    _loadTodoList();
  }
  Future<void> _loadTodoList() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/test.json');

      if (!await file.exists()) {
        final data = await rootBundle.loadString('assets/test.json');
        await file.writeAsString(data);
      }

      final String response = await file.readAsString();
      final data = json.decode(response)['user_day_todolist'] as List<dynamic>;

      setState(() {
        userDayTodoList = data.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      print('Error loading JSON: $e');
    }
  }

  Future<Map<String, double>> fetchAndSetData() async {
    try {
      final String response = await rootBundle.loadString('assets/test.json'); // JSON 파일 읽기
      final data = await json.decode(response);

      List<String> loadedTexts = [];

      data['user_day_todolist'].forEach((day) {
        day['todos'].forEach((todo) {
          loadedTexts.add(todo['content']); // 할일 내용 추가
        });
      });

      final wordFrequencies = await collectFrequentWords(loadedTexts, 2);
      return wordFrequencies;
    } catch (e) {
      throw e;
    }
  }

  Future<Map<String, double>> collectFrequentWords(List<String> texts, int minFrequency) async {
    final Map<String, double> wordFrequencies = {};
    try {
      for (String text in texts) {
        final textDoc = await TextDocument.analyze(
            sourceText: text,
            analyzer: English.analyzer,
            nGramRange: NGramRange(1, 1));
        // 단어 빈도수 계산
        textDoc.tokens.forEach((token) {
          final word = token.term;
          if (word.isNotEmpty && !RegExp(r'\d').hasMatch(word)) { // 숫자가 포함된 단어 제거
            wordFrequencies[word] = ((wordFrequencies[word] ?? 0) + 1).toDouble();
          }
        });
      }
      // 최소 빈도 조건에 맞는 단어들만 남김
      wordFrequencies.removeWhere((key, value) => value < minFrequency);
      return wordFrequencies;
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('분석 Page'),
      ),
      body: Column(
        children: [
          ToggleButtons(
            children: [Text('일별'), Text('주별'), Text('월별')],
            isSelected: [selectedIndex == 0, selectedIndex == 1, selectedIndex == 2],
            onPressed: (int index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
          Expanded(
            child: selectedIndex == 0
                ? buildDailyAnalysis(userDayTodoList)
                : selectedIndex == 1
                ? buildWeeklyAnalysis(userDayTodoList)
                : buildMonthlyAnalysis(),
          ),
        ],
      ),
    );
  }
}
