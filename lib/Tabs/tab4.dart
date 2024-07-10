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
      },//
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
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Table(
                  columnWidths: const {
                    0: FlexColumnWidth(),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      children: [
                        Container(
                          color: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'ID',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            widget.user.id,
                            style: TextStyle(fontSize: 14, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Container(
                          color: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Name',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            widget.user.displayName ?? '',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Container(
                          color: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Email',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            widget.user.email,
                            style: TextStyle(fontSize: 12, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        Container(
                          color: Colors.white.withOpacity(0.2),
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Running Mate',
                            style: TextStyle(fontSize: 14.5, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            runningMate ?? 'No Running Mate set',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
