import 'package:flutter/material.dart';

class LoginSuccessPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('로그인 성공'),
      ),
      body: Center(
        child: Text('로그인에 성공했습니다!'),
      ),
    );
  }
}
