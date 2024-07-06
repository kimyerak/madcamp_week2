import 'package:flutter/material.dart';
import 'sign_up_page.dart'; // SignUpPage 파일을 import 합니다.

void main() {
  runApp(const MyApp());
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
      home: SignUpPage(), // SignUpPage를 시작 페이지로 설정합니다.
    );
  }
}
