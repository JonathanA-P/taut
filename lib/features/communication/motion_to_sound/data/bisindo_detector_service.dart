import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../domain/bisindo_labels.dart';
import '../domain/bisindo_recognition_service.dart';
import '../domain/gesture_result.dart';
import 'bisindo_model_manager.dart';
import 'camera_image_converter.dart';

/// Normalized bounding box coordinates [ymin, xmin, ymax, xmax].
class BoundingBox {
  final double ymin;
  final double xmin;
  final double ymax;
  final double xmax;

  const BoundingBox({
    required this.ymin,
    required this.xmin,
    required this.ymax,
    required this.xmax,
  });

  bool get isValid => (ymax > ymin) && (xmax > xmin);
}

/// Rich inference event emitted by [BisindoDetectorService].
class BisindoDetectionEvent {
  final GestureResult result;
  final BisindoMode mode;
  final BoundingBox? boundingBox;
  final bool isValidatedToken; // True if passed stability filter
  final bool isProlongedUnrecognized;

  const BisindoDetectionEvent({
    required this.result,
    required this.mode,
    this.boundingBox,
    this.isValidatedToken = false,
    this.isProlongedUnrecognized = false,
  });
}

/// Core On-Device AI inference & stabilization engine for BISINDO.
/// Implements [BisindoRecognitionService].
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
class BisindoDetectorService implements BisindoRecognitionService {
  final BisindoModelManager _modelManager;

  BisindoMode _currentMode = BisindoMode.kata;
  Interpreter? _activeInterpreter;

  bool _isProcessing = false;
  int _lastInferenceTimeMs = 0;

  // Throttling: 3-4 FPS -> 280-330 ms interval
  static const int minFrameIntervalMs = 280;

  // Confidence & Stability criteria
  // 0.48 threshold gives optimal responsiveness for mobile hand signs
  static const double confidenceThreshold = 0.48;
  static const int requiredConsecutiveCycles = 2; // 2 consecutive cycles for stability
  static const int tokenCooldownMs =
      1200; // Cooldown before repeating same token
  static const int unrecognizedTimeoutMs =
      3500; // 3.5s of low confidence triggers warning

  String _candidateLabel = '';
  int _consecutiveHits = 0;
  String _lastValidatedToken = '';
  int _lastValidatedTokenTimeMs = 0;

  int _firstUnrecognizedTimeMs = 0;
  bool _isProlongedUnrecognized = false;

  final StreamController<BisindoDetectionEvent> _detectionStreamController =
      StreamController<BisindoDetectionEvent>.broadcast();

  Stream<BisindoDetectionEvent> get detectionStream =>
      _detectionStreamController.stream;

  BisindoDetectorService({BisindoModelManager? modelManager})
    : _modelManager = modelManager ?? BisindoModelManager();

  BisindoMode get currentMode => _currentMode;

  @override
  bool get isModelLoaded => _activeInterpreter != null;

  @override
  Future<void> initializeModel({
    BisindoMode initialMode = BisindoMode.kata,
  }) async {
    _currentMode = initialMode;
    _activeInterpreter = await _modelManager.getInterpreter(_currentMode);
  }

  /// Switches active BISINDO model (Kata, Abjad, or Angka) dynamically.
  Future<void> switchMode(BisindoMode newMode) async {
    if (_currentMode == newMode && _activeInterpreter != null) return;

    _currentMode = newMode;
    _candidateLabel = '';
    _consecutiveHits = 0;
    _firstUnrecognizedTimeMs = 0;
    _isProlongedUnrecognized = false;

    _activeInterpreter = await _modelManager.getInterpreter(_currentMode);
    debugPrint('[BisindoDetectorService] Switched mode to $newMode');
  }

  /// Processes live camera frame from [CameraImage].
  /// Enforces frame throttling (3-4 FPS) and on-device privacy guarantee.
  /// [sensorOrientation] accounts for Android/iOS device rotation.
  Future<BisindoDetectionEvent?> processCameraImage(
    CameraImage cameraImage, {
    bool isFrontCamera = false,
    int sensorOrientation = 0,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    // 1. Frame throttling: Process 3–4 frames per second
    if (_isProcessing || (now - _lastInferenceTimeMs < minFrameIntervalMs)) {
      return null;
    }

    if (_activeInterpreter == null) {
      return null;
    }

    _isProcessing = true;
    _lastInferenceTimeMs = now;

    try {
      // 2. Fast RGB conversion to 320x320 Float32 tensor with sensor orientation
      final inputTensor = CameraImageConverter.convertToRgbTensor(
        cameraImage,
        isFrontCamera: isFrontCamera,
        sensorOrientation: sensorOrientation,
      );

      // 3. Run inference with dynamic tensor shape checking
      final detection = await _runInferenceOnTensor(inputTensor);

      // 4. Apply stability and prolonged unrecognized validation
      final event = _evaluateDetection(detection, now);
      if (!_detectionStreamController.isClosed) {
        _detectionStreamController.add(event);
      }
      return event;
    } catch (e, stack) {
      debugPrint('[BisindoDetectorService] Inference error: $e\n$stack');
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Future<GestureResult> recognizeGesture(dynamic frameOrLandmarks) async {
    if (frameOrLandmarks is CameraImage) {
      final event = await processCameraImage(frameOrLandmarks);
      return event?.result ?? GestureResult.unknown(0.0);
    } else if (frameOrLandmarks is Float32List) {
      final raw = await _runInferenceOnTensor(frameOrLandmarks);
      return raw.result;
    }
    return GestureResult.unknown(0.0);
  }

  /// Runs TFLite interpreter, supporting both 4-tensor Object Detection
  /// (SSD MobileNet V2) and 1-tensor Classification.
  Future<_RawDetection> _runInferenceOnTensor(Float32List inputTensor) async {
    final interpreter = _activeInterpreter!;
    final outputTensors = interpreter.getOutputTensors();

    if (outputTensors.length == 4) {
      return _runObjectDetection(interpreter, outputTensors, inputTensor);
    } else {
      return _runClassification(interpreter, outputTensors, inputTensor);
    }
  }

  /// Standard SSD Object Detection handling:
  /// boxes [1, 10, 4], classes [1, 10], scores [1, 10], num_detections [1]
  _RawDetection _runObjectDetection(
    Interpreter interpreter,
    List<Tensor> outputTensors,
    Float32List inputTensor,
  ) {
    int scoresIdx = -1;
    int boxesIdx = -1;
    int numDetectionsIdx = -1;
    int classesIdx = -1;

    // 1. Unambiguous shape-based resolution
    for (int i = 0; i < outputTensors.length; i++) {
      final shape = outputTensors[i].shape;
      if (shape.length == 3 && shape[2] == 4) {
        boxesIdx = i;
      } else if (shape.length == 1 && shape[0] == 1) {
        numDetectionsIdx = i;
      }
    }

    // 2. Semantic name resolution & TF model conventions
    for (int i = 0; i < outputTensors.length; i++) {
      final name = outputTensors[i].name;
      final lower = name.toLowerCase();

      if (lower.contains('box') || lower.contains('loc')) {
        boxesIdx = i;
      } else if (lower.contains('class') || lower.contains('cat')) {
        classesIdx = i;
      } else if (lower.contains('score')) {
        scoresIdx = i;
      } else if (lower.contains('num')) {
        numDetectionsIdx = i;
      } else if (name.contains('StatefulPartitionedCall')) {
        // TF2 SavedModel Object Detection API output mapping:
        // StatefulPartitionedCall:1 -> detection_scores
        // StatefulPartitionedCall:3 -> detection_boxes
        // StatefulPartitionedCall:0 -> num_detections
        // StatefulPartitionedCall:2 -> detection_classes
        if (name.contains(':1')) {
          scoresIdx = i;
        } else if (name.contains(':3')) {
          boxesIdx = i;
        } else if (name.contains(':0')) {
          numDetectionsIdx = i;
        } else if (name.contains(':2')) {
          classesIdx = i;
        }
      } else if (lower.contains('postprocess')) {
        // TF1 TFLite_Detection_PostProcess mapping:
        // :0 -> boxes, :1 -> classes, :2 -> scores, :3 -> num
        if (name.contains(':0')) {
          boxesIdx = i;
        } else if (name.contains(':1')) {
          classesIdx = i;
        } else if (name.contains(':2')) {
          scoresIdx = i;
        } else if (name.contains(':3')) {
          numDetectionsIdx = i;
        }
      }
    }

    // 3. Fallbacks to default TF2 SavedModel order if any index is still unassigned
    if (scoresIdx == -1) scoresIdx = 0;
    if (boxesIdx == -1) boxesIdx = 1;
    if (numDetectionsIdx == -1) numDetectionsIdx = 2;
    if (classesIdx == -1) classesIdx = 3;

    final boxesBuffer = Float32List(10 * 4);
    final classesBuffer = Float32List(10);
    final scoresBuffer = Float32List(10);
    final numBuffer = Float32List(1);

    final outputs = <int, Object>{
      boxesIdx: boxesBuffer.buffer,
      classesIdx: classesBuffer.buffer,
      scoresIdx: scoresBuffer.buffer,
      numDetectionsIdx: numBuffer.buffer,
    };

    // Run inference with normalized raw input bytes
    interpreter.runForMultipleInputs([inputTensor.buffer], outputs);

    // Find highest scoring detection
    double topScore = 0.0;
    int topClassIdx = -1;
    int topBoxOffset = 0;

    final numDetections = math.min(10, numBuffer[0].round().clamp(1, 10));

    for (int i = 0; i < numDetections; i++) {
      final score = scoresBuffer[i];
      if (score > topScore) {
        topScore = score;
        topClassIdx = classesBuffer[i].round();
        topBoxOffset = i * 4;
      }
    }

    BoundingBox? boundingBox;
    if (topClassIdx >= 0) {
      boundingBox = BoundingBox(
        ymin: boxesBuffer[topBoxOffset].clamp(0.0, 1.0),
        xmin: boxesBuffer[topBoxOffset + 1].clamp(0.0, 1.0),
        ymax: boxesBuffer[topBoxOffset + 2].clamp(0.0, 1.0),
        xmax: boxesBuffer[topBoxOffset + 3].clamp(0.0, 1.0),
      );
    }

    if (topScore >= confidenceThreshold && topClassIdx >= 0) {
      final label = BisindoLabels.resolveLabel(topClassIdx, _currentMode);
      return _RawDetection(
        result: GestureResult.recognized(label: label, confidence: topScore),
        boundingBox: boundingBox,
      );
    }

    return _RawDetection(
      result: GestureResult.unknown(topScore),
      boundingBox: boundingBox,
    );
  }

  /// Single output tensor classification (probabilities vector).
  _RawDetection _runClassification(
    Interpreter interpreter,
    List<Tensor> outputTensors,
    Float32List inputTensor,
  ) {
    final numClasses = BisindoLabels.getLabelsForMode(_currentMode).length;
    final probsBuffer = Float32List(numClasses);

    interpreter.run(inputTensor.buffer, probsBuffer.buffer);

    int maxIdx = 0;
    double maxScore = probsBuffer[0];
    for (int i = 1; i < numClasses; i++) {
      if (probsBuffer[i] > maxScore) {
        maxScore = probsBuffer[i];
        maxIdx = i;
      }
    }

    if (maxScore >= confidenceThreshold) {
      final label = BisindoLabels.resolveLabel(maxIdx, _currentMode);
      return _RawDetection(
        result: GestureResult.recognized(label: label, confidence: maxScore),
      );
    }

    return _RawDetection(result: GestureResult.unknown(maxScore));
  }

  /// Applies temporal stability filtering (2 consecutive cycles) and
  /// checks prolonged unrecognized duration.
  BisindoDetectionEvent _evaluateDetection(_RawDetection raw, int now) {
    bool isValidatedToken = false;

    if (raw.result.isRecognized) {
      // Reset prolonged unrecognized timer
      _firstUnrecognizedTimeMs = 0;
      _isProlongedUnrecognized = false;

      if (raw.result.label == _candidateLabel) {
        _consecutiveHits++;
      } else {
        _candidateLabel = raw.result.label;
        _consecutiveHits = 1;
      }

      // If stabilized across required consecutive cycles
      if (_consecutiveHits >= requiredConsecutiveCycles) {
        // Debounce: Avoid rapid duplicate tokens
        final isDifferentToken = raw.result.label != _lastValidatedToken;
        final isCooldownPassed =
            (now - _lastValidatedTokenTimeMs) > tokenCooldownMs;

        if (isDifferentToken || isCooldownPassed) {
          isValidatedToken = true;
          _lastValidatedToken = raw.result.label;
          _lastValidatedTokenTimeMs = now;
          _consecutiveHits = 0; // Reset after emission
        }
      }
    } else {
      // Unknown / low confidence
      _consecutiveHits = 0;

      if (_firstUnrecognizedTimeMs == 0) {
        _firstUnrecognizedTimeMs = now;
      } else if (now - _firstUnrecognizedTimeMs > unrecognizedTimeoutMs) {
        _isProlongedUnrecognized = true;
      }
    }

    return BisindoDetectionEvent(
      result: raw.result,
      mode: _currentMode,
      boundingBox: raw.boundingBox,
      isValidatedToken: isValidatedToken,
      isProlongedUnrecognized: _isProlongedUnrecognized,
    );
  }

  @override
  List<String> getSupportedVocabulary() {
    return BisindoLabels.getLabelsForMode(_currentMode);
  }

  @override
  void dispose() {
    _detectionStreamController.close();
    _activeInterpreter = null;
  }
}

class _RawDetection {
  final GestureResult result;
  final BoundingBox? boundingBox;

  const _RawDetection({required this.result, this.boundingBox});
}
