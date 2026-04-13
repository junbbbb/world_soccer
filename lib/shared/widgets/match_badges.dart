import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../types/enums.dart';
import '../../types/match.dart';
import 'info_capsule.dart';

/// 경기 상태 기반 배지 목록 생성 (홈 카드 + 경기 상세 공용).
List<Widget> buildMatchBadges(List<Match> allMatches, Match? match) {
  if (match == null) return [];
  final badges = <Widget>[];

  // 상태 배지
  switch (match.displayState) {
    case MatchDisplayState.ended:
    case MatchDisplayState.earlyEnded:
      badges.add(const InfoCapsule(text: '경기 종료'));
    case MatchDisplayState.inProgress:
      badges.add(const InfoCapsule(text: '진행 중'));
    case MatchDisplayState.cancelled:
      badges.add(const InfoCapsule(text: '취소'));
    case MatchDisplayState.completed:
      badges.add(const InfoCapsule(text: '완료'));
    case MatchDisplayState.upcoming:
      // TODO: 실제 참가 인원 연동 시 교체
      badges.add(const InfoCapsule(text: '0/16명'));
  }

  // 상대팀 전적 배지
  final pastVs = allMatches
      .where((m) =>
          m.status == MatchStatus.completed &&
          m.opponentName == match.opponentName)
      .toList();

  if (pastVs.isEmpty) {
    badges.add(const InfoCapsule(text: '첫 매치'));
  } else {
    pastVs.sort((a, b) => b.date.compareTo(a.date));
    final lastResult = pastVs.first.result;
    if (lastResult != null) {
      if (lastResult == MatchResult.loss) {
        badges.add(const InfoCapsule(text: '리벤지 매치'));
      } else if (lastResult == MatchResult.win) {
        badges.add(const InfoCapsule(text: '연승 도전'));
      } else {
        badges.add(const InfoCapsule(text: '재대결'));
      }
    }
  }

  // 사이에 간격 삽입
  if (badges.isEmpty) return [];
  return badges
      .expand((w) => [w, const SizedBox(width: AppSpacing.sm)])
      .toList()
    ..removeLast();
}
