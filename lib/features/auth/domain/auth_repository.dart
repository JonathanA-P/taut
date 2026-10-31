import '../../../shared/models/user_profile.dart';

/// Integration Contract: Authentication Repository
/// Owner: Alfredo Jonathan Purba (Team Lead & Backend Architect)
///
/// Responsibilities:
/// - Supabase Auth lifecycle management (sign up, sign in, sign out)
/// - Syncing auth credentials with public.profiles
/// - Exposing reactive auth state changes
abstract class AuthRepository {
  /// Signs up a new user with email and password, creating a profile row.
  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Signs in an existing user with email and password.
  Future<UserProfile> signIn({required String email, required String password});

  /// Signs out the current user and clears session tokens.
  Future<void> signOut();

  /// Gets the currently authenticated user profile, or null if unauthenticated.
  Future<UserProfile?> getCurrentUser();

  /// Stream of authentication state changes.
  Stream<UserProfile?> authStateChanges();
}
