import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Internal helper that safely returns the client or null if Supabase
  // has not been initialized yet (e.g. during hot reload in dev tools).
  static SupabaseClient? get _maybeClient {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Non-nullable client for places that are only called after init.
  static SupabaseClient get client {
    final c = _maybeClient;
    if (c == null) {
      throw StateError('Supabase has not been initialized');
    }
    return c;
  }

  static User? get currentUser => _maybeClient?.auth.currentUser;

  /// Nullable stream so callers can safely skip wiring listeners when
  /// Supabase is not ready (avoids assertion during hot reload).
  static Stream<AuthState>? get onAuthStateChange =>
      _maybeClient?.auth.onAuthStateChange;

  static Future<void> signInWithGoogle() async {
    await client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.cricstatz.cricstatz://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
