import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/section_title.dart';

class _Post {
  final String author;
  final String avatarPath;
  final String content;
  final int likes;
  final int comments;

  const _Post({
    required this.author,
    required this.avatarPath,
    required this.content,
    required this.likes,
    required this.comments,
  });
}

const _dummyPosts = [
  _Post(
    author: '벤 화이트',
    avatarPath: 'assets/images/avatars/B.WHITE_Headshot_web_xdbqzl78.avif',
    content: '이번주 토요일 경기 다들 참석 가능한지 확인 부탁드립니다! 유니폼 꼭 챙겨오세요 🙏',
    likes: 5,
    comments: 3,
  ),
  _Post(
    author: '라야',
    avatarPath: 'assets/images/avatars/RAYA_Headshot_web_njztl3wr.avif',
    content: '지난 경기 하이라이트 영상 올렸습니다. 3번째 골 진짜 미쳤음 ㅋㅋ',
    likes: 12,
    comments: 7,
  ),
  _Post(
    author: '살리바',
    avatarPath: 'assets/images/avatars/SALIBA_Headshot_web_khl9z1vw.avif',
    content: '다음달 회비 납부 안내드립니다. 계좌번호는 공지 참고해주세요~',
    likes: 2,
    comments: 1,
  ),
  _Post(
    author: '모스케라',
    avatarPath: 'assets/images/avatars/MOSQUERA_Headshot_web_b3sucu1j.avif',
    content: '주말 연습 끝나고 회식 갈 사람 댓글 달아주세요 🍻',
    likes: 8,
    comments: 4,
  ),
];

class TeamPostsSection extends StatelessWidget {
  const TeamPostsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.paddingPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('팀 게시물'),
          ...List.generate(_dummyPosts.length, (index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                  child: _PostItem(post: _dummyPosts[index]),
                ),
                if (index < _dummyPosts.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.textPrimary.withValues(alpha: 0.06),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PostItem extends StatelessWidget {
  const _PostItem({required this.post});

  final _Post post;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipOval(
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(post.avatarPath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                post.content,
                style: AppTextStyles.bodyRegular.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 22,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${post.likes}',
                    style: AppTextStyles.labelRegular.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.base),
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${post.comments}',
                    style: AppTextStyles.labelRegular.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
