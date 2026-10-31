import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../domain/speech_service.dart';
import '../domain/speech_state.dart';

class SpeechServiceImpl implements SpeechService {
  final SpeechToText _speechToText;
  final StreamController<SpeechRecognitionState> _stateController =
      StreamController<SpeechRecognitionState>.broadcast();

  bool _isAvailable = false;
  bool _isContinuousActive = false;
  Completer<bool>? _initCompleter;
  void Function(String text, bool isFinal)? _currentOnResult;
  String _currentLanguage = 'id_ID';
  String? _resolvedIndonesianLocaleId;

  SpeechServiceImpl({SpeechToText? speechToText})
    : _speechToText = speechToText ?? SpeechToText() {
    _stateController.add(
      const SpeechRecognitionState(status: SpeechStatus.uninitialized),
    );
  }

  @override
  Future<bool> initialize() async {
    if (_isAvailable) return true;

    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<bool>();
    try {
      _isAvailable = await _speechToText.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: kDebugMode,
      );

      if (_isAvailable) {
        await _resolveIndonesianLocale();
      }

      _stateController.add(
        SpeechRecognitionState(
          status: _isAvailable ? SpeechStatus.ready : SpeechStatus.error,
          errorMessage: _isAvailable ? null : 'Fitur pengenalan suara tidak tersedia atau izin mikrofon belum diberikan.',
        ),
      );
      _initCompleter!.complete(_isAvailable);
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
      _initCompleter!.complete(false);
      return false;
    } finally {
      _initCompleter = null;
    }
  }

  Future<void> _resolveIndonesianLocale() async {
    try {
      final availableLocales = await _speechToText.locales();
      debugPrint('Device speech locales count: ${availableLocales.length}');

      for (final loc in availableLocales) {
        final id = loc.localeId.toLowerCase();
        if (id == 'id_id' ||
            id == 'id-id' ||
            id.startsWith('id_') ||
            id.startsWith('id-') ||
            id == 'in_id' ||
            id == 'in-id' ||
            id.startsWith('in_') ||
            id.startsWith('in-')) {
          _resolvedIndonesianLocaleId = loc.localeId;
          debugPrint(
            'Matched Indonesian speech locale: $_resolvedIndonesianLocaleId (${loc.name})',
          );
          break;
        }
      }
    } catch (e) {
      debugPrint('Error inspecting available device locales: $e');
    }
  }

  void _handleError(SpeechRecognitionError error) {
    debugPrint(
      'SpeechRecognition error: ${error.errorMsg} (permanent: ${error.permanent})',
    );
    if (_isContinuousActive && !error.permanent) {
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
    Future.delayed(const Duration(milliseconds: 300), () {
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
      final localeId =
          _resolvedIndonesianLocaleId ?? _currentLanguage.replaceAll('-', '_');

      debugPrint('SpeechToText listen() using localeId: $localeId');

      final started = await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          debugPrint(
            'Speech words: "${result.recognizedWords}", isFinal: ${result.finalResult}',
          );
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

      if (started == false) {
        debugPrint('SpeechToText.listen() returned false');
        _stateController.add(
          const SpeechRecognitionState(
            status: SpeechStatus.error,
            errorMessage: 'Gagal memulai perekaman audio. Periksa izin mikrofon perangkat.',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error invoking speech listen: $e');
      _stateController.add(
        SpeechRecognitionState(
          status: SpeechStatus.error,
          errorMessage: 'Gagal mengaktifkan mikrofon: $e',
        ),
      );
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
      final ready = await initialize();
      if (!ready) {
        _isContinuousActive = false;
        return;
      }
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

