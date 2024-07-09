import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'sign_up_page.dart'; // SignUpPage 파일을 import 합니다.
import 'package:madcamp_week2/component/todo_provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),  // TodoProvider를 위젯 트리에 추가
      ],
      child: const MyApp(),
    ),
  );
  FlutterNativeSplash.remove();
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
