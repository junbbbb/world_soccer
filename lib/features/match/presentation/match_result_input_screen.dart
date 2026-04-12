import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

// ══════════════════════════════════════════════
// 더미 데이터
// ══════════════════════════════════════════════

class _Player {
  final String name;
  final int number;
  final String avatarPath;
  const _Player({
    required this.name,
    required this.number,
    required this.avatarPath,
  });
}

const _participants = [
  _Player(name: '박서준', number: 1, avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif'),
  _Player(name: '윤태경', number: 2, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '정도현', number: 4, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '김재윤', number: 5, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '이병준', number: 7, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '최민수', number: 8, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '김태호', number: 9, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Player(name: '윤서준', number: 10, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '박정우', number: 11, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Player(name: '강지훈', number: 14, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '이현우', number: 15, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '조원빈', number: 16, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '신유찬', number: 17, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
];

// ══════════════════════════════════════════════
// MatchResultInputScreen
//
// 한 화면에 전부. 스텝 없음.
// 위: 스코어 (큰 숫자 + -) → 아래: 선수별 골/어시 카운터
// ══════════════════════════════════════════════

class MatchResultInputScreen extends StatefulWidget {
  const MatchResultInputScreen({super.key});

  @override
  State<MatchResultInputScreen> createState() => _MatchResultInputScreenState();
}

class _MatchResultInputScreenState extends State<MatchResultInputScreen> {
  int _ourScore = 0;
  int _theirScore = 0;
  final Map<int, int> _goals = {};
  final Map<int, int> _assists = {};

  void _save() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('경기 결과가 저장되었습니다'),
        behavior: SnackBarBehavior.floating,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

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
                          '경기 결과',
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

              // 스코어 영역
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    // 우리팀
                    Expanded(
                      child: _TeamScore(
                        logo: 'assets/images/logo_calo.png',
                        name: 'FC칼로',
                        score: _ourScore,
                        onMinus: _ourScore > 0
                            ? () => setState(() => _ourScore--)
                            : null,
                        onPlus: () => setState(() => _ourScore++),
                      ),
                    ),
                    // 콜론
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: Text(
                        ':',
                        style: GoogleFonts.barlowCondensed(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                    // 상대팀
                    Expanded(
                      child: _TeamScore(
                        logo: 'assets/images/logo_ssoa.png',
                        name: 'FC쏘아',
                        score: _theirScore,
                        onMinus: _theirScore > 0
                            ? () => setState(() => _theirScore--)
                            : null,
                        onPlus: () => setState(() => _theirScore++),
                      ),
                    ),
                  ],
                ),
              ),

              // 구분
              const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.surface,
              ),

              // 선수별 기록
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.base,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      '개인 기록',
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${_participants.length}명',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // 컬럼 헤더
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    SizedBox(
                      width: 72,
                      child: Center(
                        child: Text(
                          '골',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 72,
                      child: Center(
                        child: Text(
                          '도움',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 선수 리스트
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    bottomPadding + 80,
                  ),
                  itemCount: _participants.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    thickness: 0.5,
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                  ),
                  itemBuilder: (_, i) {
                    final p = _participants[i];
                    final g = _goals[i] ?? 0;
                    final a = _assists[i] ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              p.avatarPath,
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text(
                              p.name,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _Counter(
                            value: g,
                            onChanged: (v) =>
                                setState(() => _goals[i] = v),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _Counter(
                            value: a,
                            onChanged: (v) =>
                                setState(() => _assists[i] = v),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 저장 버튼
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
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                shape: SmoothRectangleBorder(
                  borderRadius: AppRadius.smoothButton,
                ),
              ),
              child:
                  const Text('저장하기', style: AppTextStyles.buttonPrimary),
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Team Score — 로고 + 이름 + 큰 숫자 + ± 버튼
// ══════════════════════════════════════════════

class _TeamScore extends StatelessWidget {
  const _TeamScore({
    required this.logo,
    required this.name,
    required this.score,
    required this.onMinus,
    required this.onPlus,
  });

  final String logo;
  final String name;
  final int score;
  final VoidCallback? onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipSmoothRect(
          radius: AppRadius.smoothXs,
          child: Image.asset(logo, width: 36, height: 36, fit: BoxFit.cover),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          name,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          '$score',
          style: GoogleFonts.barlowCondensed(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.0,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RoundButton(
              icon: Icons.remove_rounded,
              onTap: onMinus,
            ),
            const SizedBox(width: AppSpacing.base),
            _RoundButton(
              icon: Icons.add_rounded,
              onTap: onPlus,
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: () {
        if (enabled) HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.surfaceLight : AppColors.surface,
          shape: BoxShape.circle,
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

// ══════════════════════════════════════════════
// Counter — 심플 ±  카운터 (골/도움 공용)
// ══════════════════════════════════════════════

class _Counter extends StatelessWidget {
  const _Counter({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 34,
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothFull),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: value > 0
                  ? () {
                      HapticFeedback.lightImpact();
                      onChanged(value - 1);
                    }
                  : null,
              behavior: HitTestBehavior.opaque,
              child: Icon(
                Icons.remove_rounded,
                size: 14,
                color: value > 0
                    ? AppColors.textSecondary
                    : AppColors.iconInactive,
              ),
            ),
          ),
          Text(
            '$value',
            style: AppTextStyles.label.copyWith(
              color: value > 0
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onChanged(value + 1);
              },
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.add_rounded,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
