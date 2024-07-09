import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SecondTab extends StatefulWidget {
  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _todos = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodoList();
    });
  }

  Future<void> _loadTodoList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? todoListString = prefs.getString('todoList');
    if (todoListString != null) {
      Map<String, dynamic> todoMap = json.decode(todoListString);
      setState(() {
        _todos = todoMap.map((key, value) {
          DateTime date = DateTime.parse(key);
          List<Map<String, dynamic>> todos = List<Map<String, dynamic>>.from(value);
          // 날짜의 시간을 제거하여 키로 사용
          DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
          return MapEntry(dateWithoutTime, todos);
        });
      });
    }
    print('Loaded todo list: ${_todos.length} dates loaded.');
  }

  void _showTodoDialog(DateTime date) {
    DateTime dateWithoutTime = DateTime(date.year, date.month, date.day);
    List<Map<String, dynamic>> todos = _todos[dateWithoutTime] ?? [];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('To-do List for ${DateFormat('yyyy-MM-dd').format(date)}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final item = todos[index];
                return ListTile(
                  title: Text(
                    item['text'],
                    style: TextStyle(
                      decoration: item['isChecked'] ? TextDecoration.lineThrough : null,
                      color: item['type'] == 'Work' ? Colors.blue : Colors.green,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
      ),
      body: GestureDetector(
        child: Column(
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
                _showTodoDialog(selectedDay);
              },
              eventLoader: (day) {
                DateTime dayWithoutTime = DateTime(day.year, day.month, day.day);
                return _todos[dayWithoutTime] ?? [];
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
          ],
        ),
      ),
    );
  }
}
