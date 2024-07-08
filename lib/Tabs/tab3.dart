import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:text_analysis/text_analysis.dart';
import 'package:word_cloud/word_cloud.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});


  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<Map<String, double>>? wordCountsFuture;

  @override
  void initState() {
    super.initState();
    wordCountsFuture = fetchAndSetData();
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
        title: const Text('분석 Page'), // 분석 페이지 상단 제목
      ),
      body: FutureBuilder<Map<String, double>>(
        future: wordCountsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // 로딩 중 표시
          } else if (snapshot.hasError) {
            return Center(child: Text('An error occurred!')); // 에러 발생 시 표시
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> convertedList = snapshot.data!.entries.map((entry) {
              return {'word': entry.key, 'value': entry.value};
            }).toList();

            WordCloudData wcdata = WordCloudData(data: convertedList);

            return Center(
              child: WordCloudView(
                data: wcdata,
                maxtextsize: 50,
                mintextsize: 10,
                mapcolor: Colors.white,
                mapwidth: 300,
                mapheight: 350,
                fontWeight: FontWeight.bold,
                colorlist: [Colors.blue, Colors.green, Colors.black],
              ),
            );
          } else {
            return Center(child: Text('No data available!'));
          }
        },
      ),
    );
  }
}
