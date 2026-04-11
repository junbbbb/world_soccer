import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 라인업 빌더 도메인 색상 + 공정성 상태 매핑.
///
/// "절제됨 속 여백" 원칙: 메인 컬러는 textPrimary / textTertiary / primary
/// 세 가지로만. 경고 색(주황·빨강) 사용 안 함.
class LineupColors {
  LineupColors._();

  // ── 피치 ──
  /// 피치 배경. 흰 본문에서 살짝 회색 톤으로 분리.
  static const pitchBackground = AppColors.surfaceLight;

  /// 피치 라인. 매우 옅게.
  static const pitchLine = Color(0x14333D4B); // textPrimary alpha ~8%

  // ── 공정성 (출전 쿼터 수 기반) ──
  /// 적정(2~3쿼터). 유일한 채도 있는 색.
  static const fairOk = AppColors.primary;

  /// 부족(1쿼터) — 모노톤.
  static const fairWarn = AppColors.textTertiary;

  /// 미배정(0쿼터) — 강조이지만 모노톤(검정 톤).
  static const fairBad = AppColors.textPrimary;

  /// 풀출전(4쿼터) — 모노톤.
  static const fairFull = AppColors.textTertiary;
}

/// 한 선수의 출전 쿼터 수에 따른 공정성 상태.
enum FairnessStatus {
  unassigned, // 0쿼
  under, //      1쿼
  ok, //         2~3쿼
  full, //       4쿼
}

extension FairnessStatusX on FairnessStatus {
  Color get color {
    switch (this) {
      case FairnessStatus.unassigned:
        return LineupColors.fairBad;
      case FairnessStatus.under:
        return LineupColors.fairWarn;
      case FairnessStatus.ok:
        return LineupColors.fairOk;
      case FairnessStatus.full:
        return LineupColors.fairFull;
    }
  }
}

/// 출전 쿼터 수 → 공정성 상태.
FairnessStatus fairnessOf(int playCount) {
  if (playCount <= 0) return FairnessStatus.unassigned;
  if (playCount == 1) return FairnessStatus.under;
  if (playCount >= 4) return FairnessStatus.full;
  return FairnessStatus.ok;
}

/// 포지션 4종류.
const lineupPositions = ['GK', 'DF', 'MF', 'FW'];
