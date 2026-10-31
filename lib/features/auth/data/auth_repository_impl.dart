import 'dart:async';

import '../../../core/errors/app_exception.dart';
import '../../../shared/models/user_profile.dart';
import '../domain/auth_repository.dart';

/// Foundation implementation of [AuthRepository] for Stage 01.
/// Real implementation using `supabase_flutter` will be completed by Alfredo in
/// branch `feature/supabase-auth-friends`.
class AuthRepositoryImpl implements AuthRepository {
  final _controller = StreamController<UserProfile?>.broadcast();
  UserProfile? _currentUser;

  AuthRepositoryImpl();

  @override
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Stage 01 contract stub - throws until Alfredo wires Supabase client
    throw const AuthException(
      message: 'Supabase Auth belum dihubungkan (Stage 01 Foundation).',
      code: 'AUTH_NOT_IMPLEMENTED',
    );
  }

  @override
  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    throw const AuthException(
      message: 'Supabase Auth belum dihubungkan (Stage 01 Foundation).',
      code: 'AUTH_NOT_IMPLEMENTED',
    );
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Stream<UserProfile?> authStateChanges() {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
