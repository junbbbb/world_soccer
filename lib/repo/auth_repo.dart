import 'package:supabase_flutter/supabase_flutter.dart' show AuthResponse, User;

/// 인증 저장소 인터페이스.
abstract class AuthRepo {
  /// 현재 로그인된 사용자.
  User? get currentUser;

  /// 이메일+비밀번호 회원가입.
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  });

  /// 이메일+비밀번호 로그인.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  });

  /// 로그아웃.
  Future<void> signOut();

  /// 네이티브 Google 로그인.
  Future<AuthResponse> signInWithGoogle();

  /// 소셜 로그인 (Kakao 등 — 브라우저 기반).
  Future<bool> signInWithOAuth(String provider);

  /// 개발용 익명 로그인 (프로덕션에서는 숨김).
  Future<AuthResponse> signInAnonymously();

  /// 인증 상태 변화 스트림.
  Stream<User?> onAuthStateChange();
}
