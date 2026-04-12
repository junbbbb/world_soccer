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
import '../../features/match/presentation/match_create_screen.dart';
import '../../features/match/presentation/match_result_input_screen.dart';
import '../../features/match/presentation/match_screen.dart';
import '../../features/match/presentation/share/match_share_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = Supabase.instance.client.auth.currentUser != null;
      final isAuthRoute = state.matchedLocation == '/auth';

      if (!loggedIn && !isAuthRoute) return '/auth';
      if (loggedIn && isAuthRoute) return '/';
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
        builder: (context, state) => const MatchDetailScreen(),
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
        path: '/match/share',
        builder: (context, state) => const MatchShareScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
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
