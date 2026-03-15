import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/chat/presentation/chat_room_screen.dart';
import '../../features/chat/presentation/chat_tab.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/match/presentation/match_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/match',
        builder: (context, state) => const MatchDetailScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final room = state.extra as ChatRoom;
          return ChatRoomScreen(room: room);
        },
      ),
    ],
  );
}
