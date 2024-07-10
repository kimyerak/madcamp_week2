import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madcamp_week2/api/user_api.dart';
import './dialog_tab2.dart';

class SecondTab extends StatefulWidget {
  final GoogleSignInAccount user;

  SecondTab({required this.user});
  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, int> _todosByDate = {}; // 날짜별 todo 개수 저장
  List<Map<String, dynamic>> _todoList = [];

  @override
  void initState() {
    super.initState();
    _fetchAllTodobyName(); // 탭을 처음 열 때 모든 todo 데이터를 가져옴
  }

  void _fetchAllTodobyName() async {
    try {
      print("일별 todo 데이터를 가져오는 중");
      Map<String, dynamic> todosByDate = await getAllTodos(widget.user.displayName!); // 새로운 API 호출

      Map<DateTime, int> parsedTodosByDate = {};
      todosByDate.forEach((dateString, todos) {
        DateTime date = DateTime.parse(dateString);
        parsedTodosByDate[date] = todos.length;
      });

      setState(() {
        _todosByDate = parsedTodosByDate;
        print("상태 변경 후 데이터: $_todosByDate");
      });
    } catch (e) {
      print('Failed to load todos: $e');
    }
  }

  void _updateTodoList(List<Map<String, dynamic>> todos) {
    setState(() {
      _todoList = todos;
    });
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
                return _selectedDay != null &&
                    _selectedDay!.year == day.year &&
                    _selectedDay!.month == day.month &&
                    _selectedDay!.day == day.day;
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
                  _focusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
                });
                DialogForTab2(context: context,
                  user: widget.user,
                ).fetchTodosForSelectedDay(_selectedDay!, _updateTodoList);
              },
              eventLoader: (day) {
                print("eventLoader 호출 시도중 $day");
                return _todosByDate[DateTime(day.year, day.month, day.day)] != null ? List.filled(_todosByDate[DateTime(day.year, day.month, day.day)]!, 'events') : [];
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    print("마커 호출 시도중 $date, events: $events");
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildTodosMarker(date, events.length),
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
                todayTextStyle: TextStyle(color: Colors.black),
                selectedTextStyle: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodosMarker(DateTime date, int eventcount) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.pink,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '$eventcount',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }
}
