import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:text_analysis/text_analysis.dart';
import 'package:word_cloud/word_cloud.dart';




Future<Map<String, double>> collectFrequentWords(List<String> texts, int minFrequency) async {
  final Map<String, double> wordFrequencies = {};
  try {
    for (String text in texts) {
      final textDoc = await TextDocument.analyze(
        sourceText: text,
        analyzer: English.analyzer,
        nGramRange: NGramRange(1, 1),
      );
      textDoc.tokens.forEach((token) {
        final word = token.term;
        if (word.isNotEmpty && !RegExp(r'\d').hasMatch(word)) {
          wordFrequencies[word] = ((wordFrequencies[word] ?? 0) + 1).toDouble();
        }
      });
    }
    wordFrequencies.removeWhere((key, value) => value < minFrequency);
    return wordFrequencies;
  } catch (e) {
    throw e;
  }
}

Future<Map<String, double>> fetchAndSetData() async {
  try {
    final String response = await rootBundle.loadString('assets/test.json');
    final data = await json.decode(response);

    List<String> loadedTexts = [];

    data['user_day_todolist'].forEach((day) {
      day['todos'].forEach((todo) {
        loadedTexts.add(todo['content']);
      });
    });

    final wordFrequencies = await collectFrequentWords(loadedTexts, 2);
    return wordFrequencies;
  } catch (e) {
    throw e;
  }
}

Widget buildMonthlyAnalysis() {
  return FutureBuilder<Map<String, double>>(
    future: fetchAndSetData(),
    builder: (ctx, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('An error occurred!'));
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
  );
}
