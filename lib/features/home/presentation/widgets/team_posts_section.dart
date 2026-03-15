import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/section_title.dart';

class _Post {
  final String author;
  final String avatar;
  final String time;
  final String content;
  final int likes;
  final int comments;

  const _Post({
    required this.author,
    required this.avatar,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
  });
}

const _dummyPosts = [
  _Post(
    author: '김주장',
    avatar: '⚽',
    time: '오후 3:42',
    content: '이번주 토요일 경기 다들 참석 가능한지 확인 부탁드립니다! 유니폼 꼭 챙겨오세요 🙏',
    likes: 5,
    comments: 3,
  ),
  _Post(
    author: '박골키퍼',
    avatar: '🧤',
    time: '오후 1:15',
    content: '지난 경기 하이라이트 영상 올렸습니다. 3번째 골 진짜 미쳤음 ㅋㅋ',
    likes: 12,
    comments: 7,
  ),
  _Post(
    author: '이미드',
    avatar: '🏃',
    time: '오전 11:30',
    content: '다음달 회비 납부 안내드립니다. 계좌번호는 공지 참고해주세요~',
    likes: 2,
    comments: 1,
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
            return _PostBubble(post: _dummyPosts[index]);
          }),
        ],
      ),
    );
  }
}

class _PostBubble extends StatelessWidget {
  const _PostBubble({required this.post});

  final _Post post;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아바타
          Container(
            width: 36,
            height: 36,
            decoration: const ShapeDecoration(
              color: Color(0xFFF2F4F6),
              shape: SmoothRectangleBorder(
                borderRadius: SmoothBorderRadius.all(
                  SmoothRadius(cornerRadius: 10, cornerSmoothing: 1.0),
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              post.avatar,
              style: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(width: 10),
          // 말풍선
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름 + 시간
                Row(
                  children: [
                    Text(
                      post.author,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF333D4B),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      post.time,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8E97A3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 본문 버블
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const ShapeDecoration(
                    color: Color(0xFFF2F4F6),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius.only(
                        topLeft: SmoothRadius(cornerRadius: 4, cornerSmoothing: 1.0),
                        topRight: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
                        bottomLeft: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
                        bottomRight: SmoothRadius(cornerRadius: 16, cornerSmoothing: 1.0),
                      ),
                    ),
                  ),
                  child: Text(
                    post.content,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF333D4B),
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 좋아요 + 댓글
                Row(
                  children: [
                    const Icon(Icons.favorite_border_rounded, size: 14, color: Color(0xFF8E97A3)),
                    const SizedBox(width: 3),
                    Text(
                      '${post.likes}',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        color: Color(0xFF8E97A3),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.chat_bubble_outline_rounded, size: 13, color: Color(0xFF8E97A3)),
                    const SizedBox(width: 3),
                    Text(
                      '${post.comments}',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 11,
                        color: Color(0xFF8E97A3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
