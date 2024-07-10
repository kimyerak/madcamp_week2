import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

List<FlSpot> _calculateCompletionRates(List<Map<String, dynamic>> todosList, [String? type]) {
  List<FlSpot> completionRates = [];
  for (int i = 0; i < 7; i++) {
    final date = DateTime.now().subtract(Duration(days: 7 - i));
    final dateStr = date.toIso8601String().split('T').first;
    final dayTodos = todosList.firstWhere(
          (element) => element['date'] == dateStr,
      orElse: () => {'todos': []},
    )['todos'];
    final filteredTodos = type == null ? dayTodos : dayTodos.where((todo) => todo['type'] == type).toList();
    final completedTodos = filteredTodos.where((todo) => todo['complete'] == true).length;
    final completionRate = filteredTodos.isEmpty ? 0.0 : (completedTodos / filteredTodos.length).toDouble();
    completionRates.add(FlSpot(i.toDouble(), completionRate));
  }
  return completionRates;
}

Widget buildWeeklyAnalysis(List<Map<String, dynamic>> userDayTodoList) {
  final today = DateTime.now();
  final lastWeek = today.subtract(Duration(days: 7));
  final pastWeekTodos = userDayTodoList.where((element) {
    final date = DateTime.parse(element['date']);
    return date.isAfter(lastWeek) && date.isBefore(today);
  }).toList();

  final workCompletionRates = _calculateCompletionRates(pastWeekTodos, 'work');
  final lifeCompletionRates = _calculateCompletionRates(pastWeekTodos, 'life');
  final allCompletionRates = _calculateCompletionRates(pastWeekTodos);

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
