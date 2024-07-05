import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

class UserController with ChangeNotifier {
  User? _user;
  User? get user => _user;

  Future<void> signInWithKakao(BuildContext context) async {
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
        print('카카오톡으로 로그인 성공');
        _user = await UserApi.instance.me();
        notifyListeners();
        Navigator.pushReplacementNamed(context, '/loginSuccess');
      } catch (error) {
        print('카카오톡으로 로그인 실패 $error');
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        try {
          await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공');
          _user = await UserApi.instance.me();
          notifyListeners();
          Navigator.pushReplacementNamed(context, '/loginSuccess');
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } else {
      try {
        await UserApi.instance.loginWithKakaoAccount();
        _user = await UserApi.instance.me();
        notifyListeners();
        Navigator.pushReplacementNamed(context, '/loginSuccess');
        print('카카오계정으로 로그인 성공');
      } catch (error) {
        print('카카오계정으로 로그인 실패 $error');
      }
    }
  }

  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      _user = null;
      notifyListeners();
      print('로그아웃 성공, SDK에서 토큰 삭제');
    } catch (error) {
      print('로그아웃 실패, SDK에서 토큰 삭제 $error');
    }
  }
}
