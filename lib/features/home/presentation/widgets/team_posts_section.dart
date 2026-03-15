import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('팀 게시물'),
          ...List.generate(_dummyPosts.length, (index) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: _PostItem(post: _dummyPosts[index]),
                ),
                if (index < _dummyPosts.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: const Color(0xFF333D4B).withValues(alpha: 0.06),
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
        // 아바타 (원형 프로필 이미지)
        ClipOval(
          child: SizedBox(
            width: 40,
            height: 40,
            child: Image.asset(
              post.avatarPath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 콘텐츠
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름 (검정)
              Text(
                post.author,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF333D4B),
                ),
              ),
              const SizedBox(height: 6),
              // 본문
              Text(
                post.content,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF333D4B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // 좋아요(하트) + 댓글(말풍선) 아이콘
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 22,
                    color: Color(0xFF8E97A3),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likes}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E97A3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 20,
                    color: Color(0xFF8E97A3),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.comments}',
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF8E97A3),
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
