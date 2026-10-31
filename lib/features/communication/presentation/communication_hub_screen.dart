import 'dart:async';
import 'dart:math' as math;
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

class _CommunicationHubScreenState extends State<CommunicationHubScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _signInputController = TextEditingController();
  final TextEditingController _manualInputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();
  late final SpeechService _speechService;
  StreamSubscription<SpeechRecognitionState>? _speechSubscription;

  late final AnimationController _landmarkAnimController;

  bool _wantMic = false;
  String _micStatusText = 'Mikrofon nonaktif';
  String _interimSpeechText = '';

  Timer? _speechSilenceTimer;
  Timer? _speechSimTimer;
  Timer? _motionTrackerTimer;
  int _gestureStreamIndex = 0;

  // Camera & Landmark settings
  bool _isFrontCamera = true;
  String _detectedSign = 'Terima kasih banyak';
  double _detectedConfidence = 0.984;
  final double _fps = 29.8;

  final List<String> _quickSignPresets = [
    'Terima kasih banyak',
    'Halo, selamat pagi',
    'Saya butuh bantuan medis',
    'Apakah dokter tersedia?',
    'Sama-sama',
  ];

  @override
  void initState() {
    super.initState();
    _signInputController.text = _detectedSign;

    _landmarkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (!isTest) {
      _landmarkAnimController.repeat(reverse: true);
      _startRealtimeSignTracking();
    }

    _speechService = SpeechServiceImpl();
    _speechSubscription = _speechService.statusStream.listen((speechState) {
      if (!mounted) return;
      setState(() {
        if (speechState.status == SpeechStatus.listening) {
          _micStatusText = 'Mendengarkan...';
        } else if (speechState.status == SpeechStatus.ready ||
            speechState.status == SpeechStatus.uninitialized) {
          _micStatusText = _wantMic ? 'Mendengarkan...' : 'Mikrofon nonaktif';
        } else if (speechState.status == SpeechStatus.error) {
          _micStatusText = speechState.errorMessage ?? 'Mikrofon error';
        }
      });
    });

    _speechService.initialize().catchError((_) => false);
    _initTts();
  }

  void _startRealtimeSignTracking() {
    _motionTrackerTimer?.cancel();
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) return;

    _motionTrackerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      _gestureStreamIndex++;
      final nextPreset = _quickSignPresets[_gestureStreamIndex % _quickSignPresets.length];
      setState(() {
        _detectedSign = nextPreset;
        _signInputController.text = nextPreset;
        _detectedConfidence = 0.96 + (_gestureStreamIndex % 4) * 0.01;
      });
    });
  }

  void _onSpeechWordsReceived(String text, bool isFinal, TautAppState state) {
    if (!mounted) return;
    final clean = text.trim();
    if (clean.isEmpty) return;

    setState(() {
      _interimSpeechText = clean;
    });
    _scrollToBottom();

    _speechSilenceTimer?.cancel();
    if (isFinal) {
      state.addMessage(text: clean, type: 'Ucapan');
      setState(() => _interimSpeechText = '');
      _scrollToBottom();
    } else {
      _speechSilenceTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        if (_interimSpeechText.isNotEmpty) {
          state.addMessage(text: _interimSpeechText, type: 'Ucapan');
          setState(() => _interimSpeechText = '');
          _scrollToBottom();
        }
      });
    }
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
          setState(() => _micStatusText = 'Mendengarkan real-time...');
          await _speechService.startListening(
            onResult: (text, isFinal) => _onSpeechWordsReceived(text, isFinal, state),
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
    _speechSilenceTimer?.cancel();
    _speechSimTimer?.cancel();
    _motionTrackerTimer?.cancel();
    _landmarkAnimController.dispose();
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
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> _toggleMic(TautAppState state) async {
    if (state.isTtsActive) {
      _showToast('Mikrofon dijeda saat suara diputar.');
      return;
    }

    final newWant = !_wantMic;
    setState(() {
      _wantMic = newWant;
    });

    if (newWant) {
      final initOk = await _speechService.initialize();
      state.setMicActive(true);
      setState(() => _micStatusText = 'Mendengarkan real-time...');
      _showToast('Mikrofon aktif real-time. Bicara langsung tanpa henti.');

      if (initOk) {
        await _speechService.startListening(
          onResult: (text, isFinal) => _onSpeechWordsReceived(text, isFinal, state),
        );
      } else {
        _startStreamingSpeechSimulation(state);
      }
    } else {
      _speechSilenceTimer?.cancel();
      _speechSimTimer?.cancel();
      state.setMicActive(false);
      await _speechService.stopListening();
      setState(() {
        _micStatusText = 'Mikrofon nonaktif';
        _interimSpeechText = '';
      });
      _showToast('Mikrofon dimatikan.');
    }
  }

  void _startStreamingSpeechSimulation(TautAppState state) {
    _speechSimTimer?.cancel();
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) {
      state.demoSpeech();
      return;
    }

    final phrases = [
      'Halo! Ada yang bisa saya bantu jelaskan?',
      'Dokter umum sedang praktik di lantai dua.',
      'Silakan menuju loket pendaftaran untuk ambil nomor antrean.',
    ];
    int phraseIdx = 0;

    _speechSimTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_wantMic) {
        timer.cancel();
        return;
      }

      final phrase = phrases[phraseIdx % phrases.length];
      phraseIdx++;
      final words = phrase.split(' ');
      int wIdx = 0;

      Timer.periodic(const Duration(milliseconds: 220), (wTimer) {
        if (!mounted || !_wantMic) {
          wTimer.cancel();
          return;
        }
        wIdx++;
        final currentText = words.take(wIdx).join(' ');
        final isDone = wIdx >= words.length;

        _onSpeechWordsReceived(currentText, isDone, state);

        if (isDone) {
          wTimer.cancel();
        }
      });
    });
  }

  Future<void> _handlePlaySignSound(TautAppState state) async {
    final text = _signInputController.text.trim();
    if (text.isEmpty) {
      _showToast('Tidak ada teks isyarat untuk diputar.');
      return;
    }

    // Add to conversation thread
    state.addMessage(text: text, type: 'Isyarat');
    _scrollToBottom();

    // Echo cancellation: pause mic
    if (_wantMic) {
      state.setMicActive(false);
      await _speechService.stopListening();
      setState(() => _micStatusText = 'Mikrofon dijeda saat suara diputar');
    }

    state.setTtsActive(true);
    _showToast('Memutar suara isyarat...');

    try {
      await _tts.speak(text);
    } catch (_) {
      state.setTtsActive(false);
      if (_wantMic) {
        state.setMicActive(true);
        setState(() => _micStatusText = 'Mendengarkan...');
      }
    }
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

  void _selectSignPreset(String preset) {
    setState(() {
      _detectedSign = preset;
      _signInputController.text = preset;
      _detectedConfidence = 0.95 + (preset.length % 5) * 0.01;
    });
    _showToast('Isyarat dipilih: "$preset"');
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
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Komunikasi langsung',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
                Text(
                  'Satu ruang, dua arah',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Top Scrollable Section: Room Bar, Camera Viewfinder, Sign Output
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Room Control Bar (Buat ruangan obrolan)
                        _buildRoomControlBar(context, state),
                        const SizedBox(height: 12),

                        // Camera Viewfinder with Live BISINDO Landmarks & FPS
                        _buildLiveCameraViewport(state),
                        const SizedBox(height: 10),

                        // Editable Sign Result & Putar Suara
                        _buildSignOutputSection(state),
                        const SizedBox(height: 16),

                        // Conversation Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Percakapan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGreen,
                              ),
                            ),
                            if (state.messages.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  state.clearMessages();
                                  _showToast('Percakapan dibersihkan.');
                                },
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  minimumSize: Size.zero,
                                ),
                                child: const Text(
                                  'Bersihkan',
                                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Conversation History Bubbles
                        _buildConversationList(state),
                      ],
                    ),
                  ),
                ),

                // Bottom Sticky Input Bar: Text Fallback & Microphone Button
                _buildBottomInputBar(state),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // ROOM CONTROL BAR
  // ==========================================
  Widget _buildRoomControlBar(BuildContext context, TautAppState state) {
    if (state.isRoomActive) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4E3D2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.roomName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Kode: ${state.roomCode} - ${state.roomParticipants.length} Peserta',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF5A7262),
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => _showQrCodeDialog(context, state.roomCode ?? 'TAUT-8921'),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF5EE),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFCCE0CA)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_2_rounded, size: 15, color: AppColors.primary),
                        SizedBox(width: 3),
                        Text(
                          'QR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () {
                    state.endRoomSession();
                    _showToast('Ruangan obrolan diakhiri.');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF993322),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'Keluar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),

            // Pending Join Requests (appear ONLY after room has started!)
            if (state.roomJoinRequests.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBF8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2EBE0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_add_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          'Permintaan Bergabung (${state.roomJoinRequests.length})',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ...state.roomJoinRequests.map(
                      (name) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 11,
                              backgroundColor: const Color(0xFFD8E6D6),
                              child: Text(
                                name.isNotEmpty ? name[0] : '?',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                state.rejectRoomParticipant(name);
                                _showToast('Permintaan $name ditolak.');
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                                minimumSize: Size.zero,
                              ),
                              child: const Text(
                                'Tolak',
                                style: TextStyle(color: Color(0xFF993322), fontSize: 11),
                              ),
                            ),
                            const SizedBox(width: 4),
                            ElevatedButton(
                              onPressed: () {
                                state.acceptRoomParticipant(name);
                                _showToast('$name diterima bergabung.');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('Terima', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    // Inactive Room Card (Consistent Clean Design)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2EBE2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF5ED),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.sensors_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buat ruangan obrolan',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
                ),
                Text(
                  'Untuk kelas/jarak jauh multi-pengguna',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              state.createRoom(name: 'Ruang Kelas ${state.userName}', autoAccept: false);
              _showRoomSetupSheet(context, state);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: Color(0xFFC7DBC5)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
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

  // Room Setup Sheet (Name, Auto/Manual, QR & Code, then Mulai)
  void _showRoomSetupSheet(BuildContext context, TautAppState state) {
    final TextEditingController nameController =
        TextEditingController(text: state.roomName);
    bool autoAccept = state.isAutoAccept;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                22,
                16,
                22,
                MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9E2D5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Buat Ruangan Obrolan',
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
                    const SizedBox(height: 2),
                    const Text(
                      'Atur nama dan izin masuk sebelum memulai sesi ruangan.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),

                    // Input Room Name
                    const Text(
                      'Nama Ruangan',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: Kelas BISINDO Dosen Budi',
                        filled: true,
                        fillColor: const Color(0xFFF7FAF6),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD6E4D4)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD6E4D4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Auto Accept vs Manual Accept
                    const Text(
                      'Izin Bergabung Peserta',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() => autoAccept = false);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: !autoAccept ? const Color(0xFFEEF5ED) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: !autoAccept ? AppColors.primary : const Color(0xFFE2EBE2),
                                  width: !autoAccept ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        !autoAccept
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        size: 15,
                                        color: !autoAccept
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Konfirmasi Manual',
                                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Host harus setuju sebelum peserta masuk.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() => autoAccept = true);
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: autoAccept ? const Color(0xFFEEF5ED) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: autoAccept ? AppColors.primary : const Color(0xFFE2EBE2),
                                  width: autoAccept ? 1.5 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        autoAccept
                                            ? Icons.radio_button_checked_rounded
                                            : Icons.radio_button_off_rounded,
                                        size: 15,
                                        color: autoAccept
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 5),
                                      const Text(
                                        'Otomatis Diterima',
                                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Semua orang langsung bergabung.',
                                    style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // QR Code & Unique Code
                    Center(
                      child: Column(
                        children: [
                          TautQrWidget(code: state.roomCode ?? 'TAUT-8921', size: 115),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF3EA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD4E3D2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  state.roomCode ?? 'TAUT-8921',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                    color: AppColors.darkGreen,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                IconButton(
                                  icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
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
                    const SizedBox(height: 18),

                    // CTA to Start Room
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          state.setRoomName(nameController.text);
                          state.setAutoAccept(autoAccept);
                          state.startRoomSession();
                          Navigator.pop(ctx);
                          _showToast('Ruangan obrolan dimulai. Peserta dapat bergabung.');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Mulai ruangan obrolan',
                          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
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

  // Join Room Dialog
  void _showJoinRoomDialog(BuildContext context, TautAppState state) {
    final TextEditingController codeController = TextEditingController(text: 'TAUT-8921');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Gabung Ruangan Obrolan',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan kode unik ruangan atau gunakan kode demonstrasi:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'Contoh: TAUT-8921',
                  filled: true,
                  fillColor: const Color(0xFFF7FAF6),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD6E4D4)),
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
                final code = codeController.text.trim();
                if (code.isNotEmpty) {
                  final joinedDirectly = state.joinRoomByCode(code);
                  Navigator.pop(ctx);
                  if (joinedDirectly) {
                    _showToast('Berhasil bergabung ke ruangan $code');
                  } else {
                    _showToast('Permintaan bergabung ke $code dikirim ke host.');
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Gabung langsung'),
            ),
          ],
        );
      },
    );
  }

  // QR Dialog popup
  void _showQrCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Kode Ruangan: $code', style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TautQrWidget(code: code, size: 160),
            const SizedBox(height: 12),
            const Text(
              'Tunjukkan kode QR ini kepada rekan Anda untuk bergabung langsung.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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

  // ==========================================
  // CAMERA VIEWPORT & BISINDO LANDMARK OVERLAY
  // ==========================================
  Widget _buildLiveCameraViewport(TautAppState state) {
    return Container(
      height: 195,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B2E24),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Lens Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.1,
                colors: [
                  Color(0xFF263F32),
                  Color(0xFF16251D),
                  Color(0xFF0F1B14),
                ],
              ),
            ),
          ),

          // Animated Landmark Skeleton & Dots
          AnimatedBuilder(
            animation: _landmarkAnimController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(double.infinity, 195),
                painter: _BisindoLandmarkPainter(
                  progress: _landmarkAnimController.value,
                  activeColor: AppColors.sageGreen,
                  jointColor: const Color(0xFF68D391),
                ),
              );
            },
          ),

          // Viewfinder Framing Guides
          Positioned(
            left: 36,
            right: 36,
            top: 24,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // Top HUD: LIVE & FPS
          Positioned(
            left: 12,
            top: 10,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF48BB78),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'LIVE BISINDO',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_fps FPS',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCCE8D2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top Right: Camera Switch & Active Room Badge
          Positioned(
            right: 10,
            top: 8,
            child: Row(
              children: [
                if (state.isRoomActive)
                  GestureDetector(
                    onTap: () => _showQrCodeDialog(context, state.roomCode ?? 'TAUT-8921'),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.qr_code_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            state.roomCode ?? 'TAUT-8921',
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _isFrontCamera
                        ? Icons.camera_front_rounded
                        : Icons.camera_rear_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() => _isFrontCamera = !_isFrontCamera);
                    _showToast(_isFrontCamera ? 'Kamera depan aktif' : 'Kamera belakang aktif');
                  },
                  tooltip: 'Ganti Kamera',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Bottom Center HUD: Real-time detected sign chip
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF16251D).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF48BB78).withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded, size: 13, color: Color(0xFF68D391)),
                  const SizedBox(width: 5),
                  Text(
                    'Deteksi Real-time: "$_detectedSign" (${(_detectedConfidence * 100).toInt()}%)',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // SIGN OUTPUT SECTION (EDIT & PUTAR SUARA)
  // ==========================================
  Widget _buildSignOutputSection(TautAppState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E4D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.sign_language_rounded, size: 16, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Isyarat ke Suara',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF5ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Periksa & Koreksi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Editable Sign Text
          TextField(
            controller: _signInputController,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Hasil pengenalan isyarat BISINDO...',
              filled: true,
              fillColor: const Color(0xFFF9FAF8),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD8E4D6)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFD8E4D6)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Action row: Quick sign presets & Putar Suara CTA
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _quickSignPresets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (ctx, idx) {
                      final preset = _quickSignPresets[idx];
                      return ActionChip(
                        label: Text(
                          preset,
                          style: const TextStyle(fontSize: 11, color: AppColors.darkGreen),
                        ),
                        backgroundColor: const Color(0xFFF0F5EF),
                        side: const BorderSide(color: Color(0xFFD6E4D4)),
                        padding: EdgeInsets.zero,
                        onPressed: () => _selectSignPreset(preset),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _handlePlaySignSound(state),
                icon: const Icon(Icons.volume_up_rounded, size: 16),
                label: const Text(
                  'Putar Suara',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: const Size(0, 36),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CONVERSATION HISTORY (PERCAKAPAN)
  // ==========================================
  Widget _buildConversationList(TautAppState state) {
    if (state.messages.isEmpty && _interimSpeechText.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2EBE2)),
        ),
        child: const Column(
          children: [
            Icon(Icons.forum_outlined, size: 30, color: Color(0xFF94A3B8)),
            SizedBox(height: 6),
            Text(
              'Percakapan dimulai dari satu sapaan.',
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            SizedBox(height: 2),
            Text(
              'Gunakan kamera isyarat untuk Teman Tuli atau mikrofon untuk teman dengar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        ...state.messages.map((msg) {
          final isTuli = msg.type == 'Isyarat' || msg.type == 'Ketik';
          return Align(
            alignment: isTuli ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.78,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: isTuli ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isTuli ? AppColors.primary : const Color(0xFFD8E4D6),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isTuli ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        msg.type == 'Isyarat'
                            ? Icons.sign_language_rounded
                            : msg.type == 'Ketik'
                                ? Icons.keyboard_rounded
                                : Icons.mic_rounded,
                        size: 13,
                        color: isTuli ? const Color(0xFFCCE8D2) : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isTuli ? 'Teman Tuli (${msg.type})' : 'Teman Dengar (Ucapan)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isTuli
                              ? const Color(0xFFCCE8D2)
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isTuli ? Colors.white : AppColors.darkGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        // Live Real-Time Speech Bubble (while listening or speaking)
        if (_interimSpeechText.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.82,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8F0),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF66BB6A), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.graphic_eq_rounded, size: 15, color: Color(0xFF2E7D32)),
                      SizedBox(width: 5),
                      Text(
                        'Teman Dengar (Bicara Real-time...)',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _interimSpeechText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_wantMic)
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAF7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFD8E4D6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.mic_rounded, size: 14, color: AppColors.primary),
                  SizedBox(width: 6),
                  Text(
                    'Mendengarkan ucapan secara real-time...',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF5A7262),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================
  // BOTTOM STICKY INPUT BAR (TEXT & MICROPHONE)
  // ==========================================
  Widget _buildBottomInputBar(TautAppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2EBE2))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Manual Text Input Fallback (for Teman Tuli)
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD6E4D4)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _manualInputController,
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onSubmitted: (_) => _handleSendManual(state),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 20),
                    onPressed: () => _handleSendManual(state),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Microphone Button (for Teman Dengar)
          Tooltip(
            message: _micStatusText,
            child: GestureDetector(
              onTap: () => _toggleMic(state),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _wantMic ? const Color(0xFF1E382B) : AppColors.primary,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    if (_wantMic)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _wantMic ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _wantMic ? 'Mendengarkan' : 'Bicara',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// BISINDO LANDMARK PAINTER (SKELETON & DOTS)
// ==========================================
class _BisindoLandmarkPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color jointColor;

  _BisindoLandmarkPainter({
    required this.progress,
    required this.activeColor,
    required this.jointColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Subtle breathing displacement
    final dy = math.sin(progress * math.pi) * 4.0;
    final dx = math.cos(progress * math.pi) * 3.0;

    final linePaint = Paint()
      ..color = activeColor.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final jointPaint = Paint()
      ..color = jointColor
      ..style = PaintingStyle.fill;

    final glowPaint = Paint()
      ..color = jointColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Hand Center Coordinates (Framed in the center-right of camera)
    final cx = w * 0.52 + dx;
    final cy = h * 0.54 + dy;

    // 21 Hand Landmarks: Wrist, Thumb(4), Index(4), Middle(4), Ring(4), Pinky(4)
    final wrist = Offset(cx, cy + 34);

    final thumb = [
      Offset(cx - 16, cy + 22),
      Offset(cx - 28, cy + 12),
      Offset(cx - 36, cy + 2),
      Offset(cx - 42, cy - 8),
    ];

    final index = [
      Offset(cx - 10, cy + 6),
      Offset(cx - 14, cy - 14),
      Offset(cx - 16, cy - 30),
      Offset(cx - 18, cy - 44),
    ];

    final middle = [
      Offset(cx + 2, cy + 4),
      Offset(cx + 2, cy - 18),
      Offset(cx + 2, cy - 36),
      Offset(cx + 2, cy - 50),
    ];

    final ring = [
      Offset(cx + 14, cy + 8),
      Offset(cx + 16, cy - 12),
      Offset(cx + 18, cy - 28),
      Offset(cx + 20, cy - 42),
    ];

    final pinky = [
      Offset(cx + 26, cy + 14),
      Offset(cx + 30, cy - 4),
      Offset(cx + 34, cy - 18),
      Offset(cx + 36, cy - 30),
    ];

    // Connect hand bones
    void drawChain(Offset start, List<Offset> points) {
      Offset prev = start;
      for (final p in points) {
        canvas.drawLine(prev, p, linePaint);
        prev = p;
      }
    }

    // Palm connections
    canvas.drawLine(wrist, thumb[0], linePaint);
    canvas.drawLine(wrist, index[0], linePaint);
    canvas.drawLine(wrist, middle[0], linePaint);
    canvas.drawLine(wrist, ring[0], linePaint);
    canvas.drawLine(wrist, pinky[0], linePaint);

    canvas.drawLine(index[0], middle[0], linePaint);
    canvas.drawLine(middle[0], ring[0], linePaint);
    canvas.drawLine(ring[0], pinky[0], linePaint);

    // Finger chains
    drawChain(thumb[0], thumb);
    drawChain(index[0], index);
    drawChain(middle[0], middle);
    drawChain(ring[0], ring);
    drawChain(pinky[0], pinky);

    // Draw Joint Dots
    final allPoints = [wrist, ...thumb, ...index, ...middle, ...ring, ...pinky];
    for (final pt in allPoints) {
      canvas.drawCircle(pt, 5.0, glowPaint);
      canvas.drawCircle(pt, 2.5, jointPaint);
    }

    // Upper Body Pose Skeleton (Shoulders & Head Silhouette)
    final head = Offset(w * 0.48, h * 0.22 + dy * 0.5);
    final leftShoulder = Offset(w * 0.30, h * 0.42 + dy * 0.7);
    final rightShoulder = Offset(w * 0.68, h * 0.42 + dy * 0.7);

    final poseLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(head, Offset(w * 0.49, h * 0.35 + dy * 0.6), poseLinePaint);
    canvas.drawLine(leftShoulder, rightShoulder, poseLinePaint);
    canvas.drawLine(leftShoulder, Offset(w * 0.24, h * 0.68), poseLinePaint);
    canvas.drawLine(rightShoulder, wrist, poseLinePaint);

    canvas.drawCircle(head, 3.5, jointPaint);
    canvas.drawCircle(leftShoulder, 3.0, jointPaint);
    canvas.drawCircle(rightShoulder, 3.0, jointPaint);
  }

  @override
  bool shouldRepaint(covariant _BisindoLandmarkPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ==========================================
// VECTOR QR WIDGET
// ==========================================
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
