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

  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white),
            color: Color(0xFF004FA0), // 이전과 동일한 배경색
          ),
          child: buildDailyAnalysis(userDayTodoList),
        );
      case 1:
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white),
            color: Color(0xFF004FA0), // 이전과 동일한 배경색
          ),
          child: buildWeeklyAnalysis(userDayTodoList),
        );
      case 2:
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white),
            color: Color(0xFF004FA0), // 이전과 동일한 배경색
          ),
          child: buildMonthlyAnalysis(),
        );
      case 3:
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                  color: Color(0xFF004FA0), // 이전과 동일한 배경색
                ),
                child: buildDailyAnalysis(userDayTodoList),
              ),
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                  color: Color(0xFF004FA0), // 이전과 동일한 배경색
                ),
                child: buildWeeklyAnalysis(userDayTodoList),
              ),
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                  color: Color(0xFF004FA0), // 이전과 동일한 배경색
                ),
                child: buildMonthlyAnalysis(),
              ),
            ],
          ),
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004FA0),
        title: const Text(
          'Analyze',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Color(0xFF004FA0),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(10.0),
              fillColor: Color(0xFFD9D9D9),
              selectedColor: Colors.black,
              color: Colors.white,
              selectedBorderColor: Color(0xFFD9D9D9),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('일별', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('주별', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('월별', style: TextStyle(fontSize: 16)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text('***', style: TextStyle(fontSize: 16)),
                ),
              ],
              isSelected: [selectedIndex == 0, selectedIndex == 1, selectedIndex == 2, selectedIndex == 3],
              onPressed: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
            ),
          ),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }
}
