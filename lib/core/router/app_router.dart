import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/chat/presentation/chat_room_screen.dart';
import '../../features/chat/presentation/chat_tab.dart';
import '../../features/chat/presentation/group_info_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/match/presentation/lineup/lineup_builder_screen.dart';
import '../../features/match/presentation/lineup/lineup_view_screen.dart';
import '../../features/match/presentation/match_create_screen.dart';
import '../../features/match/presentation/match_result_input_screen.dart';
import '../../features/match/presentation/match_screen.dart';
import '../../features/match/presentation/share/match_share_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/team/presentation/team_create_screen.dart';

part 'app_router.g.dart';

/// Supabase auth 상태 변화를 GoRouter에 전달하는 Listenable.
class _AuthStateNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _AuthStateNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter goRouter(Ref ref) {
  final authNotifier = _AuthStateNotifier();
  ref.onDispose(authNotifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) async {
      final client = Supabase.instance.client;
      final loggedIn = client.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/auth';
      final isOnboarding = state.matchedLocation == '/onboarding';

      if (!loggedIn && !isAuthRoute) return '/auth';
      if (!loggedIn && isOnboarding) return '/auth';
      if (loggedIn && isAuthRoute) {
        // 로그인 직후: 팀이 있는지 확인
        try {
          final userId = client.auth.currentUser!.id;
          final teams = await client
              .from('team_members')
              .select('team_id')
              .eq('player_id', userId)
              .limit(1);
          if (teams.isEmpty) return '/onboarding';
        } catch (_) {
          return '/onboarding';
        }
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/match',
        builder: (context, state) {
          final matchId = state.extra as String?;
          return MatchDetailScreen(matchId: matchId);
        },
      ),
      GoRoute(
        path: '/match/result-input',
        builder: (context, state) => const MatchResultInputScreen(),
      ),
      GoRoute(
        path: '/match/create',
        builder: (context, state) => const MatchCreateScreen(),
      ),
      GoRoute(
        path: '/match/lineup-builder',
        builder: (context, state) => const LineupBuilderScreen(),
      ),
      GoRoute(
        path: '/match/lineup-view',
        builder: (context, state) {
          final quarter = state.extra as int? ?? 0;
          return LineupViewScreen(initialQuarter: quarter);
        },
      ),
      GoRoute(
        path: '/match/share',
        builder: (context, state) => const MatchShareScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/team/create',
        builder: (context, state) => const TeamCreateScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final room = state.extra as ChatRoom;
          return ChatRoomScreen(room: room);
        },
      ),
      GoRoute(
        path: '/group-info',
        builder: (context, state) {
          final room = state.extra as ChatRoom;
          return GroupInfoScreen(room: room);
        },
      ),
    ],
  );
}
