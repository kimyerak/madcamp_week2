import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

Widget buildDailyAnalysis(List<Map<String, dynamic>> userDayTodoList) {
  final today = DateTime.now();
  final todayFormatted = DateFormat('yyyy-MM-dd').format(today);
  // 오늘 날짜의 할일 리스트를 가져옵니다.
  final todayTodos = userDayTodoList.where((element) {
    return element['date'] == todayFormatted;
  }).toList();

  // 오늘의 work와 life 할일 개수를 계산합니다.
  final workTodosToday = todayTodos.where((todo) => todo['type'] == 'Work').length.toDouble();
  final lifeTodosToday = todayTodos.where((todo) => todo['type'] == 'Life').length.toDouble();

  // 도넛형 차트로 Work/Life 비율을 보여줍니다.
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('오늘의 Work/Life 비율', style: TextStyle(fontSize: 18, color: Colors.white)),
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
      ],
    ),
  );
}