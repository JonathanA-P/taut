import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../domain/bisindo_labels.dart';

/// Loading status for on-device AI models.
enum ModelLoadStatus {
  idle,
  checkingCache,
  downloading,
  loadingInterpreter,
  ready,
  error,
}

/// Model state container for UI feedback.
class ModelState {
  final BisindoMode mode;
  final ModelLoadStatus status;
  final double downloadProgress; // 0.0 to 1.0
  final String? errorMessage;

  const ModelState({
    required this.mode,
    required this.status,
    this.downloadProgress = 0.0,
    this.errorMessage,
  });

  bool get isReady => status == ModelLoadStatus.ready;
  bool get isLoading =>
      status == ModelLoadStatus.downloading ||
      status == ModelLoadStatus.loadingInterpreter ||
      status == ModelLoadStatus.checkingCache;
}

/// Manages downloading, disk caching, and Interpreter lifecycle
/// for the three TAUT BISINDO TFLite models.
class BisindoModelManager {
  static final BisindoModelManager _instance = BisindoModelManager._internal();
  factory BisindoModelManager() => _instance;
  BisindoModelManager._internal();

  static const Map<BisindoMode, String> _modelUrls = {
    BisindoMode.kata:
        'https://storage.googleapis.com/patuli-storage/ML-Model/kata.tflite',
    BisindoMode.abjad:
        'https://storage.googleapis.com/patuli-storage/ML-Model/abjad.tflite',
    BisindoMode.angka:
        'https://storage.googleapis.com/patuli-storage/ML-Model/angka.tflite',
  };

  static const Map<BisindoMode, String> _assetPaths = {
    BisindoMode.kata: 'assets/models/kata.tflite',
    BisindoMode.abjad: 'assets/models/abjad.tflite',
    BisindoMode.angka: 'assets/models/angka.tflite',
  };

  static const Map<BisindoMode, String> _fileNames = {
    BisindoMode.kata: 'kata.tflite',
    BisindoMode.abjad: 'abjad.tflite',
    BisindoMode.angka: 'angka.tflite',
  };

  final Map<BisindoMode, Interpreter> _interpreters = {};
  final StreamController<ModelState> _stateController =
      StreamController<ModelState>.broadcast();

  Stream<ModelState> get stateStream => _stateController.stream;
  ModelState _currentState = const ModelState(
    mode: BisindoMode.kata,
    status: ModelLoadStatus.idle,
  );
  ModelState get currentState => _currentState;

  void _emit(ModelState state) {
    _currentState = state;
    if (!_stateController.isClosed) {
      _stateController.add(state);
    }
  }

  /// Whether the interpreter for [mode] is cached and ready in memory.
  bool isModeReady(BisindoMode mode) => _interpreters.containsKey(mode);

  /// Retrieves or initializes the [Interpreter] for [mode].
  Future<Interpreter> getInterpreter(BisindoMode mode) async {
    if (_interpreters.containsKey(mode)) {
      return _interpreters[mode]!;
    }

    _emit(ModelState(mode: mode, status: ModelLoadStatus.checkingCache));

    try {
      Uint8List? modelBytes;

      // 1. Try bundled Flutter assets first (fastest, offline)
      final assetPath = _assetPaths[mode]!;
      try {
        final byteData = await rootBundle.load(assetPath);
        modelBytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        debugPrint('[BisindoModelManager] Loaded $assetPath from assets.');
      } catch (assetError) {
        debugPrint(
          '[BisindoModelManager] Asset $assetPath not in bundle: $assetError',
        );
      }

      // 2. If not found in assets, check local disk cache
      if (modelBytes == null) {
        final cacheFile = await _getLocalModelFile(mode);
        if (await cacheFile.exists() && (await cacheFile.length()) > 1000000) {
          debugPrint(
            '[BisindoModelManager] Found cached model at ${cacheFile.path}',
          );
          modelBytes = await cacheFile.readAsBytes();
        } else {
          // 3. Fallback: Download from Patuli Cloud Storage
          modelBytes = await _downloadModel(mode, cacheFile);
        }
      }

      // Initialize TFLite Interpreter
      _emit(ModelState(mode: mode, status: ModelLoadStatus.loadingInterpreter));

      final options = InterpreterOptions()..threads = 4;
      final interpreter = Interpreter.fromBuffer(modelBytes, options: options);
      interpreter.allocateTensors();

      _interpreters[mode] = interpreter;

      _emit(ModelState(mode: mode, status: ModelLoadStatus.ready));

      return interpreter;
    } catch (e, stack) {
      debugPrint(
        '[BisindoModelManager] Failed loading model $mode: $e\n$stack',
      );
      _emit(
        ModelState(
          mode: mode,
          status: ModelLoadStatus.error,
          errorMessage: 'Gagal memuat model $mode: $e',
        ),
      );
      rethrow;
    }
  }

  /// Resolves the storage location for caching models on the device.
  Future<File> _getLocalModelFile(BisindoMode mode) async {
    final fileName = _fileNames[mode]!;
    Directory directory;
    try {
      directory = await getApplicationDocumentsDirectory();
    } catch (_) {
      try {
        directory = await getApplicationSupportDirectory();
      } catch (_) {
        directory = Directory.systemTemp;
      }
    }

    final modelsDir = Directory('${directory.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }

    return File('${modelsDir.path}/$fileName');
  }

  /// Downloads model over HTTP with byte progress tracking.
  Future<Uint8List> _downloadModel(BisindoMode mode, File targetFile) async {
    final url = _modelUrls[mode]!;
    debugPrint('[BisindoModelManager] Downloading $mode from $url ...');

    _emit(
      ModelState(
        mode: mode,
        status: ModelLoadStatus.downloading,
        downloadProgress: 0.05,
      ),
    );

    final client = http.Client();
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw HttpException(
          'HTTP Error ${response.statusCode} while fetching $url',
        );
      }

      final contentLength = response.contentLength ?? 11500000;
      final bytesBuilder = BytesBuilder(copy: false);
      int received = 0;

      await for (final chunk in response.stream) {
        bytesBuilder.add(chunk);
        received += chunk.length;

        final progress = (received / contentLength).clamp(0.0, 1.0);
        _emit(
          ModelState(
            mode: mode,
            status: ModelLoadStatus.downloading,
            downloadProgress: progress,
          ),
        );
      }

      final downloadedBytes = bytesBuilder.takeBytes();

      // Persist to disk for subsequent launches
      try {
        await targetFile.writeAsBytes(downloadedBytes, flush: true);
        debugPrint('[BisindoModelManager] Saved $mode to ${targetFile.path}');
      } catch (ioError) {
        debugPrint(
          '[BisindoModelManager] Warning: Failed saving to cache file: $ioError',
        );
      }

      return downloadedBytes;
    } finally {
      client.close();
    }
  }

  /// Disposes cached interpreters and releases memory.
  void dispose() {
    for (final interpreter in _interpreters.values) {
      interpreter.close();
    }
    _interpreters.clear();
    _stateController.close();
  }
}
