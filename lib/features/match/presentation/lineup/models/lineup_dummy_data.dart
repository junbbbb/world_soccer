import 'lineup_models.dart';

/// 라인업 빌더용 더미 데이터.
///
/// 실제 데이터 연동 전까지는 여기서 16명 + 포메이션 3종을 제공.

const _avA = 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif';
const _avB = 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif';
const _avC = 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif';
const _avD = 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif';

const dummyRoster = <LineupMember>[
  LineupMember(id: '1', name: '박서준', preferredPosition: 'GK', number: 1, avatarPath: _avD),
  LineupMember(id: '21', name: '한준혁', preferredPosition: 'GK', number: 21, avatarPath: _avD),
  LineupMember(id: '2', name: '윤태경', preferredPosition: 'DF', number: 2, avatarPath: _avC),
  LineupMember(id: '4', name: '정도현', preferredPosition: 'DF', number: 4, avatarPath: _avC),
  LineupMember(id: '5', name: '김재윤', preferredPosition: 'DF', number: 5, avatarPath: _avC),
  LineupMember(id: '15', name: '이현우', preferredPosition: 'DF', number: 15, avatarPath: _avC),
  LineupMember(id: '23', name: '송민호', preferredPosition: 'DF', number: 23, avatarPath: _avC),
  LineupMember(id: '7', name: '이병준', preferredPosition: 'MF', number: 7, avatarPath: _avA),
  LineupMember(id: '8', name: '최민수', preferredPosition: 'MF', number: 8, avatarPath: _avA),
  LineupMember(id: '10', name: '윤서준', preferredPosition: 'MF', number: 10, avatarPath: _avA),
  LineupMember(id: '14', name: '강지훈', preferredPosition: 'MF', number: 14, avatarPath: _avA),
  LineupMember(id: '16', name: '조원빈', preferredPosition: 'MF', number: 16, avatarPath: _avA),
  LineupMember(id: '9', name: '김태호', preferredPosition: 'FW', number: 9, avatarPath: _avB),
  LineupMember(id: '11', name: '박정우', preferredPosition: 'FW', number: 11, avatarPath: _avB),
  LineupMember(id: '17', name: '신유찬', preferredPosition: 'FW', number: 17, avatarPath: _avB),
  LineupMember(id: '19', name: '오준영', preferredPosition: 'FW', number: 19, avatarPath: _avB),
];

/// 사용 가능한 포메이션 (11인제 기준).
const dummyFormations = <Formation>[
  Formation(
    name: '4-4-2',
    slots: [
      SlotPosition(0.50, 0.92, 'GK'),
      SlotPosition(0.15, 0.72, 'DF'),
      SlotPosition(0.38, 0.72, 'DF'),
      SlotPosition(0.62, 0.72, 'DF'),
      SlotPosition(0.85, 0.72, 'DF'),
      SlotPosition(0.15, 0.50, 'MF'),
      SlotPosition(0.38, 0.50, 'MF'),
      SlotPosition(0.62, 0.50, 'MF'),
      SlotPosition(0.85, 0.50, 'MF'),
      SlotPosition(0.35, 0.25, 'FW'),
      SlotPosition(0.65, 0.25, 'FW'),
    ],
  ),
  Formation(
    name: '4-3-3',
    slots: [
      SlotPosition(0.50, 0.92, 'GK'),
      SlotPosition(0.15, 0.72, 'DF'),
      SlotPosition(0.38, 0.72, 'DF'),
      SlotPosition(0.62, 0.72, 'DF'),
      SlotPosition(0.85, 0.72, 'DF'),
      SlotPosition(0.25, 0.50, 'MF'),
      SlotPosition(0.50, 0.50, 'MF'),
      SlotPosition(0.75, 0.50, 'MF'),
      SlotPosition(0.18, 0.25, 'FW'),
      SlotPosition(0.50, 0.20, 'FW'),
      SlotPosition(0.82, 0.25, 'FW'),
    ],
  ),
  Formation(
    name: '3-5-2',
    slots: [
      SlotPosition(0.50, 0.92, 'GK'),
      SlotPosition(0.25, 0.72, 'DF'),
      SlotPosition(0.50, 0.72, 'DF'),
      SlotPosition(0.75, 0.72, 'DF'),
      SlotPosition(0.10, 0.50, 'MF'),
      SlotPosition(0.30, 0.55, 'MF'),
      SlotPosition(0.50, 0.50, 'MF'),
      SlotPosition(0.70, 0.55, 'MF'),
      SlotPosition(0.90, 0.50, 'MF'),
      SlotPosition(0.35, 0.25, 'FW'),
      SlotPosition(0.65, 0.25, 'FW'),
    ],
  ),
  Formation(
    name: '5-3-2',
    slots: [
      SlotPosition(0.50, 0.92, 'GK'),
      SlotPosition(0.10, 0.72, 'DF'),
      SlotPosition(0.30, 0.75, 'DF'),
      SlotPosition(0.50, 0.78, 'DF'),
      SlotPosition(0.70, 0.75, 'DF'),
      SlotPosition(0.90, 0.72, 'DF'),
      SlotPosition(0.25, 0.50, 'MF'),
      SlotPosition(0.50, 0.50, 'MF'),
      SlotPosition(0.75, 0.50, 'MF'),
      SlotPosition(0.35, 0.25, 'FW'),
      SlotPosition(0.65, 0.25, 'FW'),
    ],
  ),
];
