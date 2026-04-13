/// Supabase 연결 설정.

class SupabaseConfig {
  SupabaseConfig._();

  static const url = 'https://bquqdsdlgfnncljxzlhv.supabase.co';
  static const anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
      'eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJxdXFkc2RsZ2ZubmNsanh6bGh2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzU5NzcxODIsImV4cCI6MjA5MTU1MzE4Mn0.'
      'i_Ahq4edoDSz3jjnviNCselfYQSw7ZYzvBT5YMnIMrg';

  /// Google OAuth Client IDs (Google Cloud Console에서 발급).
  /// Web client ID — Supabase Dashboard의 Google provider에도 동일하게 설정.
  static const googleWebClientId = '1049253977873-sfi7kpvu49cdfi46c7hil3v5rpipb294.apps.googleusercontent.com';

  /// iOS client ID — Google Cloud Console에서 iOS 앱용으로 생성.
  static const googleIosClientId = '1049253977873-1sa4vnsjtr76c01536u0eppogatpbvfd.apps.googleusercontent.com';
}
