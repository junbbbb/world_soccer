import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../config/dev_settings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/capture.dart';
import '../../../core/utils/date_format.dart';
import '../../../core/utils/snackbar.dart';
import '../../../runtime/providers.dart';
import '../../../shared/widgets/inline_spinner.dart';
import '../../../shared/widgets/team_logo_picker.dart';
import '../../../shared/widgets/team_logo_view.dart';
import '../../../types/enums.dart';
import '../../../types/player.dart';
import '../../../types/profile.dart';
import '../../../types/team.dart';
import 'widgets/crop_image_screen.dart';

const _defaultAvatarAsset = 'assets/images/avatars/profileimage.png';

String _seasonLabel() {
  final s = currentSeasonHalf();
  return '${s.year} ${s.half.label}';
}

String _positionGroupLabel(Player p) {
  if (p.preferredPositions.isEmpty) return '—';
  return p.preferredPositions.first.group.label;
}

String _positionsText(Player p) {
  if (p.preferredPositions.isEmpty) return '—';
  final labels = p.preferredPositions.map((pos) => pos.label).toList();
  if (labels.length <= 2) return labels.join(', ');
  return '${labels.take(2).join(', ')} +${labels.length - 2}';
}

const _titleStyles = <PlayerTitle, ({Color bg, Color fg})>{
  PlayerTitle.topScorer: (bg: Color(0xFFE3F2FD), fg: Color(0xFF1565C0)),
  PlayerTitle.topAssister: (bg: Color(0xFFE8F5E9), fg: Color(0xFF2E7D32)),
  PlayerTitle.topAttendance: (bg: Color(0xFFFFF3E0), fg: Color(0xFFE65100)),
  PlayerTitle.topMom: (bg: Color(0xFFFCE4EC), fg: Color(0xFFC62828)),
};

// ══════════════════════════════════════════════
// ProfileScreen
// ══════════════════════════════════════════════

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;

  Future<void> _shareCard(Player player) async {
    if (_sharing) return;
    HapticFeedback.selectionClick();
    setState(() => _sharing = true);
    try {
      final bytes = await captureWidgetAsPng(_cardKey, pixelRatio: 3);
      await Share.shareXFiles(
        [
          XFile.fromData(
            bytes,
            mimeType: 'image/png',
            name: 'profile_${player.id}.png',
          ),
        ],
        subject: '${player.name} 프로필',
        text: '${player.name} 프로필',
      );
    } catch (e) {
      if (!mounted) return;
      context.showError('공유 실패: $e');
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final playerAsync = ref.watch(currentPlayerProvider);
    final teamAsync = ref.watch(currentTeamProvider);
    final statsAsync = ref.watch(currentSeasonStatsProvider);
    final titlesAsync = ref.watch(currentPlayerTitlesProvider);
    final recentAsync = ref.watch(currentRecentPerformancesProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: playerAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  '프로필을 불러오지 못했습니다.\n$e',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            data: (player) {
              if (player == null) {
                return Center(
                  child: Text(
                    '로그인이 필요합니다',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                );
              }

              final realTeam = teamAsync.value;
              final realStats = statsAsync.value;
              final realTitles = titlesAsync.value ?? const <PlayerTitle>[];
              final realRecent =
                  recentAsync.value ?? const <RecentPerformance>[];

              // 실데이터가 비어있거나 경기 없음이면 mock 으로 대체 (캡쳐용).
              // 백엔드 호출 미변경 — UI 레이어에서만 덮어씀.
              final useMockStats =
                  realStats == null || realStats.appearances == 0;
              final team = realTeam ?? _mockTeam(player.createdAt);
              final stats = useMockStats ? _mockSeasonStats() : realStats;
              final titles =
                  realTitles.isEmpty ? _mockTitles() : realTitles;
              final recent =
                  realRecent.isEmpty ? _mockRecentPerformances() : realRecent;

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: bottomPadding + AppSpacing.xxl,
                ),
                child: Column(
                  children: [
                    _Header(
                      player: player,
                      onShare: () => _shareCard(player),
                      isSharing: _sharing,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: RepaintBoundary(
                        key: _cardKey,
                        child: _ProfileCard(
                          player: player,
                          team: team,
                          stats: stats,
                          titles: titles,
                          useMockAvatar: useMockStats,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _PhysicalInfo(player: player),
                    const SizedBox(height: AppSpacing.xxxl),
                    _RecentSection(recent: recent),
                    const SizedBox(height: AppSpacing.xxxl),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: ShapeDecoration(
                          color: AppColors.surfaceLight,
                          shape: RoundedRectangleBorder(
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
                                ref
                                    .read(showDummyDataProvider.notifier)
                                    .toggle(v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.base),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.mediumImpact();
                            await ref.read(authRepoProvider).signOut();
                            if (context.mounted) context.go('/auth');
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            decoration: ShapeDecoration(
                              color: AppColors.surfaceLight,
                              shape: RoundedRectangleBorder(
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
              );
            },
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
  const _Header({
    required this.player,
    required this.onShare,
    required this.isSharing,
  });
  final Player player;
  final VoidCallback onShare;
  final bool isSharing;

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
            onTap: () => _openEdit(context, player),
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
            onTap: isSharing ? null : onShare,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
              child: isSharing
                  ? const InlineSpinner(color: AppColors.textPrimary)
                  : const Icon(
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

  static void _openEdit(BuildContext context, Player player) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _EditProfileScreen(player: player),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// Edit Profile
// ══════════════════════════════════════════════

class _EditProfileScreen extends ConsumerStatefulWidget {
  const _EditProfileScreen({required this.player});
  final Player player;

  @override
  ConsumerState<_EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<_EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _heightCtrl;
  late final Set<Position> _selectedPositions;
  late PreferredFoot _foot;

  Uint8List? _pickedAvatarBytes;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.player;
    _nameCtrl = TextEditingController(text: p.name);
    _numberCtrl = TextEditingController(text: p.number?.toString() ?? '');
    _heightCtrl = TextEditingController(text: p.height?.toString() ?? '');
    _selectedPositions = p.preferredPositions.toSet();
    _foot = p.preferredFoot ?? PreferredFoot.right;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _numberCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await pickTeamLogoImage(
      context,
      maxWidth: 1500,
      maxHeight: 1500,
      imageQuality: 92,
    );
    if (picked == null || !mounted) return;

    final cropped = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        builder: (_) => CropImageScreen(imageBytes: picked.bytes),
      ),
    );
    if (cropped == null || !mounted) return;

    HapticFeedback.selectionClick();
    setState(() => _pickedAvatarBytes = cropped);
  }

  Future<void> _save() async {
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    if (user == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _saving = true);
    try {
      final profileRepo = ref.read(profileRepoProvider);
      String? uploadedUrl;
      if (_pickedAvatarBytes != null) {
        uploadedUrl = await profileRepo.uploadAvatar(
          playerId: user.id,
          bytes: _pickedAvatarBytes!,
          extension: 'png',
        );
      }

      final numberText = _numberCtrl.text.trim();
      final heightText = _heightCtrl.text.trim();

      await profileRepo.update(
        playerId: user.id,
        name: _nameCtrl.text.trim(),
        number: numberText.isEmpty ? null : int.tryParse(numberText),
        avatarUrl: uploadedUrl,
        preferredPositions: _selectedPositions.toList(),
        preferredFoot: _foot,
        height: heightText.isEmpty ? null : int.tryParse(heightText),
      );

      ref.invalidate(currentPlayerProvider);
      await ref.read(currentPlayerProvider.future);

      if (!mounted) return;
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      context.showError('저장 실패: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _togglePosition(Position p) {
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

    final avatarUrl = widget.player.avatarUrl;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
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
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: GestureDetector(
                          onTap: _saving ? null : _pickAvatar,
                          child: Stack(
                            children: [
                              ClipOval(
                                child: _pickedAvatarBytes != null
                                    ? Image.memory(
                                        _pickedAvatarBytes!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : (avatarUrl != null && avatarUrl.isNotEmpty
                                        ? Image.network(
                                            avatarUrl,
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Image(
                                              image: AssetImage(
                                                _defaultAvatarAsset,
                                              ),
                                              width: 80,
                                              height: 80,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Image(
                                            image: AssetImage(
                                              _defaultAvatarAsset,
                                            ),
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          )),
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
                      const _FieldLabel('이름'),
                      const SizedBox(height: AppSpacing.sm),
                      _InputField(
                        controller: _nameCtrl,
                        hint: '이름을 입력해주세요',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
                      const _FieldLabel('선호 포지션'),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final p in Position.values)
                            _PositionPill(
                              label: p.label,
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
                      const _FieldLabel('주발'),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        children: [
                          for (final f in PreferredFoot.values)
                            _PositionPill(
                              label: f.label,
                              isSelected: _foot == f,
                              onTap: () => setState(() => _foot = f),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
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
              onPressed: (canSave && !_saving) ? _save : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.surface,
                disabledForegroundColor: AppColors.textTertiary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.smoothButton,
                ),
              ),
              child: _saving
                  ? const InlineSpinner()
                  : const Text(
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
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothSm),
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
          shape: RoundedRectangleBorder(
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
// Physical Info
// ══════════════════════════════════════════════

class _PhysicalInfo extends StatelessWidget {
  const _PhysicalInfo({required this.player});
  final Player player;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smoothMd,
            side: BorderSide(
              color: AppColors.textPrimary.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _InfoItem(label: '선호 포지션', value: _positionsText(player)),
            ),
            Expanded(
              child: _InfoItem(
                label: '주발',
                value: player.preferredFoot?.label ?? '—',
              ),
            ),
            Expanded(
              child: _InfoItem(
                label: '키',
                value: player.height != null ? '${player.height}cm' : '—',
              ),
            ),
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
// Profile Card
// ══════════════════════════════════════════════

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.player,
    required this.team,
    required this.stats,
    required this.titles,
    this.useMockAvatar = false,
  });

  final Player player;
  final Team? team;
  final SeasonStats? stats;
  final List<PlayerTitle> titles;
  final bool useMockAvatar;

  @override
  Widget build(BuildContext context) {
    final numberText = player.number != null ? '#${player.number}' : '';
    final metaParts = <String>[
      if (team != null) team!.name,
      _positionGroupLabel(player),
      if (numberText.isNotEmpty) numberText,
      _seasonLabel(),
    ];

    final appearances = stats?.appearances ?? 0;
    final goals = stats?.goals ?? 0;
    final assists = stats?.assists ?? 0;
    final mom = stats?.mom ?? 0;

    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothLg),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text(
            player.name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            metaParts.join(' · '),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _BigAvatar(
            avatarUrl: useMockAvatar
                ? _mockProfileAvatar
                : ((player.avatarUrl != null && player.avatarUrl!.isNotEmpty)
                    ? player.avatarUrl
                    : _mockProfileAvatar),
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                _BigStat(value: '$appearances', label: '경기'),
                _BigStat(value: '$goals', label: '골'),
                _BigStat(value: '$assists', label: '어시스트'),
                _BigStat(value: '$mom', label: 'MOM'),
              ],
            ),
          ),
          if (titles.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            _TagRow(titles: titles),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _BigAvatar extends StatelessWidget {
  const _BigAvatar({required this.avatarUrl});
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      // 로컬 mock 에셋 fallback 지원
      if (!avatarUrl!.startsWith('http')) {
        return ClipRRect(
          borderRadius: AppRadius.smoothMd,
          child: Image.asset(
            avatarUrl!,
            width: 220,
            height: 220,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (_, __, ___) =>
                Image.asset(_defaultAvatarAsset, height: 220),
          ),
        );
      }
      return ClipRRect(
        borderRadius: AppRadius.smoothMd,
        child: Image.network(
          avatarUrl!,
          width: 220,
          height: 220,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          errorBuilder: (_, __, ___) =>
              Image.asset(_defaultAvatarAsset, height: 220),
        ),
      );
    }
    return Image.asset(_defaultAvatarAsset, height: 220);
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
            style: const TextStyle(
              fontFamily: 'Barlow Condensed',
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
  const _TagRow({required this.titles});
  final List<PlayerTitle> titles;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: titles.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final title = titles[i];
          final style = _titleStyles[title]!;
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: ShapeDecoration(
              color: style.bg,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.smoothFull,
              ),
            ),
            child: Text(
              title.label,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: style.fg,
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
  const _RecentSection({required this.recent});
  final List<RecentPerformance> recent;

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
          if (recent.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Text(
                '기록된 경기가 없습니다',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            )
          else
            for (var i = 0; i < recent.length; i++) ...[
              _MatchRow(match: recent[i]),
              if (i < recent.length - 1)
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
                shape: RoundedRectangleBorder(
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

// ══════════════════════════════════════════════
// Mock 데이터 (캡쳐용)
// 실제 provider 가 빈 결과일 때만 UI 레이어에서 덮어씀.
// id/키는 mock- prefix 로 구분.
// ══════════════════════════════════════════════

// 과거 mock 시절부터 쓰던 기본 축구선수 얼굴 이미지.
const _mockProfileAvatar = 'assets/images/avatars/profileimage.png';

Team _mockTeam(DateTime createdAt) {
  return Team(
    id: 'mock-team',
    name: '칼로FC',
    logoUrl: null,
    logoColor: '#1572D1',
    description: '주말 풋살 리그 소속 아마추어 팀',
    createdAt: createdAt,
  );
}

SeasonStats _mockSeasonStats() {
  return const SeasonStats(
    appearances: 18,
    goals: 12,
    assists: 7,
    mom: 4,
  );
}

List<PlayerTitle> _mockTitles() {
  return const [
    PlayerTitle.topScorer,
    PlayerTitle.topMom,
    PlayerTitle.topAttendance,
  ];
}

List<RecentPerformance> _mockRecentPerformances() {
  // 가장 최근이 맨 위. 현재 날짜 기준이 아닌 고정 날짜로 스냅샷 안정화.
  return [
    RecentPerformance(
      opponent: 'FC 서울스타즈',
      date: DateTime(2026, 4, 12),
      goals: 2,
      assists: 1,
      isMom: true,
    ),
    RecentPerformance(
      opponent: '한강 유나이티드',
      date: DateTime(2026, 4, 5),
      goals: 1,
      assists: 2,
      isMom: false,
    ),
    RecentPerformance(
      opponent: '청담 루키스',
      date: DateTime(2026, 3, 29),
      goals: 0,
      assists: 1,
      isMom: false,
    ),
    RecentPerformance(
      opponent: '성수 블루웨이브',
      date: DateTime(2026, 3, 22),
      goals: 3,
      assists: 0,
      isMom: true,
    ),
    RecentPerformance(
      opponent: '용산 FC',
      date: DateTime(2026, 3, 15),
      goals: 1,
      assists: 1,
      isMom: false,
    ),
  ];
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({required this.match});
  final RecentPerformance match;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          TeamLogoView.byName(
            name: match.opponent,
            logoUrl: match.opponentLogoUrl,
            size: 36,
            borderRadius: AppRadius.smoothXs,
          ),
          const SizedBox(width: AppSpacing.md),
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
                  formatMdWeekday(match.date),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (match.isMom) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: ShapeDecoration(
                color: AppColors.momBackground,
                shape: RoundedRectangleBorder(
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
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: ShapeDecoration(
              color: AppColors.surfaceLight,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.smoothSm),
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

