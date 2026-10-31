import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../data/speech_service_impl.dart';
import '../domain/speech_service.dart';
import '../domain/speech_state.dart';

/// Production Live Speech-to-Text screen for Teman Tuli accessibility.
///
/// Features:
/// 1. Real-time live caption with extra-large high-contrast text and zero confirmation step.
/// 2. Continuous listening with auto-recovery and multi-sentence aggregation.
/// 3. One-tap "Bersihkan Layar" (Clear Screen) button.
/// 4. Fast manual typing fallback for noisy environments.
/// 5. Reactive synchronization with native speech recognition engine status stream.
///
/// Feature Owner: Roganda Tua Tampubolon (Branch: feature/speech-to-text).
class SpeechToTextScreen extends StatefulWidget {
  final SpeechService? speechService;

  const SpeechToTextScreen({super.key, this.speechService});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late final SpeechService _speechService;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _manualInputController = TextEditingController();

  StreamSubscription<SpeechRecognitionState>? _statusSubscription;
  bool _isListening = false;
  bool _isManualInputVisible = false;
  String? _errorMessage;

  /// Accumulated committed sentences from previous speech segments.
  String _accumulatedText = '';

  /// Active partial speech recognized in the current ongoing segment.
  String _currentSentenceWords = '';

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? SpeechServiceImpl();
    _initSpeechPipeline();
  }

  void _initSpeechPipeline() {
    // Masalah 4 Fix: Sync UI state reactively with engine's statusStream
    _statusSubscription = _speechService.statusStream.listen((state) {
      if (!mounted) return;
      setState(() {
        if (state.status == SpeechStatus.listening) {
          _isListening = true;
          _errorMessage = null;
        } else if (state.status == SpeechStatus.ready ||
            state.status == SpeechStatus.uninitialized) {
          _isListening = false;
        } else if (state.status == SpeechStatus.error) {
          _isListening = false;
          _errorMessage = state.errorMessage;
        }
      });
    });

    // Masalah 1 Fix: Safe async initialization handled with Completer in service
    _speechService.initialize().catchError((e) {
      debugPrint('Screen initialization catchError: $e');
      return false;
    });
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _speechService.dispose();
    _scrollController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSpeechResult(String text, bool isFinal) {
    if (!mounted) return;

    setState(() {
      _errorMessage = null;
      if (isFinal) {
        final trimmed = text.trim();
        if (trimmed.isNotEmpty) {
          if (_accumulatedText.isEmpty) {
            _accumulatedText = trimmed;
          } else {
            _accumulatedText = '$_accumulatedText $trimmed';
          }
        }
        _currentSentenceWords = '';
      } else {
        _currentSentenceWords = text.trim();
      }
    });

    _scrollToBottom();
  }

  Future<void> _toggleListening() async {
    setState(() {
      _errorMessage = null;
    });

    if (_isListening) {
      await _speechService.stopListening();
      if (mounted) {
        setState(() {
          _isListening = false;
          if (_currentSentenceWords.isNotEmpty) {
            if (_accumulatedText.isEmpty) {
              _accumulatedText = _currentSentenceWords;
            } else {
              _accumulatedText = '$_accumulatedText $_currentSentenceWords';
            }
            _currentSentenceWords = '';
          }
        });
      }
    } else {
      // Masalah 4 Fix: Engine statusStream will drive _isListening
      await _speechService.startListening(
        onResult: _onSpeechResult,
        language: 'id_ID',
      );
    }
  }

  void _clearScreen() {
    setState(() {
      _accumulatedText = '';
      _currentSentenceWords = '';
    });
  }

  void _submitManualText() {
    final text = _manualInputController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      if (_accumulatedText.isEmpty) {
        _accumulatedText = text;
      } else {
        _accumulatedText = '$_accumulatedText $text';
      }
      _manualInputController.clear();
      _isManualInputVisible = false;
    });

    _scrollToBottom();
  }

  String get _displayCaption {
    if (_accumulatedText.isEmpty && _currentSentenceWords.isEmpty) {
      return '';
    }
    if (_accumulatedText.isEmpty) {
      return _currentSentenceWords;
    }
    if (_currentSentenceWords.isEmpty) {
      return _accumulatedText;
    }
    return '$_accumulatedText $_currentSentenceWords';
  }

  @override
  Widget build(BuildContext context) {
    final hasContent = _displayCaption.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 soft background
      appBar: AppBar(
        title: const Text(
          'Live Speech-to-Text',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isManualInputVisible ? Icons.keyboard_hide : Icons.keyboard,
              color: AppColors.primary,
            ),
            tooltip: 'Ketik Manual Cepat',
            onPressed: () {
              setState(() {
                _isManualInputVisible = !_isManualInputVisible;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Status Banner: Guides Deaf user on microphone and engine state
            _buildStatusHeader(),

            // Error notice banner if recognition encounters an issue
            if (_errorMessage != null) _buildErrorNotice(),

            // Main Live Caption Display Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isListening
                        ? AppColors.primary
                        : AppColors.outline.withValues(alpha: 0.5),
                    width: _isListening ? 2.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: hasContent
                      ? SelectableText(
                          _displayCaption,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.45,
                            color: Color(0xFF0F172A), // Slate 900 high contrast
                            letterSpacing: -0.3,
                          ),
                        )
                      : Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 60.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isListening
                                      ? Icons.hearing_rounded
                                      : Icons.mic_none_rounded,
                                  size: 64,
                                  color: _isListening
                                      ? AppColors.primary
                                      : Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isListening
                                      ? 'Mendengarkan ucapan lawan bicara...\nSetiap kata akan langsung muncul di sini.'
                                      : 'Ketuk tombol mikrofon di bawah untuk mulai merekam ucapan lawan bicara.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.5,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ),
            ),

            // Quick Manual Typing Fallback (Shown when toggled)
            if (_isManualInputVisible) _buildManualInputField(),

            // Bottom Controls Bar: Clear Screen & Big Mic Toggle Button
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isListening
            ? const Color(0xFFDCFCE7) // Mint 100
            : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isListening ? const Color(0xFF16A34A) : AppColors.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isListening
                  ? const Color(0xFF16A34A)
                  : Colors.grey.shade500,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isListening ? Icons.mic_rounded : Icons.mic_off_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isListening
                      ? 'MIKROFON AKTIF (Bahasa Indonesia)'
                      : 'MIKROFON TIDAK AKTIF',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: _isListening
                        ? const Color(0xFF166534)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isListening
                      ? 'Arahkan mikrofon ke lawan bicara untuk transkripsi langsung'
                      : 'Ketuk tombol biru besar di bawah untuk mulai mendengarkan',
                  style: TextStyle(
                    fontSize: 12,
                    color: _isListening
                        ? const Color(0xFF15803D)
                        : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorNotice() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2), // Red 50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF87171)), // Red 400
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFB91C1C),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF991B1B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: const Color(0xFF991B1B),
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildManualInputField() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _manualInputController,
              decoration: const InputDecoration(
                hintText: 'Ketik pesan cepat di sini...',
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16),
              onSubmitted: (_) => _submitManualText(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primary),
            tooltip: 'Tampilkan ke Layar',
            onPressed: _submitManualText,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Clear Screen Button (Hapus / Bersihkan Layar)
              Expanded(
                flex: 1,
                child: AppButton(
                  label: 'Bersihkan Layar',
                  icon: Icons.delete_sweep_rounded,
                  isOutlined: true,
                  onPressed: _displayCaption.isNotEmpty ? _clearScreen : null,
                ),
              ),
              const SizedBox(width: 12),
              // Fallback Manual Input Button
              Expanded(
                flex: 1,
                child: AppButton(
                  label: _isManualInputVisible ? 'Tutup Ketik' : 'Ketik Manual',
                  icon: _isManualInputVisible
                      ? Icons.close_rounded
                      : Icons.keyboard_rounded,
                  isOutlined: true,
                  onPressed: () {
                    setState(() {
                      _isManualInputVisible = !_isManualInputVisible;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Large Microphone Control Button (Satu Sentuhan Teman Tuli)
          Center(
            child: SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton.icon(
                onPressed: _toggleListening,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isListening
                      ? AppColors.error
                      : AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: _isListening ? 6 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: Icon(
                  _isListening ? Icons.stop_circle_rounded : Icons.mic_rounded,
                  size: 32,
                ),
                label: Text(
                  _isListening
                      ? 'Hentikan Mendengarkan'
                      : 'Mulai Mendengarkan Suara',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
