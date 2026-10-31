import 'gesture_result.dart';

/// Integration Contract: BISINDO Sign Recognition Service
/// Owner: Roganda Tua Tampubolon (Communication AI Lead)
/// Branch: feature/motion-to-sound
///
/// Responsibilities:
/// - Loading TFLite / ONNX inference model assets
/// - Ingestion of hand landmarks extracted from camera feed
/// - Running classifier on feature vectors
/// - Thresholding predictions to avoid fake or false-positive translations
/// - Exposing supported vocabulary manifest
abstract class BisindoRecognitionService {
  /// Loads the inference model and label map into memory.
  Future<void> initializeModel();

  /// Runs inference against extracted landmark coordinates.
  /// Returns [GestureResult.unknown] if below confidence threshold or unmapped.
  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks);

  /// Returns the current list of verified, supported vocabulary words.
  List<String> getSupportedVocabulary();

  /// Whether the AI inference engine is ready.
  bool get isModelLoaded;

  /// Releases model and native tensor resources.
  void dispose();
}
