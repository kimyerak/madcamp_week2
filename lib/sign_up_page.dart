import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madcamp_week2_youngminyerak0/api/google_signin_api.dart'; // GoogleSigninApi 클래스를 정의한 파일을 import 합니다.
import '4tab.dart'; // 로그인 후 이동할 메인 페이지를 import 합니다.
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GoogleSignInAccount? _user;

  void _login() async {
    final user = await GoogleSigninApi.login();
    setState(() {
      _user = user;
    });

    if (_user != null) {
      print('Name: ${_user!.displayName}');
      print('Email: ${_user!.email}');
      print('ID: ${_user!.id}');
      print('Photo URL: ${_user!.photoUrl}');

      print('Trying to send user info to server');

      // await _sendUserInfoToServer(_user!);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainTabsPage(user: _user!,)),
      );
    }
  }

  Future<void> _sendUserInfoToServer(GoogleSignInAccount user) async {
    final url = Uri.parse('http://143.248.228.40:3000/users');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'displayName': user.displayName,
        'email': user.email,
        'id': user.id,
        'photoUrl': user.photoUrl,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      print('User info saved successfully');
    } else {
      print('Failed to save user info');
    }
  }


    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up Page', style: TextStyle(color: Colors.green),),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_user != null)
              Column(
                children: [
                  Text('Name: ${_user!.displayName}'),
                  Text('Email: ${_user!.email}'),
                ],
              )
            else
              ElevatedButton(
                onPressed: _login,
                child: Text('Sign in with Google'),
              ),
          ],
        ),
      ),
    );
  }
  Future signIn() async{
    await GoogleSigninApi.login();
  }
}
