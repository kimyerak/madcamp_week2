import 'package:flutter/material.dart';
import 'package:provider/provider.dart';  // Provider 패키지를 사용하기 위해 import
import 'sign_up_page.dart';  // SignUpPage 파일을 import
import 'package:madcamp_week2_youngminyerak0/component/todo_provider.dart';  // TodoProvider 파일을 import

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),  // TodoProvider를 위젯 트리에 추가
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SignUpPage(),  // SignUpPage를 시작 페이지로 설정
    );
  }
}
