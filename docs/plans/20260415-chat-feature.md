# 2026-04-15 — 채팅 시스템 (팀 단체방 + DM)

시작: 2026-04-14
상태: 완료

결정 012~014 묶음. 팀 채팅방은 팀 생성/멤버 변동에 맞춰 DB 트리거로
자동 동기화되고, 팀원 간 1:1 DM 은 advisory lock 을 건 RPC 로
원자적으로 생성된다. 방 목록·메시지·안읽은수 는 단일 RPC + 클라이언트
캐시 + realtime 구독으로 N+1 0 화.

## 변경 요약 (사용자 관점)

### Before → After

**팀 채팅방**
- Before: 없음. 더미 데이터 목록만
- After: 팀 생성 즉시 단체 채팅방 자동 생성. 팀원 초대/가입 시 자동 참여,
  탈퇴 시 자동 제거. 팀명 변경하면 방 이름도 동기화

**1:1 DM**
- Before: 없음
- After: 그룹 채팅방 정보 → 멤버 옆 "1:1 메시지" 버튼. 같은 팀원끼리만 허용.
  기존 방 있으면 재사용, 없으면 새로 생성

**메시지**
- Before: 더미
- After: 실시간 송수신. 보낸 즉시 내 화면에 반영(optimistic),
  상대 화면엔 realtime publication 으로 도착. 읽음 처리(last_read_at)
  로 안읽은 배지 관리

**방 목록**
- Before: 더미 4개
- After: 내 소속 방 전부. 마지막 메시지 · 안읽은 수 · 멤버 수 서버 집계.
  다른 방에 새 메시지 오면 탭 진입 없이 배지 실시간 갱신

## TDD 흐름

`test/service/chat_service_test.dart` — 총 12 케이스
(sendMessage 3, getOrCreateDirectRoom 3, getMessages 3, markAsRead 2,
getMyRooms 1)

**🔴 Red**: 테스트 작성 → `ChatService`/`ChatRepo`/예외 타입 부재로 컴파일 실패
**🟢 Green**: 인터페이스 + 서비스 + 예외 구현 → 12/12 통과
**🔵 Refactor**: Eng Review 후 RPC 집계로 N+1 제거, 인터페이스 슬림화
(`findDirectRoom`/`createDirectRoom`/`shareTeam` → `getOrCreateDirectRoom` 1개),
서버 RPC 가 팀원 검증 책임 전담

## DB 변경

| 마이그레이션 | 내용 |
|------|------|
| `20260414050000_chat.sql` | `chat_rooms` / `chat_room_members` / `chat_messages` + RLS + 자동 동기화 트리거 4종 + `get_or_create_direct_room` RPC + realtime publication |
| `20260414060000_chat_rls_fix.sql` | RLS 무한 재귀(`42P17`) 해결. `is_chat_room_member` SECURITY DEFINER 헬퍼 + 정책 4종 재작성 |
| `20260414070000_chat_perf.sql` | `get_my_chat_rooms` RPC(집계 1회), `share_team_with` RPC, `get_or_create_direct_room` advisory lock 추가 |
| `20260415000000_chat_logo.sql` | 방 목록 RPC 에 `team_logo_url` / `team_logo_color` 컬럼 추가 |

## 단계

- [x] `ChatService` TDD (sendMessage / DM 생성 / markAsRead / getMessages)
- [x] 타입/인터페이스: `types/chat.dart`, `repo/chat_repo.dart`
- [x] `SupabaseChatRepo` 초기 구현
- [x] DB 마이그레이션 + RLS + 트리거 (팀 ↔ 방 자동 동기화)
- [x] RLS 무한 재귀 수정 (SECURITY DEFINER 헬퍼)
- [x] Eng Review → N+1 제거 (RPC 집계)
- [x] DM 중복 생성 레이스 차단 (advisory lock)
- [x] `ChatRepo` 인터페이스 슬림화 (3개 메서드 통합)
- [x] `SupabaseChatRepo` sender 캐시
- [x] `ChatTab` realtime 채널 구독 (insert / update debounce)
- [x] UI 타입 통합: 로컬 더미 타입 제거 → `types/chat.dart` 단일 소스
- [x] `ChatRoomScreen` 실시간 연결 + optimistic update + timestamp 정렬
- [x] `GroupInfoScreen` 실제 팀원 + 1:1 DM 버튼
- [x] 방 목록 셀에 팀 로고 이미지 렌더 (fallback: `logoColor` + 이니셜)
- [x] 구현/마이그레이션 일체 `supabase db push` 반영

## 핵심 파일

| Layer | 파일 |
|------|------|
| types | `lib/types/chat.dart` (`ChatRoom`, `ChatMessage`, `ChatRoomType`) |
| repo | `lib/repo/chat_repo.dart` (인터페이스 + `NotTeammateException`) |
| repo | `lib/repo/supabase_chat_repo.dart` (RPC 호출 + sender 캐시 + realtime stream) |
| service | `lib/service/chat_service.dart` (`ChatService` + `NotRoomMemberException`) |
| runtime | `lib/runtime/providers.dart` (`chatRepoProvider`, `chatServiceProvider`, `myChatRoomsProvider`, `roomMessageStreamProvider`, `teamMembersByTeamProvider`) |
| ui | `lib/features/chat/presentation/chat_tab.dart` (realtime 배지 갱신) |
| ui | `lib/features/chat/presentation/chat_room_screen.dart` (stream + optimistic send + markAsRead) |
| ui | `lib/features/chat/presentation/group_info_screen.dart` (팀원 + DM 진입점) |
| ui | `lib/features/chat/presentation/widgets/chat_room_cell.dart` (팀 로고 렌더) |
| test | `test/service/chat_service_test.dart` (12 케이스) |

## 성능 목표 달성

| 시나리오 | Before | After |
|---|---|---|
| 방 목록 로드 (N=10, DM 3) | 2 + 2N + K = 26 round-trip | **1 round-trip** (RPC 집계) |
| 새 메시지 도착 시 sender 조회 | 매번 N회 | **캐시 히트 시 0회** (miss 1회) |
| DM 방 얻기 | find(4-RT) + create | **1 RPC** (advisory lock 원자적) |
| 다른 방 배지 갱신 | 탭 재진입 필요 | **realtime 자동** (200ms debounce) |

## 메모

- 팀 단체방 생성은 DB 트리거가 전담 → 앱 레이어에 별도 로직 불필요
- `chat_rooms.type_integrity` CHECK 제약: `team` 이면 `team_id` 필수, `direct` 면 null
- DM 정렬 쌍 해시(`hashtextextended`) + `pg_advisory_xact_lock` 으로 동시 요청 직렬화
- `subscribeMessages` 는 `limit(1)` + DESC 로 최신만 관찰 → 초기 로드와 경합 방지
- ChatRoomScreen: `_messageIds` Set 으로 dedup, add 직후 timestamp sort 로 순서 방어
- 팀 로고 URL 없을 땐 `logoColor`(hex) 로 이니셜 원형 배경 → 모든 팀이 즉시 일관된 시각
