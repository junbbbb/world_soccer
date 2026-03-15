import 'package:flutter/material.dart';

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  static const _totalSlots = 18;
  static const _dummyPlayers = [
    (name: '이병준', number: '7'),
    (name: '성준혁', number: '10'),
    (name: '정범석', number: '8'),
    (name: '김효진', number: '11'),
    (name: '유상훈', number: '1'),
  ];

  @override
  Widget build(BuildContext context) {
    final joined = _dummyPlayers.length;
    final remaining = _totalSlots - joined;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          const Text(
            '참가현황',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333D4B),
            ),
          ),
          const SizedBox(height: 8),
          // Count + remaining
          Text(
            '$joined/$_totalSlots명 · $remaining자리 남음',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8E97A3),
            ),
          ),
          const SizedBox(height: 20),
          // Stacked avatars
          Row(
            children: [
              SizedBox(
                width: 22.0 * joined + 10,
                height: 32,
                child: Stack(
                  children: List.generate(joined, (i) {
                    return Positioned(
                      left: i * 22.0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D6DB),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _dummyPlayers[i].name.substring(0, 1),
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _dummyPlayers.map((p) => p.name).take(2).join(', ') +
                      (joined > 2 ? ' 외 ${joined - 2}명' : ''),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7684),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 용병초대 Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                '용병초대',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F4F6),
                foregroundColor: const Color(0xFF333D4B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
