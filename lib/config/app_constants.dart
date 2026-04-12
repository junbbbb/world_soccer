/// 앱 전역 상수.

import '../types/enums.dart';
import '../types/lineup.dart';

/// 세부 포지션 라벨 목록 (UI 표시용).
final allPositionLabels = Position.values.map((p) => p.label).toList();

/// 포지션 그룹 라벨 목록 (라인업 빌더용).
final lineupPositionLabels =
    PositionGroup.values.map((g) => g.label).toList();

/// 시즌 기준: 상반기 1~6월, 하반기 7~12월.
const seasonFirstHalfEnd = 6;

/// 최대 쿼터 수.
const maxQuarters = 4;

/// 기본 최대 참가자 수.
const defaultMaxParticipants = 16;

/// 사용 가능한 포메이션 (11인제).
const defaultFormations = <Formation>[
  Formation(
    name: '4-4-2',
    slots: [
      SlotPosition(0.50, 0.92, PositionGroup.gk),
      SlotPosition(0.15, 0.72, PositionGroup.df),
      SlotPosition(0.38, 0.72, PositionGroup.df),
      SlotPosition(0.62, 0.72, PositionGroup.df),
      SlotPosition(0.85, 0.72, PositionGroup.df),
      SlotPosition(0.15, 0.50, PositionGroup.mf),
      SlotPosition(0.38, 0.50, PositionGroup.mf),
      SlotPosition(0.62, 0.50, PositionGroup.mf),
      SlotPosition(0.85, 0.50, PositionGroup.mf),
      SlotPosition(0.35, 0.25, PositionGroup.fw),
      SlotPosition(0.65, 0.25, PositionGroup.fw),
    ],
  ),
  Formation(
    name: '4-3-3',
    slots: [
      SlotPosition(0.50, 0.92, PositionGroup.gk),
      SlotPosition(0.15, 0.72, PositionGroup.df),
      SlotPosition(0.38, 0.72, PositionGroup.df),
      SlotPosition(0.62, 0.72, PositionGroup.df),
      SlotPosition(0.85, 0.72, PositionGroup.df),
      SlotPosition(0.25, 0.50, PositionGroup.mf),
      SlotPosition(0.50, 0.50, PositionGroup.mf),
      SlotPosition(0.75, 0.50, PositionGroup.mf),
      SlotPosition(0.18, 0.25, PositionGroup.fw),
      SlotPosition(0.50, 0.20, PositionGroup.fw),
      SlotPosition(0.82, 0.25, PositionGroup.fw),
    ],
  ),
  Formation(
    name: '3-5-2',
    slots: [
      SlotPosition(0.50, 0.92, PositionGroup.gk),
      SlotPosition(0.25, 0.72, PositionGroup.df),
      SlotPosition(0.50, 0.72, PositionGroup.df),
      SlotPosition(0.75, 0.72, PositionGroup.df),
      SlotPosition(0.10, 0.50, PositionGroup.mf),
      SlotPosition(0.30, 0.55, PositionGroup.mf),
      SlotPosition(0.50, 0.50, PositionGroup.mf),
      SlotPosition(0.70, 0.55, PositionGroup.mf),
      SlotPosition(0.90, 0.50, PositionGroup.mf),
      SlotPosition(0.35, 0.25, PositionGroup.fw),
      SlotPosition(0.65, 0.25, PositionGroup.fw),
    ],
  ),
  Formation(
    name: '5-3-2',
    slots: [
      SlotPosition(0.50, 0.92, PositionGroup.gk),
      SlotPosition(0.10, 0.72, PositionGroup.df),
      SlotPosition(0.30, 0.75, PositionGroup.df),
      SlotPosition(0.50, 0.78, PositionGroup.df),
      SlotPosition(0.70, 0.75, PositionGroup.df),
      SlotPosition(0.90, 0.72, PositionGroup.df),
      SlotPosition(0.25, 0.50, PositionGroup.mf),
      SlotPosition(0.50, 0.50, PositionGroup.mf),
      SlotPosition(0.75, 0.50, PositionGroup.mf),
      SlotPosition(0.35, 0.25, PositionGroup.fw),
      SlotPosition(0.65, 0.25, PositionGroup.fw),
    ],
  ),
];
