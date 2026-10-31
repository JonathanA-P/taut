import '../../../shared/models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<UserProfile> signIn({required String email, required String password});

  Future<void> signOut();

  Future<UserProfile?> getCurrentUser();

  Stream<UserProfile?> authStateChanges();
}

