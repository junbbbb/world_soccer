import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            HomeTab(),
            Center(child: Text('채팅')),
            Center(child: Text('스탯')),
            Center(child: Text('팀')),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                offset: const Offset(0, -1),
                blurRadius: 4,
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: const Color(0xFF333D4B),
            unselectedItemColor: const Color(0xFF8E97A3),
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: '홈',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.forum),
                label: '채팅',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard),
                label: '스탯',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shield),
                label: '팀',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
