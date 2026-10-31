import '../domain/bisindo_labels.dart';
import '../domain/bisindo_recognition_service.dart';
import '../domain/gesture_result.dart';
import 'bisindo_detector_service.dart';

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
