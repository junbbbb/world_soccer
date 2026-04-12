import 'package:supabase_flutter/supabase_flutter.dart';

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
  Stream<User?> onAuthStateChange() {
    return _client.auth.onAuthStateChange.map((event) => event.session?.user);
  }
}
