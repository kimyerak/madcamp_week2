import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madcamp_week2/api/user_api.dart';

class SecondTab extends StatefulWidget {
  final GoogleSignInAccount user;

  SecondTab({required this.user});
  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> _todosByDate = {};

  List<Map<String, dynamic>> _getTodosForDay(DateTime day) {
    return _todosByDate[day] ?? [];
  }

  void _fetchTodosForSelectedDay(DateTime day) async {
    try {
      List<Map<String, dynamic>> todos = await getTodosByDate(widget.user.displayName!, day);
      setState(() {
        _todosByDate[day] = todos;//
      });
      _showTodosDialog(day, todos);
    } catch (e) {
      print('Failed to load todos: $e');
    }
  }

  void _showTodosDialog(DateTime day, List<Map<String, dynamic>> todos) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Todo for ${day}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: todos.map((todo) {
              TextStyle textStyle = TextStyle(
                color: todo['type'] == 'work' ? Colors.red[200] : Colors.blue[200],
                decoration: todo['checked'] ? TextDecoration.underline : TextDecoration.none,
                decorationThickness: 4.0, // 밑줄 두께를 두껍게 설정
              );
              return Text(todo['content'], style: textStyle);
            }).toList(),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFF004FA0),
      ),
      body: Container(
        color: Color(0xFF004FA0),
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
                _fetchTodosForSelectedDay(selectedDay);
              },
              eventLoader: _getTodosForDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildTodosMarker(date, events),
                    );
                  }
                  return SizedBox();
                },
              ),
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(color: Colors.white),
                formatButtonTextStyle: TextStyle(color: Colors.white),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.white),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                outsideTextStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodosMarker(DateTime date, List events) {
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
