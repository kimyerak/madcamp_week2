import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';  // TableCalendar 패키지 import
import 'package:provider/provider.dart';  // Provider 패키지 import
import 'package:madcamp_week2_youngminyerak0/component/todo_provider.dart';  // TodoProvider 파일 import

class SecondTab extends StatefulWidget {
  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  DateTime _focusedDay = DateTime.now();  // 현재 포커스된 날짜를 저장
  DateTime? _selectedDay;  // 선택된 날짜를 저장

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              return Provider.of<TodoProvider>(context).getTodosForDate(day);  // 해당 날짜의 투두 항목들을 로드하여 달력에 표시
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    right: 1,
                    bottom: 1,
                    child: _buildEventsMarker(date, events),
                  );
                }
                return SizedBox();
              },
            ),
          ),
          ...Provider.of<TodoProvider>(context)
              .getTodosForDate(_selectedDay ?? _focusedDay)
              .map(
                (event) => ListTile(
              title: Text(event['text']),
              leading: Checkbox(
                value: event['isChecked'],
                onChanged: (value) {
                  setState(() {
                    event['isChecked'] = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.pink,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
