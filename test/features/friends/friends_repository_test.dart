import 'package:flutter_test/flutter_test.dart';
import 'package:taut/features/friends/data/friends_repository_impl.dart';

void main() {
  group('FriendsRepository Unit & Contract Test', () {
    test('Can instantiate FriendsRepositoryImpl without active client', () {
      expect(() => FriendsRepositoryImpl(), returnsNormally);
    });

    test('Unauthenticated user fails fast when creating invite', () async {
      final repo = FriendsRepositoryImpl();
      expect(
        () => repo.createInvite(validity: const Duration(hours: 1)),
        throwsA(isA<Exception>()),
      );
    });
  });
}
