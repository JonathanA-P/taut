import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../speech_to_text/data/speech_service_impl.dart';
import '../speech_to_text/domain/speech_service.dart';
import '../speech_to_text/domain/speech_state.dart';

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
  late final SpeechService _speechService;
  StreamSubscription<SpeechRecognitionState>? _speechSubscription;

  bool _wantMic = false;
  String _micStatusText = 'Mikrofon nonaktif';

  @override
  void initState() {
    super.initState();
    _speechService = SpeechServiceImpl();
    _speechSubscription = _speechService.statusStream.listen((speechState) {
      if (!mounted) return;
      setState(() {
        if (speechState.status == SpeechStatus.listening) {
          _micStatusText = 'Mendengarkan…';
        } else if (speechState.status == SpeechStatus.ready ||
            speechState.status == SpeechStatus.uninitialized) {
          _micStatusText = _wantMic ? 'Mendengarkan…' : 'Mikrofon nonaktif';
        } else if (speechState.status == SpeechStatus.error) {
          _micStatusText = speechState.errorMessage ?? 'Mikrofon error';
        }
      });
    });
    _speechService.initialize().catchError((_) => false);
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('id-ID');
      await _tts.setSpeechRate(0.46);
      await _tts.setPitch(0.98);
      _tts.setCompletionHandler(() async {
        final state = TautAppState();
        state.setTtsActive(false);
        if (_wantMic) {
          state.setMicActive(true);
          setState(() => _micStatusText = 'Mendengarkan…');
          await _speechService.startListening(
            onResult: (text, isFinal) {
              if (!mounted) return;
              if (isFinal && text.trim().isNotEmpty) {
                state.addMessage(text: text.trim(), type: 'Ucapan');
                _scrollToBottom();
              }
            },
          );
        } else {
          setState(() => _micStatusText = 'Mikrofon nonaktif');
        }
      });
      _tts.setErrorHandler((_) {
        final state = TautAppState();
        state.setTtsActive(false);
        setState(() => _micStatusText = 'Mikrofon nonaktif');
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _speechSubscription?.cancel();
    _speechService.dispose();
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

  Future<void> _toggleMic(TautAppState state) async {
    if (state.isMicActive || _wantMic) {
      _wantMic = false;
      await _speechService.stopListening();
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
              onPressed: () async {
                Navigator.pop(ctx);
                _wantMic = true;
                final initialized = await _speechService.initialize();
                if (!mounted) return;
                state.setMicActive(true);
                setState(() => _micStatusText = 'Mendengarkan…');
                _showToast('Mikrofon aktif. Silakan lawan bicara berbicara.');

                if (initialized) {
                  await _speechService.startListening(
                    onResult: (text, isFinal) {
                      if (!mounted) return;
                      if (isFinal && text.trim().isNotEmpty) {
                        state.addMessage(text: text.trim(), type: 'Ucapan');
                        _scrollToBottom();
                      }
                    },
                  );
                }
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

    state.setTtsActive(true);
    state.setMicActive(false);
    await _speechService.stopListening();
    setState(() => _micStatusText = 'Dijeda saat suara diputar');

    try {
      await _tts.speak(trimmed);
    } catch (_) {
      Future.delayed(const Duration(milliseconds: 600), () async {
        if (!mounted) return;
        state.setTtsActive(false);
        if (_wantMic) {
          state.setMicActive(true);
          setState(() => _micStatusText = 'Mendengarkan…');
          await _speechService.startListening(
            onResult: (t, isFinal) {
              if (!mounted) return;
              if (isFinal && t.trim().isNotEmpty) {
                state.addMessage(text: t.trim(), type: 'Ucapan');
                _scrollToBottom();
              }
            },
          );
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
    if (state.canPopPage) {
      state.popPage();
    } else if (Navigator.canPop(context)) {
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
            leading: (Navigator.canPop(context) || state.canPopPage)
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          'Aa Â· Ukuran teks (${state.fontSize.toInt()}px)',
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

                  // Ruangan Obrolan Jarak Jauh trigger bar (between title row and camera session)
                  _buildRoomControlBar(context, state),
                  const SizedBox(height: 12),

                  _buildCameraViewport(state),
                  const SizedBox(height: 6),
                  const Text(
                    'Posisikan wajah dan tangan dalam bingkai. Pengenalan isyarat pada prototipe ini adalah simulasi.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF66756B), height: 1.5),
                  ),
                  const SizedBox(height: 16),

                  _buildSignToSoundCard(state),
                  const SizedBox(height: 14),

                  _buildSpeechToTextCard(state),
                  const SizedBox(height: 20),

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

                  _buildManualInputForm(state),
                  const SizedBox(height: 8),
                  const Text(
                    'Teks hanya berada dalam sesi ini. Audio dan video tidak direkam oleh prototipe.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF66756B), height: 1.4),
                  ),
                  const SizedBox(height: 20),

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
                    'Kamera Aktif â€¢ Menangkap Isyarat',
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

          if (state.isRoomActive)
            Positioned(
              right: 12,
              top: 12,
              child: InkWell(
                onTap: () => _showQrCodeDialog(context, state.roomCode ?? 'TAUT-8921'),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.qr_code_2_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        state.roomCode ?? 'TAUT-8921',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

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
                'Isyarat â†’ suara',
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
              hintText: 'Hasil isyarat akan muncul di siniâ€¦',
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
                    'Ucapan â†’ teks',
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
                    '${msg.type.toUpperCase()}${msg.isDemo ? ' Â· DEMO' : ''}',
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
                  hintText: 'Tulis pesanâ€¦',
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

  Widget _buildRoomControlBar(BuildContext context, TautAppState state) {
    if (state.isRoomActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFE5EEE5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFD0E0CE)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xFF388E3C),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Ruangan Aktif: ${state.roomCode}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _showQrCodeDialog(
                          context,
                          state.roomCode ?? 'TAUT-8921',
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC4D6C2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.qr_code_2_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'QR',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${state.roomParticipants.length} Peserta (${state.roomParticipants.join(', ')})',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF536A5B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                state.endRoomSession();
                _showToast('Ruangan obrolan diakhiri.');
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B4435),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                minimumSize: Size.zero,
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E9DE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4D9C8)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: Color(0xFF825D24),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ruangan Obrolan Jarak Jauh',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF655747),
                  ),
                ),
                Text(
                  'Untuk kelas/jarak jauh multi-pengguna',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7A6B59),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              state.createRoom();
              _showRoomSetupSheet(context, state);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Buat Room',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 6),
          OutlinedButton(
            onPressed: () => _showJoinRoomDialog(context, state),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF655747),
              side: const BorderSide(color: Color(0xFFC7BBA8)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Gabung',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoomSetupSheet(BuildContext context, TautAppState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E2D5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ruangan Obrolan Jarak Jauh',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close_rounded, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Peserta lain dapat bergabung menggunakan kode unik atau memindai QR.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // Room Code & QR Display
                    Center(
                      child: Column(
                        children: [
                          TautQrWidget(code: state.roomCode ?? 'TAUT-8921', size: 120),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EEE5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFD0E0CE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.roomCode ?? 'TAUT-8921',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    _showToast('Kode ${state.roomCode} disalin.');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Friend requests to join (Host can accept/reject)
                    if (state.roomJoinRequests.isNotEmpty) ...[
                      Text(
                        'Teman ingin bergabung (${state.roomJoinRequests.length})',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...state.roomJoinRequests.map(
                        (friendName) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAF7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE4E9E1)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: const Color(0xFFE5EEE5),
                                child: Text(
                                  friendName.isNotEmpty ? friendName[0] : '?',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  friendName,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    state.rejectRoomParticipant(friendName);
                                  });
                                  _showToast('Permintaan $friendName ditolak.');
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text(
                                  'Tolak',
                                  style: TextStyle(
                                    color: Color(0xFF8B4435),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setModalState(() {
                                    state.acceptRoomParticipant(friendName);
                                  });
                                  _showToast('$friendName diizinkan bergabung.');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  minimumSize: Size.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Terima',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const Text(
                      '• Pengguna yang memasukkan kode unik atau memindai QR langsung bergabung tanpa menunggu persetujuan.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF66756B)),
                    ),
                    const SizedBox(height: 16),

                    // Start room CTA
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          state.startRoomSession();
                          Navigator.pop(ctx);
                          _showToast('Ruangan obrolan aktif. Menghubungkan seluruh peserta.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mulai ruangan obrolan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showJoinRoomDialog(BuildContext context, TautAppState state) {
    final controller = TextEditingController(text: 'TAUT-8921');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Gabung Ruangan Obrolan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masukkan kode unik ruangan dari pembuat ruangan:',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Contoh: TAUT-8921',
                filled: true,
                fillColor: const Color(0xFFF8FAF7),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFD9E2D5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFD9E2D5)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                state.joinRoomByCode(code);
                Navigator.pop(ctx);
                _showToast('Berhasil bergabung ke ruangan $code.');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Gabung langsung'),
          ),
        ],
      ),
    );
  }

  void _showQrCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Kode QR Ruangan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TautQrWidget(code: code, size: 160),
            const SizedBox(height: 14),
            Text(
              code,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: AppColors.darkGreen,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Pindai atau masukkan kode ini untuk langsung bergabung ke ruangan obrolan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class TautQrWidget extends StatelessWidget {
  final String code;
  final double size;

  const TautQrWidget({super.key, required this.code, this.size = 140});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE4E9E1)),
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: _TautQrPainter(),
      ),
    );
  }
}

class _TautQrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF263D2F)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;
    final unit = w / 21;

    void drawFinder(double x, double y) {
      canvas.drawRect(Rect.fromLTWH(x, y, 7 * unit, 7 * unit), paint);
      canvas.drawRect(
        Rect.fromLTWH(x + unit, y + unit, 5 * unit, 5 * unit),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(x + 2 * unit, y + 2 * unit, 3 * unit, 3 * unit),
        paint,
      );
    }

    drawFinder(0, 0);
    drawFinder(w - 7 * unit, 0);
    drawFinder(0, h - 7 * unit);

    for (int i = 8; i <= 12; i += 2) {
      canvas.drawRect(Rect.fromLTWH(i * unit, 6 * unit, unit, unit), paint);
      canvas.drawRect(Rect.fromLTWH(6 * unit, i * unit, unit, unit), paint);
    }

    final dataCoords = [
      [8, 8], [9, 8], [11, 9], [13, 8], [14, 9], [16, 8],
      [8, 10], [10, 11], [12, 10], [14, 11], [17, 10],
      [9, 13], [11, 13], [13, 13], [15, 14], [17, 13],
      [8, 16], [10, 17], [12, 16], [14, 17], [16, 16],
      [9, 19], [11, 18], [13, 19], [15, 19], [17, 18],
    ];

    for (final coord in dataCoords) {
      canvas.drawRect(
        Rect.fromLTWH(coord[0] * unit, coord[1] * unit, unit, unit),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

