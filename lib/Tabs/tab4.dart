import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPage extends StatefulWidget {
  final GoogleSignInAccount user;

  MyPage({required this.user});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  String? runningMate;

  @override
  void initState() {
    super.initState();
    _loadRunningMate();
  }

  Future<void> _loadRunningMate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      runningMate = prefs.getString('runningMate') ?? 'No Running Mate set';
    });
  }

  Future<void> _saveRunningMate(String mate) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('runningMate', mate);
    setState(() {
      runningMate = mate;
    });
  }

  Future<void> _showRunningMateDialog() async {
    TextEditingController controller = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Running Mate'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Running Mate Name'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('SAVE'),
              onPressed: () {
                _saveRunningMate(controller.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF004FA0),
        title: const Text('My Profile', style: TextStyle(fontSize: 25, color: Colors.white)),
      ),
      backgroundColor: Color(0xFF004FA0),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (widget.user.photoUrl != null)
              CircleAvatar(
                backgroundImage: NetworkImage(widget.user.photoUrl!),
                radius: 50,
              ),
            SizedBox(height: 10), // Reduced the height
            Text(
              'id: ${widget.user.id}',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 5), // Reduced the height
            Text(
              'Name: ${widget.user.displayName}',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 5), // Reduced the height
            Text(
              'Email: ${widget.user.email}',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 10), // Reduced the height
            Text(
              'Running Mate: $runningMate',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
            SizedBox(height: 10), // Kept as is for better button spacing
            ElevatedButton(
              onPressed: _showRunningMateDialog,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFFD9D9D9)),
              ),
              child: Text('Change Running Mate'),
            ),
          ],
        ),
      ),
    );
  }
}
