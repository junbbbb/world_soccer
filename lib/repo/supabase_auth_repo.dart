import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import 'auth_repo.dart';

/// AuthRepo의 Supabase 구현체.
class SupabaseAuthRepo implements AuthRepo {
  final SupabaseClient _client;

  SupabaseAuthRepo(this._client);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
  }

  @override
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: SupabaseConfig.googleIosClientId,
      serverClientId: SupabaseConfig.googleWebClientId,
    );

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw const AuthException('Google 로그인이 취소되었습니다.');
    }

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    final accessToken = googleAuth.accessToken;

    if (idToken == null) {
      throw const AuthException('Google 인증 토큰을 받지 못했습니다.');
    }

    return _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  @override
  Future<bool> signInWithOAuth(String provider) {
    final oauthProvider = switch (provider) {
      'kakao' => OAuthProvider.kakao,
      _ => throw ArgumentError('Unsupported provider: $provider'),
    };

    return _client.auth.signInWithOAuth(
      oauthProvider,
      redirectTo: 'io.supabase.worldsoccer://login-callback',
      authScreenLaunchMode: LaunchMode.inAppBrowserView,
      scopes: provider == 'kakao' ? 'profile_nickname profile_image' : null,
    );
  }

  @override
  Future<AuthResponse> signInAnonymously() {
    return _client.auth.signInAnonymously();
  }

  @override
  Stream<User?> onAuthStateChange() {
    return _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }
}
