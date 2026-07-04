import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../shared/models.dart';

final supabaseProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Raw auth state (session changes rebuild the router redirect).
final authStateProvider = StreamProvider<AuthState>(
    (ref) => ref.watch(supabaseProvider).auth.onAuthStateChange);

final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

/// The signed-in user's profile row.
final myProfileProvider = FutureProvider<AppUser?>((ref) async {
  final uid = ref.watch(currentUserIdProvider);
  if (uid == null) return null;
  final data = await ref
      .watch(supabaseProvider)
      .from('users')
      .select()
      .eq('id', uid)
      .maybeSingle();
  return data == null ? null : AppUser.fromJson(data);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  SupabaseClient get _sb => ref.read(supabaseProvider);

  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await _sb.auth.signUp(email: email, password: password, data: {
      'username': username.trim().toLowerCase(),
      'display_name': username.trim(),
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _sb.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() => _sb.auth.signOut();
}

final authControllerProvider = Provider((ref) => AuthController(ref));
