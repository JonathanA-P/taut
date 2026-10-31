import 'package:flutter/services.dart' show rootBundle;

/// BISINDO Detection Modes supported by TAUT.
enum BisindoMode {
  kata('Kata Dasar', '23 Kata'),
  abjad('Eja Abjad', 'A–Z'),
  angka('Angka', '0–10');

  final String label;
  final String description;

  const BisindoMode(this.label, this.description);
}

/// BISINDO Labels Catalog for TAUT Motion-to-Sound AI Pipeline.
/// Matches Patuli SSD MobileNet V2 models (kata, abjad, angka).
class BisindoLabels {
  BisindoLabels._();

  /// 23 Kata Dasar BISINDO (Patuli kata.tflite)
  static const List<String> kata = [
    'Kiri',
    'Kanan',
    'Atas',
    'Bawah',
    'Kamu',
    'Saya',
    'Siapa',
    'Mana',
    'Menulis',
    'Terima Kasih',
    'Sama-sama',
    'Apa',
    'Betul',
    'Salah',
    'Lagi',
    'Laki-laki',
    'Perempuan',
    'Sahabat',
    'Hubungan',
    'Cinta',
    'Kuat',
    'Waktu',
    'Ingin',
  ];

  /// 26 Huruf Abjad BISINDO A–Z (abjad.tflite)
  static const List<String> abjad = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  /// 11 Digit Angka BISINDO 0–10 (angka.tflite)
  static const List<String> angka = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  /// Indonesian Spoken Digits corresponding to 0–10
  static const List<String> angkaSpoken = [
    'Nol',
    'Satu',
    'Dua',
    'Tiga',
    'Empat',
    'Lima',
    'Enam',
    'Tujuh',
    'Delapan',
    'Sembilan',
    'Sepuluh',
  ];

  /// Returns label list for the given mode.
  static List<String> getLabelsForMode(BisindoMode mode) {
    switch (mode) {
      case BisindoMode.kata:
        return kata;
      case BisindoMode.abjad:
        return abjad;
      case BisindoMode.angka:
        return angka;
    }
  }

  /// Maps an integer class index safely to a label string.
  /// Handles both 0-based and 1-based indexing from Object Detection models.
  static String resolveLabel(int classIndex, BisindoMode mode) {
    final list = getLabelsForMode(mode);
    if (classIndex >= 0 && classIndex < list.length) {
      return list[classIndex];
    } else if (classIndex > 0 && (classIndex - 1) < list.length) {
      return list[classIndex - 1];
    }
    return 'Label-$classIndex';
  }

  /// Resolves the spoken form of a label for text-to-speech.
  /// Converts numeric digits ('1', '2'...) to natural Indonesian words ('Satu', 'Dua'...).
  static String resolveSpokenLabel(String label, BisindoMode mode) {
    if (mode == BisindoMode.angka) {
      final idx = angka.indexOf(label);
      if (idx >= 0 && idx < angkaSpoken.length) {
        return angkaSpoken[idx];
      }
    }
    return label;
  }

  /// Asynchronously loads labels from asset file if available,
  /// falling back to built-in constants.
  static Future<List<String>> loadLabelsFromAsset(BisindoMode mode) async {
    final fileName = switch (mode) {
      BisindoMode.kata => 'labels_kata.txt',
      BisindoMode.abjad => 'labels_abjad.txt',
      BisindoMode.angka => 'labels_angka.txt',
    };

    try {
      final content = await rootBundle.loadString('assets/models/$fileName');
      final lines = content
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (lines.isNotEmpty) {
        return lines;
      }
    } catch (_) {
      // Fallback to built-in static lists
    }
    return getLabelsForMode(mode);
  }
}
