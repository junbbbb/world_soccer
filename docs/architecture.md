# Architecture — 6-Layer (OpenAI Layered)

## 원칙

> 의존성은 오직 앞으로만. 뒤로 가는 import는 린터가 차단.

```
Types → Config → Repo → Service → Runtime → UI
```

## 목표 디렉토리 구조

```
lib/
├── types/                    # Layer 0: 순수 데이터
│   ├── match.dart            #   Match, MatchResult, QuarterLineup
│   ├── player.dart           #   Player, LineupMember
│   ├── team.dart             #   Team
│   ├── profile.dart          #   Profile, SeasonStats
│   ├── lineup.dart           #   Formation, SlotPosition, QuarterLineup
│   └── enums.dart            #   Position, MatchResult, FairnessStatus
│
├── config/                   # Layer 1: 설정 (Types만 import 가능)
│   ├── supabase_config.dart  #   Supabase URL, anon key
│   ├── app_constants.dart    #   시즌 기준월, 포메이션 목록, 포지션 목록
│   └── feature_flags.dart    #   기능 플래그 (오프라인 모드 등)
│
├── repo/                     # Layer 2: 데이터 접근 (Types, Config까지)
│   ├── auth_repo.dart        #   Supabase Auth
│   ├── match_repo.dart       #   경기 CRUD, 결과 입력
│   ├── lineup_repo.dart      #   라인업 저장/조회
│   ├── player_repo.dart      #   선수 정보, 참가 관리
│   ├── profile_repo.dart     #   프로필 조회/수정
│   ├── team_repo.dart        #   팀 목록, 팀 전환
│   └── stats_repo.dart       #   시즌 스탯 집계 (SQL view)
│
├── service/                  # Layer 3: 비즈니스 로직 (Types, Config, Repo까지)
│   ├── auth_service.dart     #   로그인/로그아웃 플로우
│   ├── match_service.dart    #   경기 생성, 참가 신청 (포지션+쿼터)
│   ├── lineup_service.dart   #   자동 분배, 수동 배치, 용병 추가
│   ├── stats_service.dart    #   시즌 기록 계산, H2H 전적
│   └── profile_service.dart  #   프로필 편집, 공유 카드 생성
│
├── runtime/                  # Layer 4: 앱 초기화 (Types~Service까지)
│   ├── app.dart              #   ProviderScope, MaterialApp
│   ├── router.dart           #   GoRouter 설정 (기존 app_router.dart)
│   └── providers.dart        #   글로벌 Provider 등록 (repo/service DI)
│
├── ui/                       # Layer 5: 화면 (전부 참조 가능)
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── home_tab.dart
│   │   └── widgets/
│   ├── match/
│   │   ├── match_screen.dart
│   │   ├── result_input_screen.dart
│   │   ├── lineup/           # 라인업 빌더 (기존 구조 유지)
│   │   ├── share/
│   │   └── widgets/
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── chat/
│   ├── stats/
│   ├── team/
│   └── shared/
│       └── widgets/
│
└── core/                     # 예외: 디자인 시스템 (모든 레이어에서 접근)
    └── theme/
        ├── app_colors.dart
        ├── app_text_styles.dart
        ├── app_spacing.dart
        ├── app_radius.dart
        └── app_shadows.dart
```

## 레이어별 규칙

### Types (Layer 0)
- 아무것도 import하지 않음 (dart:core 제외)
- `@freezed` 모델, `enum`, `typedef`만
- 비즈니스 로직 금지 (getter로 계산하는 건 OK, 외부 의존 금지)
- 모든 필드 immutable (`final`)
- `copyWith`, `toJson`, `fromJson` 허용 (freezed가 생성)

### Config (Layer 1)
- Types만 import 가능
- `const` 값, 환경변수 접근, 피처 플래그
- 런타임에 변경 가능한 설정은 여기 (하드코딩 상수와 분리)
- 예: 포메이션 목록, 포지션 목록, 시즌 기준월

### Repo (Layer 2)
- Types, Config만 import 가능
- **Service를 import하면 안 됨** ← 가장 자주 위반되는 규칙
- Supabase 클라이언트 직접 사용
- 하나의 repo = 하나의 DB 테이블/도메인
- 반환값은 항상 Types에 정의된 모델
- 에러는 Exception으로 throw (catch는 Service에서)

### Service (Layer 3)
- Types, Config, Repo까지 import 가능
- **UI를 import하면 안 됨**
- 여러 Repo를 조합하는 비즈니스 로직
- 에러 핸들링 (try-catch)
- 예: `LineupService.autoDistribute()` — Repo에서 선수 목록 가져와서 분배 알고리즘 실행

### Runtime (Layer 4)
- Types~Service까지 전부 import 가능
- 앱 초기화 (Supabase.initialize, ProviderScope)
- GoRouter 라우트 정의
- Riverpod Provider 등록 (Repo/Service를 Provider로 감싸서 DI)

### UI (Layer 5)
- 전부 참조 가능하지만, **Repo 직접 접근 지양** (Service를 통해)
- Riverpod `ref.watch`로 Service/State 구독
- presentation 로직만 (데이터 가공은 Service에서)
- 디자인 토큰은 Core에서

### Core (예외)
- 모든 레이어에서 import 가능 (레이어 체인 밖)
- 디자인 토큰만 (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`)
- 비즈니스 로직/데이터 모델 금지

## 의존성 매트릭스

| From \ To | Types | Config | Repo | Service | Runtime | UI | Core |
|-----------|-------|--------|------|---------|---------|-----|------|
| Types     | -     | ✗      | ✗    | ✗       | ✗       | ✗   | ✗    |
| Config    | ✓     | -      | ✗    | ✗       | ✗       | ✗   | ✗    |
| Repo      | ✓     | ✓      | -    | ✗       | ✗       | ✗   | ✗    |
| Service   | ✓     | ✓      | ✓    | -       | ✗       | ✗   | ✗    |
| Runtime   | ✓     | ✓      | ✓    | ✓       | -       | ✗   | ✓    |
| UI        | ✓     | ✓      | △    | ✓       | ✗       | -   | ✓    |
| Core      | ✗     | ✗      | ✗    | ✗       | ✗       | ✗   | -    |

`✓` = 허용, `✗` = 금지, `△` = 지양 (Service를 통해 접근 권장)

## 린터 강제

`import_lint` 패키지로 레이어 의존성 물리적 차단:

```yaml
# import_lint.yaml
rules:
  - target: "lib/types/**"
    except: ["lib/types/**"]
    
  - target: "lib/config/**"
    except: ["lib/types/**", "lib/config/**"]
    
  - target: "lib/repo/**"
    except: ["lib/types/**", "lib/config/**", "lib/repo/**"]
    
  - target: "lib/service/**"
    except: ["lib/types/**", "lib/config/**", "lib/repo/**", "lib/service/**"]
    
  - target: "lib/runtime/**"
    except: ["lib/types/**", "lib/config/**", "lib/repo/**", "lib/service/**", "lib/runtime/**", "lib/core/**"]

  # UI는 전부 허용 (core 포함)
  # Core는 외부 의존 금지 (dart/flutter SDK만)
```

## Supabase 테이블 설계 (초안)

```sql
-- teams
id uuid PK, name text, logo_url text, created_at timestamptz

-- players (= auth.users와 1:1)
id uuid PK (= auth.uid), name text, number int, avatar_url text,
preferred_positions text[], preferred_foot text, height int,
created_at timestamptz

-- team_members (다대다)
team_id uuid FK, player_id uuid FK, role text ('member'|'admin'),
joined_at timestamptz, PRIMARY KEY (team_id, player_id)

-- matches
id uuid PK, team_id uuid FK, date timestamptz, location text,
opponent_name text, opponent_logo_url text,
our_score int, opponent_score int, status text ('upcoming'|'completed'),
created_at timestamptz

-- match_participations (참가 신청)
match_id uuid FK, player_id uuid FK,
preferred_positions text[], available_quarters int[],
PRIMARY KEY (match_id, player_id)

-- quarter_lineups
match_id uuid FK, quarter int (1~4), formation_index int,
slot_to_player_id jsonb, -- {0: "uuid", 1: "uuid", ...}
PRIMARY KEY (match_id, quarter)

-- player_match_stats
match_id uuid FK, player_id uuid FK,
goals int DEFAULT 0, assists int DEFAULT 0, is_mom boolean DEFAULT false,
PRIMARY KEY (match_id, player_id)

-- RLS: team_members 기반으로 팀 데이터 격리
```

### Chat 도메인 (결정 012~014)

```
-- chat_rooms (팀 단체방 + DM)
id uuid PK, type text check in ('team', 'direct'),
team_id uuid FK nullable (type='team' 필수),
name text,
CONSTRAINT chat_rooms_team_unique unique (team_id),
CONSTRAINT chat_rooms_type_integrity check (
  (type='team' and team_id is not null) or
  (type='direct' and team_id is null)
)

-- chat_room_members
room_id uuid FK, player_id uuid FK,
joined_at timestamptz, last_read_at timestamptz,
PRIMARY KEY (room_id, player_id)

-- chat_messages
id uuid PK, room_id uuid FK, sender_id uuid FK,
content text, type text DEFAULT 'text', created_at timestamptz
INDEX (room_id, created_at desc)

-- 자동 동기화 트리거 (앱 로직 없이 DB 가 처리)
-- teams insert/update/delete, team_members insert/delete 전부 감지

-- RLS: SECURITY DEFINER 헬퍼 is_chat_room_member(room_id) 기반
--      (재귀 방지, 결정 013 참고)

-- RPC:
--   get_my_chat_rooms()           → 방 목록 + 메타 집계 (결정 014)
--   get_or_create_direct_room(p)  → DM 방 원자적 생성 (advisory lock)
--   share_team_with(p)            → 같은 팀 여부 단일 쿼리
```

### Storage 버킷

| 버킷 | 용도 | 쓰기 권한 | 결정 |
|---|---|---|---|
| `team-logos` | 팀 로고 이미지 | 팀 admin (경로 `{teamId}/`) | 011 |
| `player-avatars` | 선수 프로필 아바타 | 본인 (경로 `{playerId}/`) | 016 |

두 버킷 모두 public read, 2MB 제한, mime 제한(jpeg/png/webp).
RLS 정책은 `storage.foldername(name)[1]` 과 `auth.uid()::text` 비교로
본인/admin 만 쓰기 허용.

데이터 흐름:
- 팀 생성 → `on_team_created_create_chat_room` 트리거 → 단체방 생성
- 팀원 가입 → `on_team_member_added_join_chat_room` 트리거 → 방 참여
- 팀명 변경 → `on_team_renamed_sync_chat_room_name` 트리거 → 방이름 갱신
- 팀원 탈퇴/강퇴 → `on_team_member_removed_leave_chat_room` 트리거 → 방 제거
- 실시간: `chat_messages`/`chat_room_members` 가 `supabase_realtime` publication
  에 등록됨. 클라이언트는 방 상세에서 메시지 스트림, 홈 탭에서 배지 갱신
  이벤트 구독

N+1 회피 원칙 (결정 014):
- 방 목록은 `get_my_chat_rooms()` RPC 1회로 모든 메타 포함
- 메시지 스트림은 단일 테이블(`chat_messages`) 만 구독하므로 sender 조인 불가 →
  `SupabaseChatRepo._senderCache` 에 `{name, avatar_url}` 유지, miss 시 1회 조회
- DM 방 얻기는 `getOrCreateDirectRoom` RPC 1회 + `getRoom` 1회
  (`chat_rooms!inner(chat_room_members, players)` 단일 join)

## Riverpod Provider 구조 (Runtime)

```dart
// repo providers (autoDispose)
@riverpod MatchRepo matchRepo(Ref ref) => MatchRepo(ref.watch(supabaseProvider));
@riverpod LineupRepo lineupRepo(Ref ref) => LineupRepo(ref.watch(supabaseProvider));

// service providers (repo 주입)
@riverpod MatchService matchService(Ref ref) => MatchService(ref.watch(matchRepoProvider));
@riverpod LineupService lineupService(Ref ref) => LineupService(
  ref.watch(lineupRepoProvider),
  ref.watch(playerRepoProvider),
);

// state providers (UI가 구독)
@riverpod
class MatchListController extends _$MatchListController {
  @override
  Future<List<Match>> build() => ref.watch(matchServiceProvider).getUpcoming();
}
```
