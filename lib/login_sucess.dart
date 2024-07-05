import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'usercontroller.dart';

class LoginSuccessPage extends StatelessWidget {
  const LoginSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그인 성공'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _profile(),
            _nickName(),
            _logoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _profile() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: 100,
      height: 100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Consumer<UserController>(builder: (context, controller, child) {
          final String? src = controller.user?.properties?["profile_image"];
          if (src != null) {
            return Image.network(src, fit: BoxFit.cover);
          } else {
            return Container(
              color: Colors.black,
            );
          }
        }),
      ),
    ),
  );

  Widget _nickName() => Padding(
    padding: const EdgeInsets.all(8.0),
    child: Consumer<UserController>(builder: (context, controller, child) {
      final String? name = controller.user?.properties?["nickname"];
      if (name != null) {
        return Text(name);
      } else {
        return const Text("로그인이 필요합니다");
      }
    }),
  );

  Widget _logoutButton(BuildContext context) => Consumer<UserController>(
    builder: (context, controller, child) {
      if (controller.user != null) {
        return ElevatedButton(
          onPressed: () {
            controller.logout();
            Navigator.pushReplacementNamed(context, '/');
          },
          child: const Text('로그아웃'),
        );
      } else {
        return Container();
      }
    },
  );
}
