import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyPage extends StatelessWidget {
  final GoogleSignInAccount user;

  MyPage({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF023047),
          title: const Text('My Profile', style:TextStyle(fontSize:25, color: Colors.green)),
      ),
      backgroundColor: Color(0xFF004FA0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user.photoUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(user.photoUrl!),
                radius: 50,
              ),
            SizedBox(height: 20),
            Text(
              'id: ${user.id}',
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Name: ${user.displayName}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 10),
            Text(
              'Email: ${user.email}',
              style: TextStyle(fontSize: 20),
            ),

          ],
        ),
      ),
    );
  }
}
