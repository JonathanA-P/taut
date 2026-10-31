import 'package:flutter_test/flutter_test.dart';
import 'package:taut/features/location_sharing/data/location_sharing_repository_impl.dart';

void main() {
  group('LocationSharingRepository Unit & Contract Test', () {
    test(
      'Can instantiate LocationSharingRepositoryImpl without active client',
      () {
        expect(() => LocationSharingRepositoryImpl(), returnsNormally);
      },
    );

    test('Unauthenticated user fails fast on createShare', () async {
      final repo = LocationSharingRepositoryImpl();
      expect(
        () => repo.createShare(
          recipientId: 'test-recipient-id',
          duration: const Duration(minutes: 30),
          initialLatitude: -7.9526,
          initialLongitude: 112.6144,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
