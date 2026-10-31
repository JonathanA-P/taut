import 'dart:math' as math;

class PlaceSearchMatcher {
  PlaceSearchMatcher._();

  static const Map<String, List<String>> _synonyms = {
    'rs': ['rumah sakit', 'hospital', 'rsud', 'rsia', 'klinik'],
    'rumah sakit': ['rs', 'hospital', 'rsud', 'rsia'],
    'rsud': ['rumah sakit', 'rs'],
    'rsia': ['rumah sakit', 'rs', 'ibu dan anak', 'ibu anak'],
    'rssa': ['rsud dr. saiful anwar', 'saiful anwar', 'rssa'],
    'pusk': ['puskesmas'],
    'puskes': ['puskesmas'],
    'puskesmas': ['pusk', 'puskes', 'pusat kesehatan masyarakat'],
    'apotik': ['apotek', 'farmasi', 'obat'],
    'apotek': ['apotik', 'farmasi', 'obat'],
    'farmasi': ['apotek', 'apotik'],
    'dokter': ['praktik', 'praktek', 'klinik', 'poliklinik'],
    'klinik': ['poliklinik', 'balai', 'dokter', 'praktik', 'praktek'],
    'ugd': ['rumah sakit', 'igd', 'darurat', 'emergency'],
    'igd': ['rumah sakit', 'ugd', 'darurat', 'emergency'],
  };

  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static double diceSimilarity(String s1, String s2) {
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    if (s1 == s2) return 1.0;
    if (s1.length < 2 || s2.length < 2) {
      return s1 == s2 ? 1.0 : (s1.contains(s2) || s2.contains(s1) ? 0.7 : 0.0);
    }

    final s1Bigrams = <String, int>{};
    for (var i = 0; i < s1.length - 1; i++) {
      final bg = s1.substring(i, i + 2);
      s1Bigrams[bg] = (s1Bigrams[bg] ?? 0) + 1;
    }

    var matches = 0;
    for (var i = 0; i < s2.length - 1; i++) {
      final bg = s2.substring(i, i + 2);
      final count = s1Bigrams[bg] ?? 0;
      if (count > 0) {
        matches++;
        s1Bigrams[bg] = count - 1;
      }
    }

    return (2.0 * matches) / ((s1.length - 1) + (s2.length - 1));
  }

  static int levenshteinDistance(String s1, String s2) {
    if (s1 == s2) return 0;
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> v0 = List<int>.generate(s2.length + 1, (i) => i);
    List<int> v1 = List<int>.filled(s2.length + 1, 0);

    for (var i = 0; i < s1.length; i++) {
      v1[0] = i + 1;
      for (var j = 0; j < s2.length; j++) {
        final cost = (s1[i] == s2[j]) ? 0 : 1;
        v1[j + 1] = math.min(
          v1[j] + 1,
          math.min(v0[j + 1] + 1, v0[j] + cost),
        );
      }
      for (var j = 0; j <= s2.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v0[s2.length];
  }

  static double levenshteinSimilarity(String s1, String s2) {
    final maxLen = math.max(s1.length, s2.length);
    if (maxLen == 0) return 1.0;
    final dist = levenshteinDistance(s1, s2);
    return math.max(0.0, 1.0 - (dist / maxLen));
  }

  static String extractAcronym(String input) {
    final words = normalize(input).split(' ').where((w) => w.isNotEmpty);
    final buffer = StringBuffer();
    for (final w in words) {
      buffer.write(w[0]);
    }
    return buffer.toString();
  }

  /// Calculates matching score (0.0 to 100.0) between [query] and a place.
  static double matchScore({
    required String query,
    required String name,
    String address = '',
    String category = '',
  }) {
    final cleanQuery = normalize(query);
    if (cleanQuery.isEmpty) return 100.0;

    final cleanName = normalize(name);
    final cleanAddress = normalize(address);
    final cleanCategory = normalize(category);

    // 1. Exact match on name
    if (cleanName == cleanQuery) {
      return 100.0;
    }

    // 2. Exact match on category or synonym
    if (cleanCategory == cleanQuery) {
      return 95.0;
    }

    // 3. Prefix match on name
    if (cleanName.startsWith(cleanQuery)) {
      return 92.0;
    }

    // 4. Substring match on name
    if (cleanName.contains(cleanQuery)) {
      return 88.0;
    }

    // 5. Acronym match (e.g. RSSA, RSIA)
    final acronym = extractAcronym(cleanName);
    if (acronym.length >= 2 && (acronym == cleanQuery || acronym.contains(cleanQuery))) {
      return 85.0;
    }

    // Check bracketed acronyms in raw name, e.g. "RSUD Dr. Saiful Anwar (RSSA)"
    final bracketMatch = RegExp(r'\(([^)]+)\)').firstMatch(name);
    if (bracketMatch != null) {
      final insideBracket = normalize(bracketMatch.group(1) ?? '');
      if (insideBracket == cleanQuery || insideBracket.contains(cleanQuery)) {
        return 88.0;
      }
    }

    // 6. Token-based matching (Multi-word query like "rs saiful", "puskesmas klojen")
    final queryTokens = cleanQuery.split(' ').where((t) => t.isNotEmpty).toList();
    final nameTokens = cleanName.split(' ').where((t) => t.isNotEmpty).toList();
    final addressTokens = cleanAddress.split(' ').where((t) => t.isNotEmpty).toList();

    var matchedTokensCount = 0;
    for (final qToken in queryTokens) {
      var tokenMatched = false;

      // Check direct name token match or prefix
      for (final nToken in nameTokens) {
        if (nToken == qToken || nToken.startsWith(qToken)) {
          tokenMatched = true;
          break;
        }
        // Typo tolerance per word (both tokens at least 4 chars and lengths similar)
        if (qToken.length >= 4 &&
            nToken.length >= 4 &&
            (qToken.length - nToken.length).abs() <= 2) {
          if (diceSimilarity(qToken, nToken) >= 0.72 ||
              levenshteinSimilarity(qToken, nToken) >= 0.75) {
            tokenMatched = true;
            break;
          }
        }
      }

      // Check category match
      if (!tokenMatched && (cleanCategory.contains(qToken) || qToken.contains(cleanCategory))) {
        tokenMatched = true;
      }

      // Check synonym match
      if (!tokenMatched) {
        final synList = _synonyms[qToken] ?? [];
        for (final syn in synList) {
          if (cleanName.contains(syn) || cleanCategory.contains(syn)) {
            tokenMatched = true;
            break;
          }
        }
      }

      // Check address token match
      if (!tokenMatched) {
        for (final aToken in addressTokens) {
          if (aToken == qToken || aToken.startsWith(qToken)) {
            tokenMatched = true;
            break;
          }
        }
      }

      if (tokenMatched) {
        matchedTokensCount++;
      }
    }

    if (queryTokens.isNotEmpty && matchedTokensCount == queryTokens.length) {
      return 82.0 + (cleanName.contains(queryTokens.first) ? 5.0 : 0.0);
    } else if (queryTokens.length > 1 && matchedTokensCount > 0) {
      final partialRatio = matchedTokensCount / queryTokens.length;
      if (partialRatio >= 0.5) {
        return 50.0 * partialRatio + 20.0;
      }
    }

    // 7. Full-string fuzzy similarity (for long queries/typos like "saful anwar")
    if (cleanQuery.length >= 5) {
      final diceName = diceSimilarity(cleanQuery, cleanName);
      final levName = levenshteinSimilarity(cleanQuery, cleanName);
      final bestNameSim = math.max(diceName, levName);

      if (bestNameSim >= 0.65) {
        return 40.0 + (bestNameSim * 45.0); // 69 to 85
      }
    }

    // 8. Word-level best similarity for single typos
    var bestWordSim = 0.0;
    for (final qToken in queryTokens) {
      if (qToken.length < 4) continue;
      for (final nToken in nameTokens) {
        if (nToken.length < 4 || (qToken.length - nToken.length).abs() > 2) continue;
        final sim = math.max(diceSimilarity(qToken, nToken), levenshteinSimilarity(qToken, nToken));
        if (sim > bestWordSim) {
          bestWordSim = sim;
        }
      }
    }

    if (bestWordSim >= 0.75) {
      return 35.0 + (bestWordSim * 40.0);
    }

    // 9. Address match
    if (cleanAddress.contains(cleanQuery)) {
      return 65.0;
    }

    return 0.0;
  }
}
