import 'package:flutter_test/flutter_test.dart';
import 'package:taut/core/utils/place_search_matcher.dart';

void main() {
  group('PlaceSearchMatcher Unit Tests', () {
    const facilityName = 'RSUD Dr. Saiful Anwar (RSSA)';
    const facilityAddress = 'Jl. Jaksa Agung Suprapto No. 2, Klojen, Kota Malang';
    const facilityCategory = 'Rumah Sakit';

    test('Exact and substring match returns high score', () {
      final exactScore = PlaceSearchMatcher.matchScore(
        query: 'RSUD Dr. Saiful Anwar',
        name: facilityName,
        address: facilityAddress,
        category: facilityCategory,
      );
      expect(exactScore, greaterThanOrEqualTo(85.0));

      final substringScore = PlaceSearchMatcher.matchScore(
        query: 'Saiful',
        name: facilityName,
        address: facilityAddress,
        category: facilityCategory,
      );
      expect(substringScore, greaterThanOrEqualTo(85.0));
    });

    test('Acronym match works for RSSA', () {
      final score = PlaceSearchMatcher.matchScore(
        query: 'rssa',
        name: facilityName,
        address: facilityAddress,
        category: facilityCategory,
      );
      expect(score, greaterThanOrEqualTo(80.0));
    });

    test('Typo tolerance matches via similarity (e.g. saful anwar)', () {
      final score = PlaceSearchMatcher.matchScore(
        query: 'saful anwar',
        name: facilityName,
        address: facilityAddress,
        category: facilityCategory,
      );
      expect(score, greaterThanOrEqualTo(60.0));
    });

    test('Address token matches (e.g. Klojen)', () {
      final score = PlaceSearchMatcher.matchScore(
        query: 'Klojen',
        name: facilityName,
        address: facilityAddress,
        category: facilityCategory,
      );
      expect(score, greaterThanOrEqualTo(65.0));
    });

    test('Synonym matches (e.g. rs -> Rumah Sakit)', () {
      final score = PlaceSearchMatcher.matchScore(
        query: 'rs',
        name: 'Pusat Medis Malang',
        address: 'Jl. Ijen',
        category: 'Rumah Sakit',
      );
      expect(score, greaterThanOrEqualTo(70.0));
    });

    test('Unrelated query returns 0 score', () {
      final score = PlaceSearchMatcher.matchScore(
        query: 'Bengkel Motor',
        name: facilityName,
        address: facilityAddress,
        category: facilityCategory,
      );
      expect(score, lessThan(35.0));
    });
  });
}
