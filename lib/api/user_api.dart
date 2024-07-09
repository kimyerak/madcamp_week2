// lib/api/user_api.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:madcamp_week2/Tabs/tab1.dart';
import 'package:intl/intl.dart';

Future<void> addTodoToDB(String name, DateTime date, Map<String, dynamic> newtodo) async {
  final url = 'http://143.248.228.214:3000/users/todolists'; // 백엔드 API 엔드포인트
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({
    'user_day_todolist': [
      {
        'name': name, // 사용자의 이름을 여기에 추가합니다.
        'date': DateFormat('yyyy-MM-dd').format(date), // 현재 날짜를 사용합니다.
        'todos': [newtodo] // 단일 투두 항목을 추가합니다.
      }
    ]
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      print('Todo added successfully');
    } else {
      print('Failed to add todo: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding todo: $e');
  }
}

Future<void> deleteTodoFromDB(String name, DateTime date, String content) async {
  final url = 'http://143.248.228.214:3000/users/todolists/delete'; // 백엔드 API 엔드포인트
  final headers = {'Content-Type': 'application/json'};
  final body = json.encode({
    'name': name,
    'date': DateFormat('yyyy-MM-dd').format(date),
    'content': content
  });

  try {
    final response = await http.post(Uri.parse(url), headers: headers, body: body);
    if (response.statusCode == 200) {
      print('Deleted todo successfully');
    } else {
      print('Failed to delete todo: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting todo: $e');
  }}

Future<List<Map<String, dynamic>>> getTodosByDate(String name, DateTime date) async {
  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
  final url = Uri.parse('http://143.248.228.214:3000/users/todobydate?name=$name&date=$formattedDate');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    // Assuming each item in the data is a map containing the required fields.
    return List<Map<String, dynamic>>.from(data.map((item) => Map<String, dynamic>.from(item)));

  } else {
    throw Exception('Failed to load todos');
  }
}


Future<List<String>> getTodosByWeek(String name, DateTime startDate) async {
  final endDate = startDate.add(Duration(days: 6)); // 한 주의 끝 날짜 계산
  final url = Uri.parse('http://143.248.228.214:3000/users/todobyweek?name=$name&start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return List<String>.from(data.map((item) => item['content'] as String));
  } else {
    throw Exception('Failed to load weekly todos');
  }
}

Future<List<String>> getTodosByMonth(String name, int year, int month) async {
  final url = Uri.parse('http://143.248.228.214:3000/users/todobymonth?name=$name&year=$year&month=$month');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return List<String>.from(data.map((item) => item['content'] as String));
  } else {
    throw Exception('Failed to load monthly todos');
  }
}
