import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

// ── 더미 참가자 데이터 (참가 확인에서 자동 로드된 것으로 가정) ──

class _Player {
  final String name;
  final String position;
  final int number;
  final String avatarPath;

  const _Player({
    required this.name,
    required this.position,
    required this.number,
    required this.avatarPath,
  });
}

/// 참가 확인 완료된 선수 목록 (자동 로드)
const _participants = [
  _Player(name: '박서준', position: 'GK', number: 1, avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif'),
  _Player(name: '윤태경', position: 'DF', number: 2, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '정도현', position: 'DF', number: 4, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '김재윤', position: 'DF', number: 5, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '이병준', position: 'MF', number: 7, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '최민수', position: 'MF', number: 8, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '김태호', position: 'FW', number: 9, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Player(name: '윤서준', position: 'MF', number: 10, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '박정우', position: 'FW', number: 11, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Player(name: '강지훈', position: 'MF', number: 14, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '이현우', position: 'DF', number: 15, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
  _Player(name: '조원빈', position: 'MF', number: 16, avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif'),
  _Player(name: '신유찬', position: 'FW', number: 17, avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif'),
  _Player(name: '한준혁', position: 'GK', number: 21, avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif'),
  _Player(name: '송민호', position: 'DF', number: 23, avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif'),
];

// ── 골/어시 기록 ──

class _StatEntry {
  int goals;
  int assists;

  _StatEntry({this.goals = 0, this.assists = 0});
}

// ── 메인 화면 (2단계: 스코어 → 골/어시) ──

class MatchResultInputScreen extends StatefulWidget {
  const MatchResultInputScreen({super.key});

  @override
  State<MatchResultInputScreen> createState() => _MatchResultInputScreenState();
}

class _MatchResultInputScreenState extends State<MatchResultInputScreen> {
  int _currentStep = 0;
  static const _totalSteps = 2;

  // Step 1: 스코어
  int _ourScore = 0;
  int _opponentScore = 0;
  String _opponentName = 'FC쏘아';

  // Step 2: 골/어시 (참가자 자동 로드)
  final Map<int, _StatEntry> _playerStats = {};

  static const _stepLabels = ['스코어', '기록'];

  void _next() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _onSave() {
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
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isLastStep = _currentStep == _totalSteps - 1;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.only(top: topPadding),
              color: Colors.white,
              child: Column(
                children: [
                  SizedBox(
                    height: 56,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: _back,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.base),
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textPrimary),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            '경기 결과 입력',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 52),
                      ],
                    ),
                  ),
                  // 스텝 인디케이터
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
                    child: _StepIndicator(
                      currentStep: _currentStep,
                      totalSteps: _totalSteps,
                      labels: _stepLabels,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            // 콘텐츠
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _currentStep == 0
                    ? _ScoreStep(
                        key: const ValueKey('score'),
                        ourScore: _ourScore,
                        opponentScore: _opponentScore,
                        opponentName: _opponentName,
                        onOurScoreChanged: (v) => setState(() => _ourScore = v),
                        onOpponentScoreChanged: (v) => setState(() => _opponentScore = v),
                        onOpponentNameChanged: (v) => setState(() => _opponentName = v),
                      )
                    : _StatsStep(
                        key: const ValueKey('stats'),
                        playerStats: _playerStats,
                        onStatsChanged: () => setState(() {}),
                      ),
              ),
            ),
            // 하단 버튼
            Container(
              padding: EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.base, AppSpacing.xl, bottomPadding + AppSpacing.base),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.surface)),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: GestureDetector(
                  onTap: isLastStep ? _onSave : _next,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: AppColors.primary,
                      shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothButton),
                    ),
                    child: Text(
                      isLastStep ? '저장하기' : '다음',
                      style: AppTextStyles.buttonPrimary.copyWith(color: Colors.white),
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

// ── 스텝 인디케이터 (2단계) ──

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.labels,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          final stepBefore = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepBefore < currentStep ? AppColors.primary : AppColors.surface,
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isActive = stepIndex <= currentStep;
        final isCurrent = stepIndex == currentStep;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.surface,
                shape: BoxShape.circle,
                border: isCurrent
                    ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3)
                    : null,
              ),
              child: Text(
                '${stepIndex + 1}',
                style: AppTextStyles.captionBold.copyWith(
                  color: isActive ? Colors.white : AppColors.textTertiary,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              labels[stepIndex],
              style: AppTextStyles.caption.copyWith(
                color: isCurrent ? AppColors.primary : AppColors.textTertiary,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Step 1: 스코어 입력 ──

class _ScoreStep extends StatelessWidget {
  const _ScoreStep({
    super.key,
    required this.ourScore,
    required this.opponentScore,
    required this.opponentName,
    required this.onOurScoreChanged,
    required this.onOpponentScoreChanged,
    required this.onOpponentNameChanged,
  });

  final int ourScore;
  final int opponentScore;
  final String opponentName;
  final ValueChanged<int> onOurScoreChanged;
  final ValueChanged<int> onOpponentScoreChanged;
  final ValueChanged<String> onOpponentNameChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
      child: Column(
        children: [
          Text(
            '경기 스코어를 입력해주세요',
            style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          // 스코어 보드
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: ShapeDecoration(
              color: AppColors.surfaceLight,
              shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothLg),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _TeamScoreColumn(
                    teamLogo: 'assets/images/logo_calo.png',
                    teamName: 'FC칼로',
                    score: ourScore,
                    onScoreChanged: onOurScoreChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                  child: Text(
                    ':',
                    style: AppTextStyles.timeDisplay.copyWith(color: AppColors.textTertiary, fontSize: 40),
                  ),
                ),
                Expanded(
                  child: _TeamScoreColumn(
                    teamLogo: 'assets/images/logo_ssoa.png',
                    teamName: opponentName,
                    score: opponentScore,
                    onScoreChanged: onOpponentScoreChanged,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          // 상대팀 선택
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: ShapeDecoration(
              color: AppColors.surfaceLight,
              shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('상대팀', style: AppTextStyles.captionMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: ['FC쏘아', '올스타FC', '드림FC'].map((name) {
                    final selected = opponentName == name;
                    return GestureDetector(
                      onTap: () => onOpponentNameChanged(name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: ShapeDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          shape: SmoothRectangleBorder(
                            borderRadius: AppRadius.smoothSm,
                            side: BorderSide(
                              color: selected ? AppColors.primary : AppColors.iconInactive,
                            ),
                          ),
                        ),
                        child: Text(
                          name,
                          style: AppTextStyles.labelRegular.copyWith(
                            color: selected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamScoreColumn extends StatelessWidget {
  const _TeamScoreColumn({
    required this.teamLogo,
    required this.teamName,
    required this.score,
    required this.onScoreChanged,
  });

  final String teamLogo;
  final String teamName;
  final int score;
  final ValueChanged<int> onScoreChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipSmoothRect(
          radius: AppRadius.smoothSm,
          child: Image.asset(teamLogo, width: 48, height: 48, fit: BoxFit.cover),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          teamName,
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.base),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ScoreButton(
              icon: Icons.remove_rounded,
              onTap: score > 0 ? () => onScoreChanged(score - 1) : null,
            ),
            SizedBox(
              width: 48,
              child: Text(
                '$score',
                textAlign: TextAlign.center,
                style: AppTextStyles.timeDisplay.copyWith(color: AppColors.textPrimary, fontSize: 36),
              ),
            ),
            _ScoreButton(
              icon: Icons.add_rounded,
              onTap: () => onScoreChanged(score + 1),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.primary : AppColors.surface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: enabled ? Colors.white : AppColors.iconInactive),
      ),
    );
  }
}

// ── Step 2: 골/어시스트 입력 (참가자 자동 로드) ──

class _StatsStep extends StatelessWidget {
  const _StatsStep({
    super.key,
    required this.playerStats,
    required this.onStatsChanged,
  });

  final Map<int, _StatEntry> playerStats;
  final VoidCallback onStatsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            '골과 어시스트를 기록해주세요',
            style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            '참가자 ${_participants.length}명 · 해당 없으면 그냥 넘어가세요',
            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
          ),
        ),
        const SizedBox(height: AppSpacing.base),
        // 헤더
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Row(
            children: [
              const Expanded(child: SizedBox()),
              SizedBox(
                width: 80,
                child: Text('골', textAlign: TextAlign.center, style: AppTextStyles.captionBold.copyWith(color: AppColors.textSecondary)),
              ),
              SizedBox(
                width: 80,
                child: Text('어시스트', textAlign: TextAlign.center, style: AppTextStyles.captionBold.copyWith(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            itemCount: _participants.length,
            itemBuilder: (context, i) {
              final player = _participants[i];
              final stats = playerStats.putIfAbsent(i, () => _StatEntry());

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ClipSmoothRect(
                      radius: AppRadius.smoothSm,
                      child: Image.asset(player.avatarPath, width: 32, height: 32, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(player.name, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary)),
                          Text(
                            '${player.position} · #${player.number}',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    _MiniCounter(
                      value: stats.goals,
                      onChanged: (v) {
                        stats.goals = v;
                        onStatsChanged();
                      },
                    ),
                    const SizedBox(width: AppSpacing.base),
                    _MiniCounter(
                      value: stats.assists,
                      onChanged: (v) {
                        stats.assists = v;
                        onStatsChanged();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniCounter extends StatelessWidget {
  const _MiniCounter({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 32,
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: SmoothRectangleBorder(borderRadius: AppRadius.smoothFull),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: value > 0
                ? () {
                    HapticFeedback.lightImpact();
                    onChanged(value - 1);
                  }
                : null,
            child: Icon(Icons.remove_rounded, size: 16, color: value > 0 ? AppColors.textSecondary : AppColors.iconInactive),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(color: value > 0 ? AppColors.primary : AppColors.textTertiary),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onChanged(value + 1);
            },
            child: const Icon(Icons.add_rounded, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
