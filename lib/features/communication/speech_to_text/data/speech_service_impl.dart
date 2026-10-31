import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../domain/speech_service.dart';
import '../domain/speech_state.dart';

/// Production implementation of [SpeechService] using `speech_to_text` plugin.
/// Designed for Teman Tuli accessibility in TAUT.
/// Supports continuous listening, auto-recovery across speech pauses,
/// and real-time streaming in Indonesian (`id_ID`).
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
class SpeechServiceImpl implements SpeechService {
  final SpeechToText _speechToText;
  final StreamController<SpeechRecognitionState> _stateController =
      StreamController<SpeechRecognitionState>.broadcast();

  bool _isAvailable = false;
  bool _isContinuousActive = false;
  bool _isInitializing = false;
  void Function(String text, bool isFinal)? _currentOnResult;
  String _currentLanguage = 'id_ID';

  SpeechServiceImpl({SpeechToText? speechToText})
    : _speechToText = speechToText ?? SpeechToText() {
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.uninitialized),
    );
  }

  @override
  Future<bool> initialize() async {
    if (_isAvailable) return true;
    if (_isInitializing) return false;

    _isInitializing = true;
    try {
      _isAvailable = await _speechToText.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: kDebugMode,
      );

      _stateController.add(
        SpeechRecognitionState(
          status: _isAvailable ? SpeechStatus.ready : SpeechStatus.error,
          errorMessage: _isAvailable ? null : 'Fitur pengenalan suara tidak tersedia atau izin mikrofon belum diberikan.',
        ),
      );
      return _isAvailable;
    } catch (e) {
      debugPrint('Speech recognition initialization error: $e');
      _isAvailable = false;
      _stateController.add(
        SpeechRecognitionState(
          status: SpeechStatus.error,
          errorMessage: e.toString(),
        ),
      );
      return false;
    } finally {
      _isInitializing = false;
    }
  }

  void _handleError(SpeechRecognitionError error) {
    debugPrint(
      'SpeechRecognition error: ${error.errorMsg} (permanent: ${error.permanent})',
    );
    if (_isContinuousActive && !error.permanent) {
      // Non-fatal pause / network hiccup: restart listening automatically
      _scheduleAutoRestart();
    } else {
      _stateController.add(
        SpeechRecognitionState(
          status: SpeechStatus.error,
          errorMessage: error.errorMsg,
        ),
      );
    }
  }

  void _handleStatus(String status) {
    debugPrint('SpeechRecognition status: $status');
    if (status == 'listening') {
      _stateController.add(
        const SpeechRecognitionState(status: SpeechStatus.listening),
      );
    } else if (status == 'notListening' || status == 'done') {
      if (_isContinuousActive) {
        _scheduleAutoRestart();
      } else {
        _stateController.add(
          const SpeechRecognitionState(status: SpeechStatus.ready),
        );
      }
    }
  }

  void _scheduleAutoRestart() {
    if (!_isContinuousActive) return;
    Future.delayed(const Duration(milliseconds: 250), () {
      if (_isContinuousActive && !_speechToText.isListening) {
        _startListeningInternal();
      }
    });
  }

  Future<void> _startListeningInternal() async {
    if (!_isAvailable) {
      final ready = await initialize();
      if (!ready) return;
    }

    try {
      final localeId = _currentLanguage.replaceAll('-', '_');
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _stateController.add(
            SpeechRecognitionState(
              status: SpeechStatus.listening,
              recognizedText: result.recognizedWords,
              isFinal: result.finalResult,
            ),
          );
          _currentOnResult?.call(result.recognizedWords, result.finalResult);
        },
        listenOptions: SpeechListenOptions(
          localeId: localeId,
          listenFor: const Duration(hours: 1),
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
          listenMode: ListenMode.dictation,
          cancelOnError: false,
        ),
      );
    } catch (e) {
      debugPrint('Error invoking speech listen: $e');
    }
  }

  @override
  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
    String language = 'id_ID',
  }) async {
    _isContinuousActive = true;
    _currentOnResult = onResult;
    _currentLanguage = language;

    if (!_isAvailable) {
      await initialize();
    }

    await _startListeningInternal();
  }

  @override
  Future<void> stopListening() async {
    _isContinuousActive = false;
    try {
      await _speechToText.stop();
    } catch (e) {
      debugPrint('Error stopping speech recognizer: $e');
    }
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.ready),
    );
  }

  @override
  Future<void> cancelListening() async {
    _isContinuousActive = false;
    try {
      await _speechToText.cancel();
    } catch (e) {
      debugPrint('Error cancelling speech recognizer: $e');
    }
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.ready),
    );
  }

  @override
  bool get isListening => _isContinuousActive || _speechToText.isListening;

  @override
  Stream<SpeechRecognitionState> get statusStream => _stateController.stream;

  @override
  void dispose() {
    _isContinuousActive = false;
    try {
      _speechToText.stop();
    } catch (_) {}
    _stateController.close();
  }
}
