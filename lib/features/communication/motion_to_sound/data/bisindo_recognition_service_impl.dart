import '../domain/bisindo_recognition_service.dart';
import '../domain/gesture_result.dart';

class BisindoRecognitionServiceImpl implements BisindoRecognitionService {
  bool _isLoaded = false;

  @override
  bool get isModelLoaded => _isLoaded;

  @override
  Future<void> initializeModel() async {
    _isLoaded = false;
  }

  @override
  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks) async {
    return GestureResult.unknown(0.0);
  }

  @override
  List<String> getSupportedVocabulary() {
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

