import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../data/speech_service_impl.dart';
import '../domain/speech_service.dart';

/// Production Live Speech-to-Text screen for Teman Tuli accessibility.
/// Adopts the Dribbble-inspired healthcare aesthetic & sage green identity:
/// - Real-time live caption with extra-large high-contrast text (#263D2F) and zero confirmation step
/// - Continuous listening with auto-recovery and multi-sentence aggregation
/// - Spacious transcription viewport with auto-scroll
/// - Large, accessible microphone control
/// - One-tap "Bersihkan Layar" (Clear Screen) button
/// - Fast manual typing fallback for noisy environments
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
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

  bool _isListening = false;
  bool _isManualInputVisible = false;

  /// Accumulated committed sentences from previous speech segments.
  String _accumulatedText = '';

  /// Active partial speech recognized in the current ongoing segment.
  String _currentSentenceWords = '';

  @override
  void initState() {
    super.initState();
    _speechService = widget.speechService ?? SpeechServiceImpl();
    _speechService.initialize();
  }

  @override
  void dispose() {
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
      setState(() {
        _isListening = true;
      });

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Live Speech-to-Text'),
        actions: [
          IconButton(
            tooltip: 'Ketik Manual',
            icon: Icon(
              _isManualInputVisible ? Icons.keyboard_hide_rounded : Icons.keyboard_rounded,
              color: AppColors.darkGreen,
            ),
            onPressed: () {
              setState(() {
                _isManualInputVisible = !_isManualInputVisible;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status Header
            _buildStatusHeader(),

            // Manual Typing Input (collapsible)
            if (_isManualInputVisible) _buildManualInputField(),

            // Spacious Transcription Area
            Expanded(
              child: AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                padding: const EdgeInsets.all(20.0),
                backgroundColor: AppColors.white,
                borderColor: _isListening
                    ? AppColors.primary
                    : AppColors.lightGreen,
                child: hasContent
                    ? SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          _displayCaption,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                            letterSpacing: -0.3,
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: AppColors.accentSttBg,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mic_rounded,
                                size: 40,
                                color: AppColors.accentStt,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Menunggu Ucapan Lawan Bicara',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(
                                'Tekan tombol mikrofon di bawah untuk mentranskripsi suara bahasa Indonesia secara langsung.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),

            // Bottom Controls Area
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _isListening ? AppColors.accentSttBg : AppColors.lightGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isListening
              ? AppColors.accentStt.withValues(alpha: 0.3)
              : AppColors.sageGreen,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _isListening ? AppColors.error : AppColors.primary,
              shape: BoxShape.circle,
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
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: _isListening ? AppColors.error : AppColors.darkGreen,
                  ),
                ),
                Text(
                  _isListening
                      ? 'Mendengarkan ucapan langsung lawan bicara...'
                      : 'Ketuk tombol di bawah untuk mulai mendengarkan',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _isListening ? AppColors.onAccentStt : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge.category(
            'id-ID',
            bg: _isListening ? AppColors.white : AppColors.sageGreen,
            fg: AppColors.darkGreen,
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _manualInputController,
              decoration: const InputDecoration(
                hintText: 'Ketik pesan cepat di sini...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
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
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A263D2F),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: AppButton(
                  label: 'Bersihkan Layar',
                  icon: Icons.delete_sweep_rounded,
                  isOutlined: true,
                  height: 46,
                  onPressed: _displayCaption.isNotEmpty ? _clearScreen : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: AppButton(
                  label: _isManualInputVisible ? 'Tutup Ketik' : 'Ketik Manual',
                  icon: _isManualInputVisible
                      ? Icons.close_rounded
                      : Icons.keyboard_rounded,
                  isOutlined: true,
                  height: 46,
                  onPressed: () {
                    setState(() {
                      _isManualInputVisible = !_isManualInputVisible;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Large Microphone Control Button (Satu Sentuhan Teman Tuli)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: _toggleListening,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isListening
                    ? AppColors.error
                    : AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(29),
                ),
              ),
              icon: Icon(
                _isListening ? Icons.stop_circle_rounded : Icons.mic_rounded,
                size: 28,
              ),
              label: Text(
                _isListening
                    ? 'Hentikan Mendengarkan'
                    : 'Mulai Mendengarkan Suara',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
