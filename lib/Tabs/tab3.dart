import 'package:flutter/material.dart';
import 'package:madcamp_week2/component/buildDailyAnalysis.dart';
import 'package:madcamp_week2/component/buildWeeklyAnalysis.dart';
import 'package:madcamp_week2/component/buildMonthlyAnalysis.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;


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
