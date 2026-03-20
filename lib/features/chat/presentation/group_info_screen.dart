import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import 'chat_tab.dart';

/// 그룹 멤버 모델 (더미)
class GroupMember {
  const GroupMember({
    required this.id,
    required this.name,
    this.tag,
    this.isAdmin = false,
    this.isMe = false,
  });

  final int id;
  final String name;
  final String? tag;
  final bool isAdmin;
  final bool isMe;
}

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({super.key, required this.room});

  final ChatRoom room;

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _members = [
    GroupMember(id: 0, name: '나', tag: null, isMe: true),
    GroupMember(id: 1, name: '김민수', tag: '주장', isAdmin: true),
    GroupMember(id: 2, name: '이준호', tag: '골키퍼'),
    GroupMember(id: 3, name: '박성진', tag: '공격수'),
    GroupMember(id: 4, name: '최영훈', tag: '수비수'),
    GroupMember(id: 5, name: '정우성'),
    GroupMember(id: 6, name: '한지민'),
    GroupMember(id: 7, name: '강동원', tag: '미드필더'),
    GroupMember(id: 8, name: '유재석'),
    GroupMember(id: 9, name: '송중기', tag: '공격수'),
  ];

  static const _avatarColors = [
    Color(0xFFE57373),
    Color(0xFFFFB74D),
    Color(0xFF9575CD),
    Color(0xFF81C784),
    Color(0xFF4DD0E1),
    Color(0xFF64B5F6),
    Color(0xFFF06292),
  ];

  List<GroupMember> get _filteredMembers {
    if (_searchQuery.isEmpty) return _members;
    return _members
        .where((m) => m.name.contains(_searchQuery))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 상단 앱바
              SliverToBoxAdapter(child: _buildAppBar()),
              // 그룹 배너 (아바타 80pt + 이름 20pt)
              SliverToBoxAdapter(child: _buildGroupBanner()),
              // 그룹 설명
              SliverToBoxAdapter(child: _buildDescription()),
              // 구분선
              SliverToBoxAdapter(child: _buildDivider()),
              // 미디어/링크/문서
              SliverToBoxAdapter(child: _buildMediaSection()),
              SliverToBoxAdapter(child: _buildDivider()),
              // 알림 설정
              SliverToBoxAdapter(child: _buildNotificationToggle()),
              SliverToBoxAdapter(child: _buildDivider()),
              // 사라지는 메시지
              SliverToBoxAdapter(child: _buildDisappearingMessages()),
              SliverToBoxAdapter(child: _buildDivider()),
              // 멤버 섹션 헤더 + 검색
              SliverToBoxAdapter(child: _buildMemberHeader()),
              // 멤버 리스트
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildMemberRow(_filteredMembers[index]),
                  childCount: _filteredMembers.length,
                ),
              ),
              // 하단 여유
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.only(left: AppSpacing.xs, right: AppSpacing.base),
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
          const Icon(
            Icons.more_vert_rounded,
            size: 24,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  /// 스펙: 그룹 아바타 80×80pt + 이름 20pt
  Widget _buildGroupBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          // 아바타 80×80pt
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
                widget.room.name[0],
                style: AppTextStyles.sectionTitle.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                ),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          // 이름 20pt
          Text(
            widget.room.name,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '멤버 ${widget.room.memberCount}명',
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
            '${widget.room.name} 공식 채팅방입니다. 경기 일정, 공지사항 등을 공유합니다.',
            style: AppTextStyles.bodyRegular.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 8,
      color: AppColors.surface,
    );
  }

  Widget _buildMediaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.base,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '미디어, 링크, 문서',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '알림',
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Switch(
            value: !widget.room.isMuted,
            onChanged: (_) {},
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDisappearingMessages() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.base,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.timer_outlined,
            color: AppColors.textTertiary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '사라지는 메시지',
                  style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  '꺼짐',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberHeader() {
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
            '멤버 ${_members.length}명',
            style: AppTextStyles.heading.copyWith(color: AppColors.textPrimary),
          ),
          const SizedBox(height: AppSpacing.sm),
          // 검색창: 36pt 높이, border radius 10pt
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

  /// 스펙: 각 행 56pt 높이, 이름 16pt + 태그 13pt gray
  Widget _buildMemberRow(GroupMember member) {
    final colorIndex = member.id % _avatarColors.length;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Row(
        children: [
          // 아바타
          CircleAvatar(
            radius: 18,
            backgroundColor: _avatarColors[colorIndex],
            child: Text(
              member.name[0],
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // 이름 + 태그
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      member.isMe ? '나' : member.name,
                      style: AppTextStyles.heading.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                    if (member.isAdmin) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '관리자',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
                if (member.tag != null)
                  Text(
                    member.tag!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                      fontSize: 13,
                    ),
                  ),
                // 내 프로필: "Add member tag" 버튼
                if (member.isMe && member.tag == null)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('멤버 태그 추가 기능 (준비 중)')),
                      );
                    },
                    child: Text(
                      'Add member tag',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
