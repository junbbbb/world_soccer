import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

class BottomActionBar extends StatefulWidget {
  const BottomActionBar({
    super.key,
    this.isJoined = false,
    this.onExpandChanged,
    this.onJoinRequested,
    this.onCancelJoined,
  });

  final bool isJoined;
  final ValueChanged<bool>? onExpandChanged;
  final VoidCallback? onJoinRequested;
  final VoidCallback? onCancelJoined;

  @override
  State<BottomActionBar> createState() => BottomActionBarState();
}

class BottomActionBarState extends State<BottomActionBar>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late final AnimationController _expandController;
  late final Animation<double> _sizeAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      // 부드럽게 열리도록 시간 약간 늘림
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // 외곽 높이 애니메이션
    _sizeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInCubic,
    );

    // 투명도 애니메이션 (살짝 딜레이를 줘서 좀 더 부드럽게)
    _fadeAnimation = CurvedAnimation(
      parent: _expandController,
      curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
      reverseCurve: Curves.easeIn,
    );

    // 내용물이 아래에서 위로 살짝 올라오는 효과
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _expandController,
            curve: const Interval(0.1, 1.0, curve: Curves.easeOutQuart),
            reverseCurve: Curves.easeInCubic,
          ),
        );
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  final Set<String> _selectedPositions = {};
  final Set<int> _selectedSquads = {1, 2, 3, 4};

  static const _attackers = [('ST', 'ST'), ('LW', 'LW'), ('RW', 'RW')];

  static const _midfielders = [('AM', 'AM'), ('CM', 'CM'), ('DM', 'DM')];

  static const _defenders = [('CB', 'CB'), ('LB', 'LB'), ('RB', 'RB')];

  static const _goalkeepers = [('GK', 'GK')];

  static const _squads = [1, 2, 3, 4];

  void collapse() {
    if (_isExpanded) _setExpanded(false);
  }

  void _setExpanded(bool expanded) {
    setState(() {
      _isExpanded = expanded;
      if (!expanded) {
        _selectedPositions.clear();
        _selectedSquads
          ..clear()
          ..addAll(_squads);
      }
    });
    if (expanded) {
      _expandController.forward(from: 0);
    } else {
      _expandController.reverse();
    }
    widget.onExpandChanged?.call(expanded);
  }

  void _toggleExpand() {
    _setExpanded(!_isExpanded);
  }

  void _togglePosition(String position) {
    setState(() {
      if (_selectedPositions.contains(position)) {
        _selectedPositions.remove(position);
      } else {
        _selectedPositions.add(position);
      }
    });
  }

  void _toggleSquad(int squad) {
    setState(() {
      if (_selectedSquads.contains(squad)) {
        _selectedSquads.remove(squad);
      } else {
        _selectedSquads.add(squad);
      }
    });
  }

  bool get _canConfirm =>
      _selectedPositions.isNotEmpty && _selectedSquads.isNotEmpty;

  void _confirmJoin() {
    if (widget.onJoinRequested != null) {
      widget.onJoinRequested!();
    } else {
      _setExpanded(false);
    }
  }

  void _cancelJoin() {
    if (widget.onCancelJoined != null) {
      widget.onCancelJoined!();
    } else {
      _setExpanded(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: _isExpanded
            ? const BorderRadius.vertical(top: Radius.circular(AppRadius.xl))
            : BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            offset: const Offset(0, -1),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizeTransition(
                sizeFactor: _sizeAnimation,
                axisAlignment: -1.0,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildSelectionPanel(),
                  ),
                ),
              ),
              // Bottom row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3자리 남았어요',
                          style: AppTextStyles.heading.copyWith(
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          '13 / 16명',
                          style: AppTextStyles.body.copyWith(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                      onPressed: widget.isJoined && !_isExpanded
                          ? _toggleExpand
                          : (_isExpanded
                                ? (_canConfirm ? _confirmJoin : null)
                                : _toggleExpand),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isJoined && !_isExpanded
                            ? AppColors.surface
                            : AppColors.primary,
                        foregroundColor: widget.isJoined && !_isExpanded
                            ? AppColors.textSecondary
                            : Colors.white,
                        disabledBackgroundColor: widget.isJoined && !_isExpanded
                            ? AppColors.surface
                            : AppColors.primary.withValues(alpha: 0.4),
                        disabledForegroundColor: widget.isJoined && !_isExpanded
                            ? AppColors.textSecondary
                            : Colors.white.withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.smoothMd,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxxl,
                          vertical: AppSpacing.base,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.isJoined && !_isExpanded
                            ? '참가 완료'
                            : (_isExpanded ? '참가 확정' : '참가하기'),
                        style: AppTextStyles.heading.copyWith(
                          color: widget.isJoined && !_isExpanded
                              ? AppColors.textSecondary
                              : Colors.white,
                        ),
                      ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '참가 정보를 선택해주세요',
              style: AppTextStyles.heading.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: _toggleExpand,
              child: const Icon(
                Icons.close,
                size: 22,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        if (widget.isJoined) ...[
          const SizedBox(height: AppSpacing.base),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cancelJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.smoothMd,
                ),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                elevation: 0,
              ),
              child: Text(
                '참가 취소',
                style: AppTextStyles.heading.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],

        const SizedBox(height: AppSpacing.lg),

        // Position section
        Text(
          '포지션',
          style: AppTextStyles.labelRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _buildPositionRow('공격수', _attackers),
        _buildPositionRow('미드필더', _midfielders),
        _buildPositionRow('수비수', _defenders),
        _buildPositionRow('골키퍼', _goalkeepers),
        const SizedBox(height: AppSpacing.base),

        // Squad section
        Text(
          '스쿼드',
          style: AppTextStyles.labelRegular.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: _squads.map((squad) {
            final isSelected = _selectedSquads.contains(squad);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: squad != _squads.last ? 6 : 0),
                child: _buildChip(
                  label: '$squad',
                  isSelected: isSelected,
                  onTap: () => _toggleSquad(squad),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),

        Divider(color: AppColors.iconInactive.withValues(alpha: 0.3), height: 1),
        const SizedBox(height: AppSpacing.base),
      ],
    );
  }

  Widget _buildPositionRow(String category, List<(String, String)> positions) {
    const maxItemsPerRow = 3;
    final paddedPositions = List<(String, String)?>.from(positions);
    while (paddedPositions.length < maxItemsPerRow) {
      paddedPositions.add(null);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            child: Text(
              category,
              style: AppTextStyles.labelRegular.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Row(
              children: paddedPositions.asMap().entries.map((entry) {
                final index = entry.key;
                final pos = entry.value;
                final isLast = index == maxItemsPerRow - 1;

                if (pos == null) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: isLast ? 0 : 4),
                      child: const SizedBox.shrink(),
                    ),
                  );
                }

                final isSelected = _selectedPositions.contains(pos.$1);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 4),
                    child: _buildChip(
                      label: pos.$2,
                      isSelected: isSelected,
                      onTap: () => _togglePosition(pos.$1),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: ShapeDecoration(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smoothFull,
            side: BorderSide(
              color: isSelected ? AppColors.textPrimary : Colors.transparent,
              width: 1.2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child: Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: AppColors.textPrimary,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
