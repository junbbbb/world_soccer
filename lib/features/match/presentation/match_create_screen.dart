import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../runtime/providers.dart';

/// 펼쳐진 인라인 피커 — 현재는 날짜 캘린더만 사용.
enum _ExpandedField { none, date }

class MatchCreateScreen extends ConsumerStatefulWidget {
  const MatchCreateScreen({super.key});

  @override
  ConsumerState<MatchCreateScreen> createState() => _MatchCreateScreenState();
}

class _MatchCreateScreenState extends ConsumerState<MatchCreateScreen> {
  // ── 날짜 & 시간 ──
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  // 경기 시간: 시작 + 길이 (종료는 자동 계산되는 파생 정보)
  // 진짜 결정은 1개(시작), 길이는 거의 항상 90분이라 보조 결정.
  TimeOfDay _startTime = const TimeOfDay(hour: 20, minute: 0);
  int _durationMinutes = 90;

  // ── 펼침 상태 (날짜 캘린더만 인라인) ──
  _ExpandedField _expanded = _ExpandedField.none;

  // ── 장소 (최근 장소) ──
  String _selectedLocation = '성내유수지';
  final List<String> _locations = ['성내유수지', '잠실축구장', '올림픽공원'];
  final _newLocationController = TextEditingController();
  bool _showLocationAdd = false;

  // ── 상대팀 (최근 상대팀) ──
  // 미정 / 칩 선택 / 직접 입력 — 셋 중 하나의 상태.
  // 기본값은 '미정' (아직 매칭 전인 일정도 만들 수 있도록).
  String _selectedOpponent = '';
  final List<String> _opponents = ['FC쏘아', '올스타FC', '드림FC'];
  final _customOpponentController = TextEditingController();
  bool _useCustomOpponent = false;
  bool _isOpponentTbd = true;

  // ── 참가 인원 ──
  int _maxParticipants = 16;

  @override
  void dispose() {
    _newLocationController.dispose();
    _customOpponentController.dispose();
    super.dispose();
  }

  // ── 헬퍼 ──

  DateTime get _todayMidnight {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool get _canSave {
    if (_selectedLocation.isEmpty) return false;
    if (_isOpponentTbd) return true;
    final hasOpponent = _useCustomOpponent
        ? _customOpponentController.text.trim().isNotEmpty
        : _selectedOpponent.isNotEmpty;
    return hasOpponent;
  }

  String _formatDate(DateTime d) {
    const wds = ['월', '화', '수', '목', '금', '토', '일'];
    return '${d.year}년 ${d.month}월 ${d.day}일 (${wds[d.weekday - 1]})';
  }

  String get _dateLabel => _formatDate(_selectedDate);

  /// 정시는 "오후 8시", 30분은 "오후 8:30" — 정시일 때 더 짧게.
  String _formatTime(TimeOfDay t) {
    final h = t.hour % 24;
    final m = t.minute;
    final period = h < 12 ? '오전' : '오후';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    if (m == 0) return '$period $hour시';
    return '$period $hour:${m.toString().padLeft(2, '0')}';
  }

  TimeOfDay _computeEndTime(TimeOfDay start, int durationMinutes) {
    final total = start.hour * 60 + start.minute + durationMinutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  String get _timeRangeLabel {
    final end = _computeEndTime(_startTime, _durationMinutes);
    return '${_formatTime(_startTime)} ~ ${_formatTime(end)}';
  }

  // ── 핸들러 ──

  void _toggleExpanded(_ExpandedField field) {
    HapticFeedback.selectionClick();
    setState(() {
      _expanded = (_expanded == field) ? _ExpandedField.none : field;
    });
  }

  void _onDateChanged(DateTime newDate) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedDate = newDate;
      _expanded = _ExpandedField.none;
    });
  }

  /// 펼쳐진 인라인 피커가 있으면 접는다.
  /// (스크롤 / 외부 영역 탭 등 사용자 의도가 명확한 시점에서 호출)
  void _collapseExpanded() {
    if (_expanded == _ExpandedField.none) return;
    setState(() => _expanded = _ExpandedField.none);
  }

  Future<void> _openTimeSheet() async {
    HapticFeedback.selectionClick();
    _collapseExpanded();
    final result = await showModalBottomSheet<(TimeOfDay, int)>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TimeSheet(
        initialStart: _startTime,
        initialDurationMinutes: _durationMinutes,
      ),
    );
    if (result != null) {
      setState(() {
        _startTime = result.$1;
        _durationMinutes = result.$2;
      });
    }
  }

  void _addLocation() {
    final name = _newLocationController.text.trim();
    if (name.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() {
      _locations.add(name);
      _selectedLocation = name;
      _newLocationController.clear();
      _showLocationAdd = false;
    });
  }

  Future<void> _save() async {
    HapticFeedback.mediumImpact();

    // 팀 ID 가져오기
    final teamId = await ref.read(currentTeamIdProvider.future);
    if (teamId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('팀 정보를 찾을 수 없습니다'),
          behavior: SnackBarBehavior.floating,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
        ),
      );
      return;
    }

    // 날짜 + 시간 합치기
    final matchDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _startTime.hour,
      _startTime.minute,
    );

    // 상대팀 이름
    final opponent = _isOpponentTbd
        ? '미정'
        : _useCustomOpponent
            ? _customOpponentController.text.trim()
            : _selectedOpponent;

    try {
      final matchRepo = ref.read(matchRepoProvider);
      await matchRepo.create(
        teamId: teamId,
        date: matchDate,
        location: _selectedLocation,
        opponentName: opponent,
      );

      // 경기 목록 캐시 갱신
      ref.invalidate(teamMatchesProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('경기 일정이 생성되었습니다'),
          behavior: SnackBarBehavior.floating,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장 실패: $e'),
          behavior: SnackBarBehavior.floating,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
        ),
      );
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // ── 헤더 ──
            Container(
              padding: EdgeInsets.only(top: topPadding),
              color: Colors.white,
              child: SizedBox(
                height: 56,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '경기 일정 만들기',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 52),
                  ],
                ),
              ),
            ),

            // ── 본문 ──
            // C: 빈 영역 탭 → 펼쳐진 피커 접기 + 키보드 내림
            // B: 사용자 드래그 스크롤 시작 → 펼쳐진 피커 접기
            //    (펼침 애니메이션이 일으키는 프로그래매틱 스크롤은 dragDetails == null 이라 무시)
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _collapseExpanded();
                },
                behavior: HitTestBehavior.opaque,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollStartNotification &&
                        notification.dragDetails != null) {
                      _collapseExpanded();
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xl,
                      AppSpacing.xxxl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── 1. 날짜 및 시간 ──
                        const _SectionLabel('날짜 및 시간'),
                        const SizedBox(height: AppSpacing.sm),
                        _PickerButton(
                          icon: Icons.calendar_today_rounded,
                          label: _dateLabel,
                          isExpanded: _expanded == _ExpandedField.date,
                          onTap: () => _toggleExpanded(_ExpandedField.date),
                        ),
                        _ExpansionContainer(
                          isExpanded: _expanded == _ExpandedField.date,
                          child: _InlineCalendar(
                            initialDate: _selectedDate,
                            firstDate: _todayMidnight,
                            lastDate: _todayMidnight.add(
                              const Duration(days: 365),
                            ),
                            onChanged: _onDateChanged,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _PickerButton(
                          icon: Icons.access_time_rounded,
                          label: _timeRangeLabel,
                          isExpanded: false,
                          onTap: _openTimeSheet,
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── 2. 장소 ──
                        const _SectionLabel('장소'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            ..._locations.map(
                              (loc) => _SelectChip(
                                label: loc,
                                isSelected: _selectedLocation == loc,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedLocation = loc;
                                    _showLocationAdd = false;
                                  });
                                },
                              ),
                            ),
                            _AddChip(
                              label: '추가',
                              isOpen: _showLocationAdd,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(
                                  () => _showLocationAdd = !_showLocationAdd,
                                );
                              },
                            ),
                          ],
                        ),
                        _ExpansionContainer(
                          isExpanded: _showLocationAdd,
                          child: _AddInputRow(
                            controller: _newLocationController,
                            hintText: '새 장소 이름',
                            onSubmit: _addLocation,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── 3. 상대팀 ──
                        const _SectionLabel('상대팀'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _SelectChip(
                              label: '미정',
                              isSelected: _isOpponentTbd,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _isOpponentTbd = true;
                                  _selectedOpponent = '';
                                  _useCustomOpponent = false;
                                });
                              },
                            ),
                            ..._opponents.map(
                              (opp) => _SelectChip(
                                label: opp,
                                isSelected:
                                    !_isOpponentTbd &&
                                    !_useCustomOpponent &&
                                    _selectedOpponent == opp,
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedOpponent = opp;
                                    _useCustomOpponent = false;
                                    _isOpponentTbd = false;
                                  });
                                },
                              ),
                            ),
                            _AddChip(
                              label: '직접 입력',
                              isOpen: _useCustomOpponent,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _useCustomOpponent = !_useCustomOpponent;
                                  if (_useCustomOpponent) {
                                    _selectedOpponent = '';
                                    _isOpponentTbd = false;
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        _ExpansionContainer(
                          isExpanded: _useCustomOpponent,
                          child: _TextFieldBox(
                            controller: _customOpponentController,
                            hintText: '상대팀 이름 입력',
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // ── 4. 참가 인원 ──
                        const _SectionLabel('최대 참가 인원'),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            _CounterButton(
                              icon: Icons.remove_rounded,
                              onTap: _maxParticipants > 1
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _maxParticipants--);
                                    }
                                  : null,
                            ),
                            SizedBox(
                              width: 56,
                              child: Text(
                                '$_maxParticipants',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.sectionTitle.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            _CounterButton(
                              icon: Icons.add_rounded,
                              onTap: _maxParticipants < 30
                                  ? () {
                                      HapticFeedback.lightImpact();
                                      setState(() => _maxParticipants++);
                                    }
                                  : null,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              '명',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 하단 액션 ──
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.surface)),
              ),
              padding: EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.base,
                AppSpacing.xl,
                bottomPadding + AppSpacing.base,
              ),
              child: GestureDetector(
                onTap: _canSave ? _save : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: _canSave
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.3),
                    shape: SmoothRectangleBorder(
                      borderRadius: AppRadius.smoothButton,
                    ),
                  ),
                  child: Text(
                    '일정 만들기',
                    style: AppTextStyles.buttonPrimary.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 인라인 펼침 컨테이너 (AnimatedSize 래퍼) ──
// 펼쳐졌을 때만 child를 그리고, 위쪽에 sm 간격을 둔다.

class _ExpansionContainer extends StatelessWidget {
  const _ExpansionContainer({required this.isExpanded, required this.child});

  final bool isExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: isExpanded
            ? Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: child,
              )
            : const SizedBox(width: double.infinity),
      ),
    );
  }
}

// ── 섹션 라벨 ──

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
    );
  }
}

// ── 피커 버튼 (날짜 / 시간 / 마감일 trigger) ──
// 펼쳐졌을 때: 검정 테두리 1.5px, chevron 90도 회전.

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.isExpanded,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.base,
        ),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothSm,
            side: BorderSide(
              color: isExpanded ? AppColors.textPrimary : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 인라인 캘린더 (Material CalendarDatePicker 래퍼) ──

class _InlineCalendar extends StatelessWidget {
  const _InlineCalendar({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  DateTime get _safeInitial {
    if (initialDate.isBefore(firstDate)) return firstDate;
    if (initialDate.isAfter(lastDate)) return lastDate;
    return initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
      ),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            onSurface: AppColors.textPrimary,
            surface: AppColors.surfaceLight,
          ),
          textTheme: Theme.of(context).textTheme.apply(
            fontFamily: 'Pretendard',
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          ),
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
        ),
        child: CalendarDatePicker(
          initialDate: _safeInitial,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateChanged: onChanged,
        ),
      ),
    );
  }
}

// ── 경기 시간 모달 시트 (시작 + 길이 모델) ──
// 본질적 결정은 단 하나: "언제 시작하나"
// 길이는 거의 항상 90분이라 prefill, 조정은 칩 3개로 충분
// 종료 시간은 자동 계산되어 헤더에 정보로만 표시
//
// 레이아웃:
//   상단 핸들
//   "경기 시간"   [오후 8시 ~ 오후 9:30]
//
//        오후 7시            ← dim
//        오후 8시            ← 가운데, 큰 글자, 굵게  ← 진짜 결정
//        오후 9시            ← dim
//        (휠 형태 — 손가락으로 위/아래)
//
//   경기 길이
//   [1시간] [1시간 30분] [2시간]
//
//   ━━━━━ 확인 ━━━━━

class _TimeSheet extends StatefulWidget {
  const _TimeSheet({
    required this.initialStart,
    required this.initialDurationMinutes,
  });

  final TimeOfDay initialStart;
  final int initialDurationMinutes;

  @override
  State<_TimeSheet> createState() => _TimeSheetState();
}

class _TimeSheetState extends State<_TimeSheet> {
  // 시작 시간 슬롯: 06:00 ~ 23:00 (1시간 단위, 18개)
  static const _baseHour = 6;
  static const _slotCount = 18;
  static const _wheelItemExtent = 60.0;

  // 길이 옵션 (분 단위) — 조기축구 표준 + 1/2시간
  static const _durationOptions = [60, 90, 120];

  late TimeOfDay _start;
  late int _durationMinutes;
  late FixedExtentScrollController _wheelController;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _durationMinutes = widget.initialDurationMinutes;
    _wheelController = FixedExtentScrollController(
      initialItem: _timeToIndex(_start),
    );
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  // ── 시간 ↔ 인덱스 ──
  int _timeToIndex(TimeOfDay t) {
    return (t.hour - _baseHour).clamp(0, _slotCount - 1);
  }

  TimeOfDay _indexToTime(int index) =>
      TimeOfDay(hour: _baseHour + index, minute: 0);

  TimeOfDay get _endTime {
    final total = _start.hour * 60 + _start.minute + _durationMinutes;
    return TimeOfDay(hour: (total ~/ 60) % 24, minute: total % 60);
  }

  // ── 포맷 ──
  String _formatTime(TimeOfDay t) {
    final h = t.hour % 24;
    final m = t.minute;
    final period = h < 12 ? '오전' : '오후';
    final hour = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    if (m == 0) return '$period $hour시';
    return '$period $hour:${m.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (m == 0) return '$h시간';
    if (h == 0) return '$m분';
    return '$h시간 $m분';
  }

  // ── 핸들러 ──
  void _onWheelChanged(int index) {
    HapticFeedback.selectionClick();
    setState(() => _start = _indexToTime(index));
  }

  void _selectDuration(int minutes) {
    HapticFeedback.selectionClick();
    setState(() => _durationMinutes = minutes);
  }

  void _confirm() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop((_start, _durationMinutes));
  }

  // ── Build ──
  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1.0),
            topRight: SmoothRadius(cornerRadius: 24, cornerSmoothing: 1.0),
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 핸들
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.iconInactive,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // 제목 + 종료 시간 미리보기
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.base,
              AppSpacing.xl,
              AppSpacing.lg,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '경기 시간',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '끝: ${_formatTime(_endTime)}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // ━━ 시작 시간 휠 (본질의 핵심) ━━
          // 큰 글자, 가운데가 선택. 위/아래 dim
          // 가운데 라인은 미니멀하게 surfaceLight 박스로
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 가운데 선택 영역 표시 (얕은 surfaceLight 박스)
                IgnorePointer(
                  child: Container(
                    height: _wheelItemExtent,
                    margin: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.surfaceLight,
                      shape: SmoothRectangleBorder(
                        borderRadius: AppRadius.smoothMd,
                      ),
                    ),
                  ),
                ),
                // 휠
                ListWheelScrollView.useDelegate(
                  controller: _wheelController,
                  itemExtent: _wheelItemExtent,
                  perspective: 0.003,
                  diameterRatio: 1.8,
                  physics: const FixedExtentScrollPhysics(),
                  overAndUnderCenterOpacity: 0.35,
                  onSelectedItemChanged: _onWheelChanged,
                  childDelegate: ListWheelChildBuilderDelegate(
                    childCount: _slotCount,
                    builder: (context, index) {
                      final t = _indexToTime(index);
                      final isCenter = _timeToIndex(_start) == index;
                      return Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 180),
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: isCenter ? 32 : 24,
                            fontWeight: isCenter
                                ? FontWeight.w800
                                : FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          child: Text(_formatTime(t)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ━━ 경기 길이 (보조 결정) ━━
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '경기 길이',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    for (int i = 0; i < _durationOptions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _DurationChip(
                          label: _formatDuration(_durationOptions[i]),
                          isSelected: _durationMinutes == _durationOptions[i],
                          onTap: () => _selectDuration(_durationOptions[i]),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 확인 CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.base,
            ),
            child: GestureDetector(
              onTap: _confirm,
              child: Container(
                width: double.infinity,
                height: 52,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: AppColors.textPrimary,
                  shape: SmoothRectangleBorder(
                    borderRadius: AppRadius.smoothButton,
                  ),
                ),
                child: Text(
                  '확인',
                  style: AppTextStyles.buttonPrimary.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 길이 칩 (1시간 / 1시간 30분 / 2시간) ──
class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 48,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.textPrimary : AppColors.surfaceLight,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ── 선택 칩 (장소 / 상대팀 후보) ──
// 선택 시: 검정 테두리 1.5px (텍스트 weight + 색만 강화)
// 비선택: surfaceLight 배경에 transparent 테두리(자리만 차지) — jitter 방지

class _SelectChip extends StatelessWidget {
  const _SelectChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 10,
        ),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothSm,
            side: BorderSide(
              color: isSelected ? AppColors.textPrimary : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── 추가 칩 (+ 추가 / + 직접 입력) ──
// 일반 선택 칩과 다른 시각언어: 배경 없는 outline-only.
// 활성(open) 상태에서 검정 테두리로 변환.

class _AddChip extends StatelessWidget {
  const _AddChip({
    required this.label,
    required this.isOpen,
    required this.onTap,
  });

  final String label;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = isOpen ? AppColors.textPrimary : AppColors.textTertiary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: 10,
        ),
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothSm,
            side: BorderSide(
              color: isOpen ? AppColors.textPrimary : AppColors.iconInactive,
              width: 1.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_rounded, size: 14, color: accent),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: accent,
                fontWeight: isOpen ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 텍스트 필드 박스 ──

class _TextFieldBox extends StatelessWidget {
  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.primary,
        style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}

// ── 텍스트 필드 + 추가 버튼 (장소 추가) ──

class _AddInputRow extends StatelessWidget {
  const _AddInputRow({
    required this.controller,
    required this.hintText,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hintText;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TextFieldBox(controller: controller, hintText: hintText),
        ),
        const SizedBox(width: AppSpacing.sm),
        GestureDetector(
          onTap: onSubmit,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: 12,
            ),
            decoration: ShapeDecoration(
              color: AppColors.textPrimary,
              shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
            ),
            child: Text(
              '추가',
              style: AppTextStyles.captionBold.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 카운터 버튼 (인원 ±) ──

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppColors.textPrimary : AppColors.iconInactive,
        ),
      ),
    );
  }
}
