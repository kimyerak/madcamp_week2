import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SecondTab extends StatefulWidget {
  @override
  _SecondTabState createState() => _SecondTabState();
}

class _SecondTabState extends State<SecondTab> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {
    DateTime(2023, 7, 5): ['Task 1', 'Task 2'],
    DateTime(2023, 7, 7): ['Task 3'],
  };

  List<String> _getEventsForDay(DateTime day) {
    return _events[day] ?? [];
  }

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
            eventLoader: _getEventsForDay,
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
          ..._getEventsForDay(_selectedDay ?? _focusedDay).map(
                (event) => ListTile(
              title: Text(event),
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