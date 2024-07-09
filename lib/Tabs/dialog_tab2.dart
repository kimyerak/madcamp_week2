// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:madcamp_week2/api/user_api.dart';
// import 'package:intl/intl.dart';
//
// class SecondTab extends StatefulWidget {
//   final GoogleSignInAccount user;
//
//   SecondTab({required this.user});
//   @override
//   _SecondTabState createState() => _SecondTabState();
// }
//
// class _SecondTabState extends State<SecondTab> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   // Map<DateTime, List<Map<String, dynamic>>> _todosByDate = {};
//   List<Map<String, dynamic>> _todoList = [];
//
//   // List<Map<String, dynamic>> _getTodosForDay(DateTime day) {
//   //   return _todoList.where((todo) => isSameDay(todo['date'], day)).toList();
//   // }
//   List<Map<String, dynamic>> _getTodosForDay(DateTime day) {
//     print('날짜별 할 일 가져오기: $day');
//     return _todoList.where((todo) {
//       final todoDate = todo['date'];
//       if(todoDate == null) {print("날짜가 null"); return false;}
//       final isSame = (todoDate.year == day.year && todoDate.month == day.month && todoDate.day == day.day);
//       print('비교: todoDate: $todoDate, day: $day, isSame: $isSame');
//       return isSame;
//     }).toList();
//   }
// //방법2. DB에서 불러오기로만 구현
//   void _fetchTodosForSelectedDay(DateTime day) async {
//     try {
//       print("api함수 호출하는중");
//       List<Map<String, dynamic>> todos =
//       await getTodosByDate(widget.user.displayName!, day.toUtc());
//       for (var todo in todos) {
//         if (todo['date'] == null) {
//           todo['date'] = DateTime.utc(day.year, day.month, day.day); // 시간 부분 제거
//         } else {
//           // date 필드가 이미 존재하는 경우에도 시간 부분을 제거
//           DateTime todoDate = todo['date'];
//           todo['date'] = DateTime.utc(todoDate.year, todoDate.month, todoDate.day);
//         }
//       }
//       print("Todos fetched: $todos");
//       setState(() {
//         _todoList = todos;
//       });
//       _showTodosDialog(day, todos);
//     } catch (e) {
//       print('Failed to load todos: $e');
//     }
//   }
//   // void _fetchTodosForSelectedDay(DateTime day) async {
//   //   try {
//   //     List<Map<String, dynamic>> todos = await getTodosByDate(widget.user.displayName!, day);
//   //     setState(() {
//   //       _todosByDate[day] = todos;
//   //     });
//   //     _showTodosDialog(day, todos);
//   //   } catch (e) {
//   //     print('Failed to load todos: $e');
//   //   }
//   // }
//   void _toggleCheck(int index, Function updateState ) async {
//     updateState(() {
//       _todoList[index]['complete'] = !_todoList[index]['complete'];
//     });
//     await _updateTodoStatus(_todoList[index]);
//
//   }
//   Future<void> _updateTodoStatus(Map<String, dynamic> todo) async {
//     print("update투두 함수가 호출됨");
//     try {
//       await updateTodoInDB(widget.user.displayName ?? '', _selectedDay!, todo);
//     } catch (e) {
//       print('Failed to update todo: $e');
//     }
//   }
//   void _showTodosDialog(DateTime day, List<Map<String, dynamic>> todos) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return AlertDialog(
//               title: Text('Todo for ${DateFormat('yyyy-MM-dd').format(day)}'),
//               // content: Column(
//               //   mainAxisSize: MainAxisSize.min,
//               //   children: todos.map((todo) => Text(todo['content'])).toList(),
//               // ),
//               content: Container(
//                 width: double.maxFinite,
//                 height: 400,
//                 child: ListView.builder(
//                   itemCount: _todoList.length,
//                   itemBuilder: (context, index) {
//                     final item = _todoList[index];
//                     return ListTile(
//                       leading: Checkbox(
//                         value: item['complete'],
//                         onChanged: (value) {
//                           setState(() {
//                             item['complete'] = value;
//                           });
//                           _toggleCheck(index, (updateState) {
//                             setState(() {
//                               _todoList[index]['complete'] = value;
//                             });
//                           });
//                         }
//                       ),
//                       title: Text(
//                         item['content'],
//                         style: TextStyle(
//                           decoration: item['complete']
//                               ? TextDecoration.lineThrough
//                               : null,
//                           color:
//                           item['type'] == 'Work' ? Colors.blue : Colors.green,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   child: Text('Close'),
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             );
//           }
//         );
//       },
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Calendar'),
//       ),
//       body: Column(
//         children: [
//           TableCalendar(
//             firstDay: DateTime(2020),
//             lastDay: DateTime(2030),
//             focusedDay: _focusedDay,
//             // selectedDayPredicate: (day) {
//             //   return isSameDay(_selectedDay, day);
//             // },
//             selectedDayPredicate: (day) {
//               return _selectedDay != null && _selectedDay!.year == day.year && _selectedDay!.month == day.month && _selectedDay!.day == day.day;
//             },
//             onDaySelected: (selectedDay, focusedDay) {
//               setState(() {
//                 // _selectedDay = selectedDay;
//                 // _focusedDay = focusedDay;
//                 _selectedDay = DateTime.utc(selectedDay.year, selectedDay.month, selectedDay.day);
//                 _focusedDay = DateTime.utc(focusedDay.year, focusedDay.month, focusedDay.day);
//               });
//               _fetchTodosForSelectedDay(_selectedDay!);
//             },
//             // eventLoader: (day) => _getTodosForDay(day),
//             eventLoader: (day) {
//               final events = _getTodosForDay(day);
//               print('eventLoader 호출: $day, events: $events');
//               return events;
//             },
//             calendarBuilders: CalendarBuilders(
//               markerBuilder: (context, date, events) {
//                 if (events.isNotEmpty) {
//                   print("마커 호출 시도중 $date, events: $events");
//                   return Positioned(
//                     right: 1,
//                     bottom: 1,
//                     child: _buildTodosMarker(date, events),
//                   );
//                 }
//                 return SizedBox();
//               },
//             ),
//           ),
//           // ..._getTodosForDay(_selectedDay ?? _focusedDay).map(
//           //       (event) => ListTile(
//           //     title: Text(event),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTodosMarker(DateTime date, List events) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         color: Colors.pink,
//       ),
//       width: 16.0,
//       height: 16.0,
//       child: Center(
//         child: Text(
//           '${events.length}',
//           style: TextStyle().copyWith(
//             color: Colors.white,
//             fontSize: 12.0,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:madcamp_week2/api/user_api.dart';

class DialogForTab2 {
  final BuildContext context;
  final GoogleSignInAccount user;


  DialogForTab2({
    required this.context,
    required this.user,

  });

  void showTodosDialog(List<Map<String, dynamic>> todoList, DateTime day) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Todo for ${DateFormat('yyyy-MM-dd').format(day)}'),
              content: Container(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  itemCount: todoList.length,
                  itemBuilder: (context, index) {
                    final item = todoList[index];
                    return ListTile(
                      leading: Checkbox(
                        value: item['complete'],
                        onChanged: (value) {
                          setState(() {
                            item['complete'] = value;
                          });
                          toggleCheck(todoList, index, (updateState) {
                            setState(() {
                              todoList[index]['complete'] = value;
                            });
                          });
                        },
                      ),
                      title: Text(
                        item['content'],
                        style: TextStyle(
                          decoration: item['complete']
                              ? TextDecoration.lineThrough
                              : null,
                          color: item['type'] == 'Work' ? Colors.blue : Colors.green,
                        ),
                      ),
                    );
                  },
                ),
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
      },
    );
  }

  void toggleCheck(List<Map<String, dynamic>> todoList, int index, Function updateState) async {
    updateState(() {
      todoList[index]['complete'] = !todoList[index]['complete'];
    });
    await _updateTodoStatus(todoList[index]);
  }

  Future<void> _updateTodoStatus(Map<String, dynamic> todo) async {
    try {
      await updateTodoInDB(user.displayName ?? '', todo['date'], todo);
    } catch (e) {
      print('Failed to update todo: $e');
    }
  }

  Future<void> fetchTodosForSelectedDay(DateTime day, Function(List<Map<String, dynamic>>) updateTodoList) async {
    try {
      List<Map<String, dynamic>> todos = await getTodosByDate(user.displayName!, day);
      for (var todo in todos) {
        if (todo['date'] == null) {
          todo['date'] = DateTime(day.year, day.month, day.day);
        } else {
          DateTime todoDate = todo['date'];
          todo['date'] = DateTime(todoDate.year, todoDate.month, todoDate.day);
        }
      }
      updateTodoList(todos);
      showTodosDialog(todos, day);
    } catch (e) {
      print('Failed to load todos: $e');
    }
  }
}
