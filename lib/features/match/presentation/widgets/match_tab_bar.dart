import 'package:flutter/material.dart';

class MatchTabBar extends StatelessWidget {
  const MatchTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 24),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: const Color(0xFF333D4B),
          unselectedLabelColor: const Color(0xFF8E97A3),
          labelStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          indicator: BoxDecoration(
            color: const Color(0xFFF2F4F6),
            borderRadius: BorderRadius.circular(100),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: -6, vertical: 2),
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          dividerHeight: 0,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(height: 48, text: '경기정보'),
            Tab(height: 48, text: '상대전적'),
            Tab(height: 48, text: '스탯'),
          ],
        ),
      ),
    );
  }
}
