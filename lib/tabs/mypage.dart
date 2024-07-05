import 'package:flutter/material.dart';
import 'package:kaist_week2/login.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: getKaKaoLoginButton(),
      ),
    );
  }
}

Widget getKaKaoLoginButton(){
  return InkWell(
    onTap: (){
      signin_withkakao(context);
    },
    child: Card(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      elevation: 2,
        child: Container(
          height: 50,
            decoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(7)
            ),
            child: Image.asset('assets/image/kakao_login_large_wide.png', width: 10, fit: BoxFit.contain),
        ),
    ),
  );
}
