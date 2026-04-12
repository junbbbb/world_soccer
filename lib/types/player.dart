/// 선수 모델.

import 'enums.dart';

/// 이름에서 이니셜 추출 (Player, LineupMember 공용).
String initialsFrom(String name) {
  if (name.isEmpty) return '?';
  return name.substring(0, 1);
}

/// 선수(= auth.users와 1:1) 모델.
class Player {
  final String id; // = auth.uid (uuid)
  final String name;
  final int? number;
  final String? avatarUrl;
  final List<Position> preferredPositions;
  final PreferredFoot? preferredFoot;
  final int? height;
  final DateTime createdAt;

  const Player({
    required this.id,
    required this.name,
    this.number,
    this.avatarUrl,
    this.preferredPositions = const [],
    this.preferredFoot,
    this.height,
    required this.createdAt,
  });

  Player copyWith({
    String? name,
    int? number,
    String? avatarUrl,
    List<Position>? preferredPositions,
    PreferredFoot? preferredFoot,
    int? height,
  }) {
    return Player(
      id: id,
      name: name ?? this.name,
      number: number ?? this.number,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      preferredPositions: preferredPositions ?? this.preferredPositions,
      preferredFoot: preferredFoot ?? this.preferredFoot,
      height: height ?? this.height,
      createdAt: createdAt,
    );
  }

  String get initials => initialsFrom(name);
}

/// 라인업 빌더에서 사용하는 경량 멤버 모델.
class LineupMember {
  final String id;
  final String name;
  final PositionGroup preferredPosition;
  final int? number;
  final String? avatarPath;
  final bool isMercenary;

  const LineupMember({
    required this.id,
    required this.name,
    required this.preferredPosition,
    this.number,
    this.avatarPath,
    this.isMercenary = false,
  });

  LineupMember copyWith({
    String? id,
    String? name,
    PositionGroup? preferredPosition,
    int? number,
    String? avatarPath,
    bool? isMercenary,
  }) {
    return LineupMember(
      id: id ?? this.id,
      name: name ?? this.name,
      preferredPosition: preferredPosition ?? this.preferredPosition,
      number: number ?? this.number,
      avatarPath: avatarPath ?? this.avatarPath,
      isMercenary: isMercenary ?? this.isMercenary,
    );
  }

  String get initials => initialsFrom(name);
}
