import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:madcamp_week2/api/google_signin_api.dart'; // GoogleSigninApi 클래스를 정의한 파일을 import 합니다.
import '4tab.dart'; // 로그인 후 이동할 메인 페이지를 import 합니다.
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart'; // Add this line

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  GoogleSignInAccount? _user;
  String _message = '';

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
      final result = await check_if_new_or_exist(_user!);

      if (result == 'new') {
        await send_newUserInfo_ToServer(_user!);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainTabsPage(user: _user!,)),
        );
      } else if (result == 'exists') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('이미 가입된 유저입니다'),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainTabsPage(user: _user!,)),
        );
      } else {
        setState(() {
          _message = '새 유저도 아니고 이미 가입한 유저도 아님';
        });
      }
    }
  }

  Future<String> check_if_new_or_exist(GoogleSignInAccount user) async {
    final url = Uri.parse('http://143.248.228.214:3000/users/signup');
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
      return 'new';
    } else if (response.statusCode == 409) {
      print('User already exists');
      return 'exists';
    } else {
      print('Failed to check user info');
      return 'error';
    }
  }

  Future<void> send_newUserInfo_ToServer(GoogleSignInAccount user) async {
    final url = Uri.parse('http://143.248.228.214:3000/users/signup');
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
      setState(() {
        _message = '새 유저 정보를 저장하는데 실패했습니다';
      });
    }
  }

  void _navigateToMainTabsPage() async {
    final user = await GoogleSigninApi.login();
    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainTabsPage(user: user)),
      );
    } else {
      setState(() {
        _message = '로그인에 실패했습니다. 다시 시도해주세요.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004FA0),
        title: Text('Sign Up Page', style: TextStyle(color: Colors.white),),
      ),
      backgroundColor: Color(0xFF004FA0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'assets/Image/voice-record.svg',
                  height: 100,
                  width: 100,
                  color: Colors.white.withOpacity(0.3),
                ),
                ElevatedButton.icon(
                  icon: Image.asset(
                    'assets/Image/google.png',
                    height: 24, // 버튼 세로 높이와 이미지 크기를 맞춤
                    fit: BoxFit.contain,
                  ),
                  label: Text('Sign in/up with Google'),
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(
              height:20,
            ),
            ElevatedButton(
              onPressed: _navigateToMainTabsPage,
              child: Text('이미 로그인 했어요'),
            ),
          ],
        ),
      ),
    );
  }

  Future signIn() async {
    await GoogleSigninApi.login();
  }
}
