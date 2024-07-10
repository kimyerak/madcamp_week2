import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:text_analysis/text_analysis.dart';
import 'package:word_cloud/word_cloud.dart';
import 'package:madcamp_week2/component/buildweeklyAnalysis.dart';
import 'package:madcamp_week2/component/buildmonthlyAnalysis.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:madcamp_week2/api/user_api.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatefulWidget {
  final GoogleSignInAccount user;
  const DashboardPage({Key? key, required this.user}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, dynamic>> userDayTodoList = [];
  List<Map<String, dynamic>> weeklyTodoList = [];
  List<Map<String, dynamic>> monthlyTodoList = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _loadDailyTodoList();
    } else {
      print('User is null');
    }
  }

  // 1. 일별 분석
  Future<void> _loadDailyTodoList() async {
    try {
      DateTime today = DateTime.now();
      List<Map<String, dynamic>> data = await getTodosByDate(widget.user.displayName!, today);

      // 필수 필드가 있는지 확인하고 없으면 기본값 설정
      data.forEach((todo) {
        if (todo['content'] == null || todo['content'].isEmpty) {
          todo['content'] = 'No content'; // 기본값 설정
        }
      });

      setState(() {
        userDayTodoList = data;
      });
      print('Daily Todos: $userDayTodoList');
    } catch (e) {
      print('Error loading daily todos: $e');
    }
  }

  // 2. 주별 분석
  Future<void> _loadWeeklyTodoList() async {
    try {
      DateTime today = DateTime.now();
      DateTime startDate = today.subtract(Duration(days: today.weekday % 7)); // 현재 주의 일요일을 startDate로 설정
      DateTime endDate = startDate.add(Duration(days: 6)); // 주의 끝 날짜 설정
      List<Map<String, dynamic>> data = await getTodosByWeek(widget.user.displayName!, startDate);

      print('Fetched Weekly Todos: $data');

      data.forEach((todo) {
        if (todo['content'] == null || todo['content'].isEmpty) {
          todo['content'] = 'No content';
        }
      });

      setState(() {
        weeklyTodoList = data;
      });
      print('Processed Weekly Todos: $weeklyTodoList');
    } catch (e) {
      print('Error loading weekly todos: $e');
    }
  }

  // 3. 월별 분석
  Future<void> _loadMonthlyTodoList() async {
    try {
      DateTime now = DateTime.now();
      List<Map<String, dynamic>> data = await getTodosByMonth(widget.user.displayName!, now.year, now.month);

      setState(() {
        monthlyTodoList = data.map((item) {
          if (item['content'] == null || item['content'].isEmpty) {
            item['content'] = 'No content'; // 기본값 설정
          }
          return item;
        }).toList();
      });
      print('Monthly Todos: $monthlyTodoList');
    } catch (e) {
      print('Error loading monthly todos: $e');
    }
  }




//이제 load 함수들 다 끝나고 화면 그리는 로직
  Widget _buildDailyAnalysis() {

    // 오늘의 work와 life 할일 개수를 계산합니다.
    final workTodosToday = userDayTodoList.where((todo) => todo['type'] == 'Work').length.toDouble();
    final lifeTodosToday = userDayTodoList.where((todo) => todo['type'] == 'Life').length.toDouble();
    // 디버깅용 출력
    print('Work Todos Today: $workTodosToday');
    print('Life Todos Today: $lifeTodosToday');
    // 도넛형 차트로 Work/Life 비율을 보여줍니다.
    return Center(
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 40,),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: Colors.blue,
                    value: workTodosToday,
                    title: 'Work',
                    radius: 50,
                  ),
                  PieChartSectionData(
                    color: Colors.green,
                    value: lifeTodosToday,
                    title: 'Life',
                    radius: 50,
                  ),

                ],
              ),
            ),
          ),
          SizedBox(height: 40,),
          Text('오늘의 Work/Life 비율', style: TextStyle(fontSize: 18, color: Colors.white)),
        ],
      ),
    );
  }
  Widget _buildContent() {
    switch (selectedIndex) {
      case 0:
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(color: Colors.white),
            color: Color(0xFF004FA0), // 이전과 동일한 배경색
          ),
          child: _buildDailyAnalysis(),
        );
      case 1:
        return Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // border: Border.all(color: Colors.white),
            color: Color(0xFF004FA0), // 이전과 동일한 배경색
          ),
          child: buildWeeklyAnalysis(weeklyTodoList),
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
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                  color: Color(0xFF004FA0), // 이전과 동일한 배경색
                ),
                child: _buildDailyAnalysis(),
              ),
              Container(
                margin: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white),
                  color: Color(0xFF004FA0), // 이전과 동일한 배경색
                ),
                child: buildWeeklyAnalysis(weeklyTodoList),
              ),
              Container(
                margin: EdgeInsets.all(30),
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
          'Dashboard',
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
              onPressed: (int index) async {
                setState(() {
                  selectedIndex = index;
                });
                if (index == 0) {
                  await _loadDailyTodoList();
                } else if (index == 1) {
                  await _loadWeeklyTodoList();
                } else if (index == 2) {
                  await _loadMonthlyTodoList();
                }
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
