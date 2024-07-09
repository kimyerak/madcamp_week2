import 'package:flutter/material.dart';
import 'package:madcamp_week2/Tabs/tab1.dart'; // 각 탭의 페이지들을 import 합니다.
import 'package:madcamp_week2/Tabs/tab2.dart';
import 'package:madcamp_week2/Tabs/tab3.dart';
import 'package:madcamp_week2/Tabs/tab4.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MainTabsPage extends StatefulWidget {
  final GoogleSignInAccount user;
  MainTabsPage({required this.user});

  @override
  _MainTabsPageState createState() => _MainTabsPageState();
}

class _MainTabsPageState extends State<MainTabsPage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      FirstTab(user: widget.user),
      SecondTab(user: widget.user),
      DashboardPage(),
      MyPage(user: widget.user), // 사용자 정보를 MyPage에 전달
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF004FA0),
            icon: Icon(Icons.mic),
            label: 'Voice Recognition',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF004FA0),
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF004FA0),
            icon: Icon(Icons.list),
            label: 'Dash board',
          ),
          BottomNavigationBarItem(
            backgroundColor: Color(0xFF004FA0),
            icon: Icon(Icons.person),
            label: 'My Page',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
