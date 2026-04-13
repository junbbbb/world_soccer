import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../config/dev_settings.dart';
import '../../../runtime/providers.dart';

// ══════════════════════════════════════════════
// 더미 데이터
// ══════════════════════════════════════════════

const _avatarPath =
    'assets/images/avatars/profileimage.png';

const _name = '이병준';
const _position = 'MF';
const _number = 7;
const _team = 'FC칼로';
const _season = '2026 상반기';

const _appearances = 12;
const _goals = 5;
const _assists = 3;
const _mom = 2;

const _tags = <({String label, Color bg, Color fg})>[
  (label: '출석왕', bg: Color(0xFFFFF3E0), fg: Color(0xFFE65100)),
  (label: '득점 2위', bg: Color(0xFFE3F2FD), fg: Color(0xFF1565C0)),
  (label: '어시왕', bg: Color(0xFFE8F5E9), fg: Color(0xFF2E7D32)),
  (label: 'MOM 2회', bg: Color(0xFFFCE4EC), fg: Color(0xFFC62828)),
];

const _recentPerformances = <_PerfData>[
  _PerfData(opponent: 'FC쏘아', logo: 'assets/images/logo_ssoa.png', date: '3/14 토', goals: 1, assists: 1, isMom: true),
  _PerfData(opponent: '올스타FC', logo: 'assets/images/logo_ssoa.png', date: '3/7 토', goals: 0, assists: 0, isMom: false),
  _PerfData(opponent: 'FC쏘아', logo: 'assets/images/logo_ssoa.png', date: '2/21 토', goals: 2, assists: 0, isMom: true),
  _PerfData(opponent: '올스타FC', logo: 'assets/images/logo_ssoa.png', date: '2/7 토', goals: 1, assists: 1, isMom: false),
  _PerfData(opponent: 'FC쏘아', logo: 'assets/images/logo_ssoa.png', date: '1/18 토', goals: 1, assists: 0, isMom: false),
];

class _PerfData {
  final String opponent;
  final String logo;
  final String date;
  final int goals;
  final int assists;
  final bool isMom;
  const _PerfData({
    required this.opponent,
    required this.logo,
    required this.date,
    required this.goals,
    required this.assists,
    required this.isMom,
  });
}

// ══════════════════════════════════════════════
// ProfileScreen
// ══════════════════════════════════════════════

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomPadding + AppSpacing.xxl),
            child: Column(
              children: [
                // 헤더
                const _Header(),
                const SizedBox(height: AppSpacing.sm),

                // 프로필 카드 (이름+이미지+데이터+태그)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: _ProfileCard(),
                ),

                // 피지컬 정보
                const SizedBox(height: AppSpacing.xl),
                const _PhysicalInfo(),

                // 최근 경기 (스크롤 아래)
                const SizedBox(height: AppSpacing.xxxl),
                const _RecentSection(),

                // 개발 설정
                const SizedBox(height: AppSpacing.xxxl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.base,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.surfaceLight,
                      shape: SmoothRectangleBorder(
                        borderRadius: AppRadius.smoothMd,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '더미 데이터 표시',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Switch.adaptive(
                          value: ref.watch(showDummyDataProvider),
                          activeColor: AppColors.primary,
                          onChanged: (v) {
                            ref.read(showDummyDataProvider.notifier).toggle(v);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // 로그아웃
                const SizedBox(height: AppSpacing.base),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        await ref.read(authRepoProvider).signOut();
                        if (context.mounted) context.go('/auth');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                        decoration: ShapeDecoration(
                          color: AppColors.surfaceLight,
                          shape: SmoothRectangleBorder(
                            borderRadius: AppRadius.smoothButton,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '로그아웃',
                          style: AppTextStyles.buttonSecondary.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Header
// ══════════════════════════════════════════════

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _openEdit(context),
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(
                Icons.settings_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('프로필 공유 (준비중)'),
                  shape: SmoothRectangleBorder(
                    borderRadius: AppRadius.smoothMd,
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: Icon(
                Icons.ios_share_rounded,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void _openEdit(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const _EditProfileScreen(),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Edit Profile Sheet
// ══════════════════════════════════════════════

const _allPositions = [
  'GK', 'LB', 'CB', 'RB',
  'DM', 'CM', 'AM',
  'LW', 'ST', 'RW',
];

class _EditProfileScreen extends StatefulWidget {
  const _EditProfileScreen();

  @override
  State<_EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<_EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _heightCtrl;
  final Set<String> _selectedPositions = {'CM'};
  String _foot = '오른발';

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: _name);
    _numberCtrl = TextEditingController(text: '$_number');
    _heightCtrl = TextEditingController(text: '175');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  void _togglePosition(String p) {
    setState(() {
      if (_selectedPositions.contains(p)) {
        _selectedPositions.remove(p);
      } else {
        _selectedPositions.add(p);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final canSave = _selectedPositions.isNotEmpty &&
        _nameCtrl.text.trim().isNotEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // 헤더
              SizedBox(
                height: 52,
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
                      child: Center(
                        child: Text(
                          '프로필 편집',
                          style: AppTextStyles.heading.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 52),
                  ],
                ),
              ),

              // 폼 스크롤
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),

                  // 프로필 이미지
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 이미지 피커
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('이미지 변경 (준비중)'),
                            shape: SmoothRectangleBorder(
                              borderRadius: AppRadius.smoothMd,
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          const ClipOval(
                            child: Image(
                              image: AssetImage(_avatarPath),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.textPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // 이름
                  const _FieldLabel('이름'),
                  const SizedBox(height: AppSpacing.sm),
                  _InputField(
                    controller: _nameCtrl,
                    hint: '이름을 입력해주세요',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 등번호
                  const _FieldLabel('등번호'),
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: 100,
                    child: _InputField(
                      controller: _numberCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 선호 포지션
                  const _FieldLabel('선호 포지션'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final p in _allPositions)
                        _PositionPill(
                          label: p,
                          isSelected: _selectedPositions.contains(p),
                          onTap: () => _togglePosition(p),
                        ),
                    ],
                  ),
                  if (_selectedPositions.isEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '최소 1개 이상 선택해주세요',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),

                  // 주발
                  const _FieldLabel('주발'),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final f in ['왼발', '오른발', '양발'])
                        _PositionPill(
                          label: f,
                          isSelected: _foot == f,
                          onTap: () => setState(() => _foot = f),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // 키
                  const _FieldLabel('키'),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: _InputField(
                          controller: _heightCtrl,
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'cm',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),

            ],
          ),
        ),
        // 저장 버튼 (고정 하단)
        bottomNavigationBar: Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            bottomPadding + AppSpacing.sm,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canSave
                  ? () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothButton,
                ),
              ),
              child: const Text(
                '저장',
                style: AppTextStyles.buttonPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.captionMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.keyboardType,
    this.hint,
    this.maxLength,
    this.onChanged,
  });

  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hint;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
      ),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLength: maxLength,
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
          ),
          hintText: hint,
          hintStyle: AppTextStyles.body.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
        style: AppTextStyles.body.copyWith(
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PositionPill extends StatelessWidget {
  const _PositionPill({
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
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: ShapeDecoration(
          color: AppColors.surfaceLight,
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothFull,
            side: BorderSide(
              color: isSelected ? AppColors.textPrimary : Colors.transparent,
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.captionBold.copyWith(
            color: isSelected
                ? AppColors.textPrimary
                : AppColors.textTertiary,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Physical Info — 카드 밖, 가벼운 정보 행
// ══════════════════════════════════════════════

class _PhysicalInfo extends StatelessWidget {
  const _PhysicalInfo();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        decoration: ShapeDecoration(
          shape: SmoothRectangleBorder(
            borderRadius: AppRadius.smoothMd,
            side: BorderSide(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: const Row(
          children: [
            Expanded(child: _InfoItem(label: '선호 포지션', value: 'CM, AM')),
            Expanded(child: _InfoItem(label: '주발', value: '오른발')),
            Expanded(child: _InfoItem(label: '키', value: '175cm')),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════
// Profile Card — 회색 카드에 이름 + 이미지 + 데이터 통합
// ══════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothLg),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),

          // 이름
          const Text(
            _name,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // 팀 · 포지션 · 번호 · 시즌
          Text(
            '$_team · $_position · #$_number · $_season',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // 상반신 이미지
          Image.asset(
            _avatarPath,
            height: 220,
          ),

          const SizedBox(height: AppSpacing.xl),

          // 큰 숫자 4열
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _BigStat(value: '$_appearances', label: '경기'),
                _BigStat(value: '$_goals', label: '골'),
                _BigStat(value: '$_assists', label: '어시스트'),
                _BigStat(value: '$_mom', label: 'MOM'),
              ],
            ),
          ),

          // 태그
          const SizedBox(height: AppSpacing.lg),
          const _TagRow(),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.barlowCondensed(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Tags
// ══════════════════════════════════════════════

class _TagRow extends StatelessWidget {
  const _TagRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: _tags.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final tag = _tags[i];
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: ShapeDecoration(
              color: tag.bg,
              shape: SmoothRectangleBorder(
                borderRadius: AppRadius.smoothFull,
              ),
            ),
            child: Text(
              tag.label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: tag.fg,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Recent Section
// ══════════════════════════════════════════════

class _RecentSection extends StatelessWidget {
  const _RecentSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '최근 경기 기록',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.base),
          for (var i = 0; i < _recentPerformances.length; i++) ...[
            _MatchRow(match: _recentPerformances[i]),
            if (i < _recentPerformances.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothMd,
                ),
              ),
              child: const Text(
                '전체 경기 기록 보기',
                style: AppTextStyles.buttonSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});
  final _PerfData match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
      ),
      child: Row(
        children: [
          // 상대팀 로고
          ClipSmoothRect(
            radius: AppRadius.smoothXs,
            child: Image.asset(
              match.logo,
              width: 36,
              height: 36,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 상대 + 날짜
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.opponent,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  match.date,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          // MOM
          if (match.isMom) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: ShapeDecoration(
                color: AppColors.momBackground,
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothXs,
                ),
              ),
              child: Text(
                'MOM',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.momText,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          // 골/어시 숫자
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: ShapeDecoration(
              color: Colors.white,
              shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothSm),
            ),
            child: Row(
              children: [
                Text(
                  '${match.goals}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '골',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${match.assists}',
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '도움',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
