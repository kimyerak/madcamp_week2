import 'package:flutter/material.dart';

class TodoProvider with ChangeNotifier {
  Map<DateTime, List<Map<String, dynamic>>> _todos = {};  // 날짜별로 투두리스트를 저장

  Map<DateTime, List<Map<String, dynamic>>> get todos => _todos;  // 투두리스트를 반환

  void addTodoItem(DateTime date, Map<String, dynamic> todo) {
    if (_todos[date] == null) {
      _todos[date] = [];
    }
    _todos[date]!.add(todo);  // 해당 날짜에 투두 항목을 추가
    notifyListeners();  // 상태 변경을 통지
  }

  void removeTodoItem(DateTime date, int index) {
    _todos[date]?.removeAt(index);  // 해당 날짜에서 특정 인덱스의 항목을 삭제
    notifyListeners();  // 상태 변경을 통지
  }

  List<Map<String, dynamic>> getTodosForDate(DateTime date) {
    return _todos[date] ?? [];  // 특정 날짜에 해당하는 투두 항목들을 반환
  }
}
