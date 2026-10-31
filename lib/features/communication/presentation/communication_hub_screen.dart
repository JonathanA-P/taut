import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';

/// Unified Communication Screen ("Komunikasi Langsung - Satu ruang, dua arah").
/// Implements the exact single-screen two-way communication workflow from the HTML prototype:
/// 1. Session header with title, status badge, and dynamic text-size cycling (Aa · 16/19/22 px)
/// 2. Camera & sign-recognition area with framing guide, status badge, and demo sign generation
/// 3. Speech-to-Text area with large microphone control, live transcript, and echo protection
/// 4. Shared conversation history displaying speech, sign, and typed messages
/// 5. Fast manual typing fallback with instant TTS speech playback
/// 6. Safe session termination that stops camera, microphone, and TTS
class CommunicationHubScreen extends StatefulWidget {
  final VoidCallback? onOpenDashboard;

  const CommunicationHubScreen({super.key, this.onOpenDashboard});

  @override
  State<CommunicationHubScreen> createState() => _CommunicationHubScreenState();
}

class _CommunicationHubScreenState extends State<CommunicationHubScreen> {
  final TextEditingController _signInputController = TextEditingController();
  final TextEditingController _manualInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();

  bool _wantMic = false;
  String _micStatusText = 'Mikrofon nonaktif';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.5);
      _tts.setCompletionHandler(() {
        final state = TautAppState();
        state.setTtsActive(false);
        if (_wantMic) {
          state.setMicActive(true);
          setState(() => _micStatusText = 'Mendengarkan…');
        } else {
          setState(() => _micStatusText = 'Mikrofon nonaktif');
        }
      });
      _tts.setErrorHandler((_) {
        final state = TautAppState();
        state.setTtsActive(false);
        setState(() => _micStatusText = 'Mikrofon nonaktif');
      });
    } catch (_) {
      // Graceful fallback if TTS engine is unavailable
    }
  }

  @override
  void dispose() {
    _signInputController.dispose();
    _manualInputController.dispose();
    _scrollController.dispose();
    _tts.stop();
    super.dispose();
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF263D2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _toggleCamera(TautAppState state) {
    final next = !state.isCamActive;
    state.setCamActive(next);
    if (next) {
      _showToast('Kamera aktif (simulasi viewfinder).');
    } else {
      _showToast('Kamera dinonaktifkan.');
    }
  }

  void _toggleMic(TautAppState state) {
    if (state.isMicActive || _wantMic) {
      _wantMic = false;
      state.setMicActive(false);
      setState(() => _micStatusText = 'Mikrofon nonaktif');
      _showToast('Mikrofon dimatikan.');
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Aktifkan mikrofon?'),
          content: const Text(
            'Layanan pengenalan ucapan akan menangkap suara lawan bicara secara langsung dalam Bahasa Indonesia.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _wantMic = true;
                state.setMicActive(true);
                setState(() => _micStatusText = 'Mendengarkan…');
                _showToast('Mikrofon aktif. Silakan lawan bicara berbicara.');
              },
              child: const Text('Lanjutkan'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _speakText(String text, TautAppState state) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Echo protection: temporarily pause mic while TTS speaks
    state.setTtsActive(true);
    state.setMicActive(false);
    setState(() => _micStatusText = 'Dijeda saat suara diputar');

    try {
      await _tts.speak(trimmed);
    } catch (_) {
      // In headless or mock environment: simulate completion
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        state.setTtsActive(false);
        if (_wantMic) {
          state.setMicActive(true);
          setState(() => _micStatusText = 'Mendengarkan…');
        } else {
          setState(() => _micStatusText = 'Mikrofon nonaktif');
        }
      });
    }
  }

  void _handleDemoSign(TautAppState state) {
    state.demoSign();
    _signInputController.text = state.signText;
    _showToast('Contoh hasil simulasi, bukan pembacaan kamera.');
  }

  void _handleSpeakSign(TautAppState state) {
    final text = _signInputController.text.trim();
    if (text.isEmpty) {
      _showToast('Coba simulasi atau tulis hasil terlebih dahulu.');
      return;
    }
    state.addMessage(text: text, type: 'Isyarat', isDemo: true);
    _speakText(text, state);
    _scrollToBottom();
  }

  void _handleDemoSpeech(TautAppState state) {
    state.demoSpeech();
    _scrollToBottom();
    _showToast('Contoh ucapan ditranskripsi ke layar.');
  }

  void _handleSendManual(TautAppState state) {
    final text = _manualInputController.text.trim();
    if (text.isEmpty) return;
    state.addMessage(text: text, type: 'Ketik');
    _manualInputController.clear();
    _scrollToBottom();
  }

  void _handleEndSession(TautAppState state) {
    _tts.stop();
    _wantMic = false;
    _micStatusText = 'Mikrofon nonaktif';
    state.endCommunicationSession();
    _showToast('Sesi selesai. Kamera, mikrofon, dan suara dihentikan.');
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: Navigator.canPop(context)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => _handleEndSession(state),
                  )
                : null,
            title: const Text(
              'Komunikasi langsung',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Subheader: Status indicator + Text Size Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Satu ruang, dua arah',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          state.cycleFont();
                          _showToast('Ukuran teks: ${state.fontSize.toInt()} px');
                        },
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: Text(
                          'Aa · Ukuran teks (${state.fontSize.toInt()}px)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // 1. CAMERA VIEWPORT & SIGN RECOGNITION AREA
                  _buildCameraViewport(state),
                  const SizedBox(height: 6),
                  const Text(
                    'Posisikan wajah dan tangan dalam bingkai. Pengenalan isyarat pada prototipe ini adalah simulasi.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF66756B), height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  // 2. ISYARAT -> SUARA CARD
                  _buildSignToSoundCard(state),
                  const SizedBox(height: 14),

                  // 3. UCAPAN -> TEKS CARD
                  _buildSpeechToTextCard(state),
                  const SizedBox(height: 20),

                  // 4. SHARED CONVERSATION HISTORY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Percakapan',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      TextButton(
                        onPressed: state.messages.isNotEmpty
                            ? () {
                                state.clearMessages();
                                _showToast('Percakapan dibersihkan.');
                              }
                            : null,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        child: const Text('Bersihkan'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildConversationHistory(state),
                  const SizedBox(height: 14),

                  // 5. MANUAL TYPING FALLBACK
                  _buildManualInputForm(state),
                  const SizedBox(height: 8),
                  const Text(
                    'Teks hanya berada dalam sesi ini. Audio dan video tidak direkam oleh prototipe.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF66756B), height: 1.4),
                  ),
                  const SizedBox(height: 20),

                  // 6. END SESSION ACTION
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => _handleEndSession(state),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFB9C9B6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Akhiri sesi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCameraViewport(TautAppState state) {
    return Container(
      height: 175,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF263D2F),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Visual framing corners
          Positioned(
            left: 45,
            right: 45,
            top: 25,
            bottom: 25,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),

          // Viewfinder state
          if (state.isCamActive)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.videocam_rounded,
                    size: 38,
                    color: AppColors.sageGreen.withValues(alpha: 0.9),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kamera Aktif • Menangkap Isyarat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          else
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.back_hand_rounded,
                    size: 38,
                    color: Color(0x99FFFFFF),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ruang untuk isyaratmu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Aktifkan kamera saat kamu siap',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // Status Badge top-left
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                state.isCamActive ? 'Kamera aktif' : 'Kamera nonaktif',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),

          // Camera Toggle Button bottom-right
          Positioned(
            right: 12,
            bottom: 12,
            child: Material(
              color: Colors.white.withValues(alpha: 0.9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: InkWell(
                onTap: () => _toggleCamera(state),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  child: Icon(
                    state.isCamActive ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    size: 20,
                    color: AppColors.darkGreen,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignToSoundCard(TautAppState state) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF0E9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06263D2F),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Isyarat → suara',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6ECDA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Simulasi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF825D24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Periksa hasil sebelum diputar',
            style: TextStyle(fontSize: 12, color: Color(0xFF66756B)),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _signInputController,
            maxLines: 2,
            style: TextStyle(fontSize: state.fontSize, color: AppColors.darkGreen),
            decoration: const InputDecoration(
              hintText: 'Hasil isyarat akan muncul di sini…',
              border: OutlineInputBorder(),
            ),
            onChanged: (val) => state.setSignText(val),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleDemoSign(state),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Coba isyarat',
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _handleSpeakSign(state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('Putar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechToTextCard(TautAppState state) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF0E9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06263D2F),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ucapan → teks',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  Text(
                    _micStatusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: state.isMicActive
                          ? const Color(0xFF9A5143)
                          : const Color(0xFF66756B),
                      fontWeight: state.isMicActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _toggleMic(state),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: state.isMicActive
                        ? const Color(0xFF9A5143)
                        : AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: state.isMicActive
                        ? const [
                            BoxShadow(
                              color: Color(0xFFF2E5DF),
                              spreadRadius: 5,
                            ),
                          ]
                        : null,
                  ),
                  child: const Icon(
                    Icons.mic_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            constraints: const BoxConstraints(minHeight: 55),
            child: Text(
              state.transcriptText,
              style: TextStyle(
                fontSize: state.fontSize * 1.15,
                color: state.transcriptText.contains('Ucapan teman dengar')
                    ? const Color(0xFF66756B)
                    : AppColors.darkGreen,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () => _handleDemoSpeech(state),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(60, 30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Coba contoh ucapan'),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationHistory(TautAppState state) {
    if (state.messages.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
        alignment: Alignment.center,
        child: const Text(
          'Percakapan dimulai dari satu sapaan.',
          style: TextStyle(fontSize: 14, color: Color(0xFF66756B)),
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 260),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: state.messages.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final msg = state.messages[index];
          final isSpeech = msg.type == 'Ucapan';
          final isSign = msg.type == 'Isyarat';

          return Align(
            alignment: isSign ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: EdgeInsets.only(
                left: isSign ? 40 : 0,
                right: isSign ? 0 : 40,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: isSpeech
                    ? const Color(0xFFE5EEE5)
                    : (isSign ? const Color(0xFFF2EADD) : const Color(0xFFE5EEE5)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(17),
                  topRight: const Radius.circular(17),
                  bottomLeft: Radius.circular(isSign ? 17 : 3),
                  bottomRight: Radius.circular(isSign ? 3 : 17),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${msg.type.toUpperCase()}${msg.isDemo ? ' · DEMO' : ''}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: Color(0xFF61705D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: state.fontSize,
                            color: AppColors.darkGreen,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (msg.type == 'Ketik') ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _speakText(msg.text, state),
                          child: const Icon(
                            Icons.volume_up_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualInputForm(TautAppState state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ketik sebagai alternatif',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _manualInputController,
                style: TextStyle(fontSize: state.fontSize, color: AppColors.darkGreen),
                decoration: const InputDecoration(
                  hintText: 'Tulis pesan…',
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                onSubmitted: (_) => _handleSendManual(state),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE4E9E1)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
            onPressed: () => _handleSendManual(state),
          ),
        ),
      ],
    );
  }
}
