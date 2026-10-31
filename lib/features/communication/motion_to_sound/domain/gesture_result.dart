class GestureResult {
  final String label;
  final double confidence;
  final bool isRecognized;
  final DateTime timestamp;

  const GestureResult({
    required this.label,
    required this.confidence,
    required this.isRecognized,
    required this.timestamp,
  });

  factory GestureResult.unknown([double confidence = 0.0]) {
    return GestureResult(
      label: 'Gerakan Tidak Dikenal',
      confidence: confidence,
      isRecognized: false,
      timestamp: DateTime.now(),
    );
  }

  factory GestureResult.recognized({
    required String label,
    required double confidence,
  }) {
    return GestureResult(
      label: label,
      confidence: confidence,
      isRecognized: true,
      timestamp: DateTime.now(),
    );
  }

  @override
  String toString() =>
      'GestureResult(label: $label, confidence: ${(confidence * 100).toStringAsFixed(1)}%, isRecognized: $isRecognized)';
}

