import '../domain/bisindo_recognition_service.dart';
import '../domain/gesture_result.dart';

/// Foundation implementation of [BisindoRecognitionService] for Stage 01.
/// Does NOT invent fake predictions. Returns [GestureResult.unknown]
/// until Roganda trains and connects the TFLite model in Stage 02.
class BisindoRecognitionServiceImpl implements BisindoRecognitionService {
  bool _isLoaded = false;

  @override
  bool get isModelLoaded => _isLoaded;

  @override
  Future<void> initializeModel() async {
    // Stage 01: Model asset is pending training and quantization.
    _isLoaded = false;
  }

  @override
  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks) async {
    // Never fabricate translations. Return unknown until model is connected.
    return GestureResult.unknown(0.0);
  }

  @override
  List<String> getSupportedVocabulary() {
    // Initial planned vocabulary for isolated word testing in Stage 02
    return const [
      'HALO',
      'TERIMA KASIH',
      'TOLONG',
      'SAMA-SAMA',
      'MAAF',
      'RUMAH SAKIT',
      'DOKTER',
      'DARURAT',
    ];
  }

  @override
  void dispose() {
    _isLoaded = false;
  }
}
