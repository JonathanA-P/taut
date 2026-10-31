import '../domain/bisindo_labels.dart';
import '../domain/bisindo_recognition_service.dart';
import '../domain/gesture_result.dart';
import 'bisindo_detector_service.dart';

/// Concrete implementation of [BisindoRecognitionService] for Stage 02.
/// Fully connects on-device TFLite inference via [BisindoDetectorService].
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
class BisindoRecognitionServiceImpl implements BisindoRecognitionService {
  final BisindoDetectorService _detectorService;

  BisindoRecognitionServiceImpl({BisindoDetectorService? detectorService})
    : _detectorService = detectorService ?? BisindoDetectorService();

  BisindoDetectorService get detectorService => _detectorService;

  @override
  bool get isModelLoaded => _detectorService.isModelLoaded;

  @override
  Future<void> initializeModel({BisindoMode mode = BisindoMode.kata}) async {
    await _detectorService.initializeModel(initialMode: mode);
  }

  @override
  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks) async {
    return _detectorService.recognizeGesture(frameOrLandmarks);
  }

  @override
  List<String> getSupportedVocabulary() {
    return _detectorService.getSupportedVocabulary();
  }

  @override
  void dispose() {
    _detectorService.dispose();
  }
}
