import 'package:flutter_test/flutter_test.dart';
import 'package:taut/features/auth/data/auth_repository_impl.dart';

void main() {
  group('AuthRepository Unit & Contract Test', () {
    test('Can instantiate AuthRepositoryImpl', () {
      // Instance without active Supabase client will throw on invocation or work with client
      expect(() => AuthRepositoryImpl(), returnsNormally);
    });
  });
}
