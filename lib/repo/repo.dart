/// Layer 2: 데이터 접근 — Supabase
/// 의존: types, config
library;

// 인터페이스
export 'auth_repo.dart';
export 'lineup_repo.dart';
export 'match_repo.dart';
export 'player_repo.dart';
export 'profile_repo.dart';
export 'stats_repo.dart';
export 'team_repo.dart';

// 구현체
export 'supabase_auth_repo.dart';
export 'supabase_lineup_repo.dart';
export 'supabase_match_repo.dart';
export 'supabase_player_repo.dart';
export 'supabase_profile_repo.dart';
export 'supabase_stats_repo.dart';
export 'supabase_team_repo.dart';
