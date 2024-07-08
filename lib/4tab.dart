import 'package:flutter/material.dart';
import 'package:madcamp_week2_youngminyerak0/Tabs/tab1.dart';  // 각 탭의 페이지들을 import 합니다.
import 'package:madcamp_week2_youngminyerak0/Tabs/tab2.dart';
import 'package:madcamp_week2_youngminyerak0/Tabs/tab3.dart';
import 'package:madcamp_week2_youngminyerak0/Tabs/tab4.dart';
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
      FirstTab(),  // 음성 인식을 통한 투두리스트 페이지
      SecondTab(),  // 캘린더 페이지
      DashboardPage(),  // 대시보드 페이지
      MyPage(user: widget.user),  // 사용자 정보를 MyPage에 전달
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;  // 선택된 탭 인덱스를 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Tabs Page'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),  // 선택된 탭의 위젯을 표시
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: 'Voice Recognition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Page',
          ),
        ],
        currentIndex: _selectedIndex,  // 현재 선택된 인덱스
        selectedItemColor: Colors.green[800],  // 선택된 아이템 색상
        unselectedItemColor: Colors.green[200],  // 선택되지 않은 아이템 색상
        onTap: _onItemTapped,  // 탭이 선택될 때 호출되는 메서드
      ),
    );
  }
}
