import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/snackbar.dart';
import '../../../repo/chat_repo.dart';
import '../../../runtime/providers.dart';
import '../../../types/chat.dart';
import '../../../types/enums.dart';
import '../../../types/team.dart';

class GroupInfoScreen extends ConsumerStatefulWidget {
  const GroupInfoScreen({super.key, required this.room});

  final ChatRoom room;

  @override
  ConsumerState<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends ConsumerState<GroupInfoScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _avatarColors = [
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFF9575CD),
    Color(0xFF81C784),
    Color(0xFF4DD0E1),
    Color(0xFF64B5F6),
    Color(0xFFF06292),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeamMember> _filter(List<TeamMember> members) {
    if (_searchQuery.isEmpty) return members;
    return members
        .where((m) => (m.playerName ?? '').contains(_searchQuery))
        .toList();
  }

  String? get _myId =>
      ref.read(supabaseClientProvider).auth.currentUser?.id;

  Future<void> _openDirectChat(TeamMember member) async {
    final meId = _myId;
    if (meId == null) return;
    try {
      final room = await ref.read(chatServiceProvider).getOrCreateDirectRoom(
            meId: meId,
            otherId: member.playerId,
          );
      if (!mounted) return;
      context.push('/chat', extra: room);
    } on NotTeammateException {
      if (!mounted) return;
      context.showError('같은 팀원에게만 메시지를 보낼 수 있습니다');
    } catch (e) {
      if (!mounted) return;
      context.showError('오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamId = widget.room.teamId;
    final membersAsync = teamId == null
        ? const AsyncValue<List<TeamMember>>.data([])
        : ref.watch(teamMembersByTeamProvider(teamId));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: membersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text(
                '멤버를 불러오지 못했습니다\n$err',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            data: (members) => _buildContent(context, members),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<TeamMember> members) {
    final filtered = _filter(members);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildAppBar()),
        SliverToBoxAdapter(child: _buildGroupBanner(members.length)),
        SliverToBoxAdapter(child: _buildDescription()),
        SliverToBoxAdapter(child: _buildDivider()),
        SliverToBoxAdapter(child: _buildMemberHeader(members.length)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildMemberRow(filtered[index]),
            childCount: filtered.length,
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: AppSpacing.xxxl),
        ),
      ],
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.base,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 24,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildGroupBanner(int memberCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          if (widget.room.logoPath != null)
            ClipOval(
              child: Image.asset(
                widget.room.logoPath!,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            )
          else
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Text(
                widget.room.name.isNotEmpty ? widget.room.name[0] : '?',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            widget.room.name,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '멤버 $memberCount명',
            style: AppTextStyles.labelRegular.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '그룹 설명',
            style: AppTextStyles.captionMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${widget.room.name} 공식 채팅방입니다.',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 8,
      color: AppColors.surface,
    );
  }

  Widget _buildMemberHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.base,
        AppSpacing.xl,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '멤버 $count명',
            style: AppTextStyles.heading.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 36,
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: '멤버 검색',
                hintStyle: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 20,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                isDense: true,
              ),
              style: AppTextStyles.bodyRegular.copyWith(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRow(TeamMember member) {
    final isMe = member.playerId == _myId;
    final displayName = isMe ? '나' : (member.playerName ?? '이름 없음');
    final colorIndex =
        member.playerId.hashCode.abs() % _avatarColors.length;
    final roleLabel = switch (member.role) {
      TeamRole.admin => '관리자',
      TeamRole.mercenary => '용병',
      TeamRole.member => null,
    };

    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: _avatarColors[colorIndex],
            backgroundImage: member.playerAvatarUrl != null
                ? NetworkImage(member.playerAvatarUrl!)
                : null,
            child: member.playerAvatarUrl == null
                ? Text(
                    displayName.isNotEmpty ? displayName[0] : '?',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: AppTextStyles.heading.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (roleLabel != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        roleLabel,
                        style: AppTextStyles.caption.copyWith(
                          color: member.role == TeamRole.admin
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (member.playerPosition != null)
                  Text(
                    member.playerPosition!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (!isMe)
            IconButton(
              tooltip: '1:1 메시지',
              onPressed: () => _openDirectChat(member),
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 20,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
