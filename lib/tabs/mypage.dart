import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kaist_week2/usercontroller.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: getKaKaoLoginButton(context),
      ),
    );
  }
}

Widget getKaKaoLoginButton(BuildContext context){
  return InkWell(
    onTap: () {
      Provider.of<UserController>(context, listen: false).signInWithKakao(context);
    },
    child: Card(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      elevation: 2,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.yellow,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Image.asset('assets/image/kakao_login_large_wide.png', width: 300, fit: BoxFit.contain),
      ),
    ),
  );
}