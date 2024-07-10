import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

List<FlSpot> _calculateCompletionRates(List<Map<String, dynamic>> todosList, [String? type]) {
  List<FlSpot> completionRates = [];
  if (todosList == null) {
    todosList = [];
  }
  for (int i = 0; i < 7; i++) {
    final date = DateTime.now().subtract(Duration(days: 6 - i));
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    print('Checking todos for date: $dateStr');

    final dayTodos = todosList.where((element) {
      final elementDateStr = DateFormat('yyyy-MM-dd').format(DateTime.parse(element['date']));
      print('Element date: $elementDateStr');
      return elementDateStr == dateStr;
    }).toList();

    print('Todos for date $dateStr: $dayTodos');

    final filteredTodos = type == null
        ? dayTodos.expand((element) => element['todos']).toList()
        : dayTodos.expand((element) => element['todos'].where((todo) => todo['type'] == type)).toList();

    final completedTodos = filteredTodos.where((todo) => todo['complete'] == true).length;
    final completionRate = filteredTodos.isEmpty ? 0.0 : (completedTodos / filteredTodos.length).toDouble();

    completionRates.add(FlSpot(i.toDouble(), completionRate));
  }
  return completionRates;
}

Widget buildWeeklyAnalysis(List<Map<String, dynamic>> userDayTodoList) {

  final workCompletionRates = _calculateCompletionRates(userDayTodoList, 'work');
  final lifeCompletionRates = _calculateCompletionRates(userDayTodoList, 'life');
  final allCompletionRates = _calculateCompletionRates(userDayTodoList);

  // 라인 차트로 지난 7일간의 달성율을 보여줍니다.
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('지난 7일간의 달성율', style: TextStyle(fontSize: 18, color: Colors.white)),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: allCompletionRates,
                  isCurved: true,
                  color: Colors.red,
                  barWidth: 2,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: workCompletionRates,
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: lifeCompletionRates,
                  isCurved: true,
                  color: Colors.green,
                  barWidth: 2,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
