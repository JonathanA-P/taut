import 'gesture_result.dart';

abstract class BisindoRecognitionService {
  Future<void> initializeModel();

  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks);

  List<String> getSupportedVocabulary();

  bool get isModelLoaded;

  void dispose();
}

