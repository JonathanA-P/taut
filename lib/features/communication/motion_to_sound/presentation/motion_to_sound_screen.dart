import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/permissions/permission_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../speech_to_text/data/speech_service_impl.dart';
import '../../speech_to_text/domain/speech_service.dart';
import '../../speech_to_text/domain/speech_state.dart';
import '../data/bisindo_detector_service.dart';
import '../data/bisindo_model_manager.dart';
import '../data/tts_service_impl.dart';
import '../domain/bisindo_labels.dart';
import '../domain/tts_service.dart';

/// Screen for Modul 2: Motion-to-Sound (Isyarat BISINDO ke Suara).
/// High-contrast, accessibility-focused interface designed for Deaf/Hard-of-Hearing users.
/// Feature Owner: Roganda Tua Tampubolon (Communication AI Lead).
class MotionToSoundScreen extends StatefulWidget {
  final PermissionService? permissionService;
  final BisindoDetectorService? detectorService;
  final TtsService? ttsService;
  final SpeechService? speechService;

  const MotionToSoundScreen({
    super.key,
    this.permissionService,
    this.detectorService,
    this.ttsService,
    this.speechService,
  });

  @override
  State<MotionToSoundScreen> createState() => _MotionToSoundScreenState();
}

class _MotionToSoundScreenState extends State<MotionToSoundScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final PermissionService _permissionService;
  late final BisindoDetectorService _detectorService;
  late final TtsService _ttsService;
  late final SpeechService _speechService;
  StreamSubscription<SpeechRecognitionState>? _speechSubscription;

  late final AnimationController _landmarkAnimController;

  bool _isListening = false;
  String _sttTranscribedText = '';

  List<CameraDescription> _availableCameras = [];
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isCameraActive = false;
  bool _isCameraInitializing = false;
  AppPermissionStatus _cameraPermission = AppPermissionStatus.unknown;

  BisindoMode _activeMode = BisindoMode.kata;
  bool _isAutoSpeak = true;

  // Sentence Builder State
  String _sentenceBuffer = '';
  String _currentLiveLabel = '';
  double _currentConfidence = 0.0;
  BoundingBox? _currentBox;
  bool _isProlongedUnrecognized = false;

  StreamSubscription<BisindoDetectionEvent>? _detectionSubscription;
  StreamSubscription<ModelState>? _modelStateSubscription;
  ModelState? _modelState;

  // Emergency / Common Quick Preset Chips
  static const List<String> _quickPresets = [
    'Halo, saya Tuli',
    'Tolong bantu saya',
    'Saya butuh ke fasilitas kesehatan terdekat',
    'Terima kasih',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
    _landmarkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    if (!isTest) {
      _landmarkAnimController.repeat(reverse: true);
    }

    _permissionService =
        widget.permissionService ?? const PermissionServiceImpl();
    _detectorService = widget.detectorService ?? BisindoDetectorService();
    _ttsService = widget.ttsService ?? TtsServiceImpl();
    _speechService = widget.speechService ?? SpeechServiceImpl();

    _speechSubscription = _speechService.statusStream.listen((state) {
      if (!mounted) return;
      setState(() {
        if (state.status == SpeechStatus.listening) {
          _isListening = true;
        } else {
          _isListening = false;
        }
      });
    });
    _speechService.initialize().catchError((_) => false);

    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // 1. Initialize TTS
    await _ttsService.initialize(language: 'id-ID');

    // 2. Initialize Model Engine
    _modelStateSubscription =
        BisindoModelManager().stateStream.listen((state) {
      if (mounted) {
        setState(() => _modelState = state);
      }
    });

    try {
      await _detectorService.initializeModel(initialMode: _activeMode);
    } catch (e) {
      debugPrint('[MotionToSoundScreen] Model load error: $e');
    }

    // 3. Listen to Detection Events
    _detectionSubscription =
        _detectorService.detectionStream.listen(_handleDetectionEvent);

    // 4. Check Camera Permission & Enumerate Cameras
    await _checkPermissionAndCameras();
  }

  Future<void> _checkPermissionAndCameras() async {
    final status =
        await _permissionService.checkPermission(AppPermissionType.camera);
    if (!mounted) return;

    setState(() => _cameraPermission = status);

    if (status == AppPermissionStatus.granted) {
      await _fetchCameras();
      final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');
      if (!isTest && _availableCameras.isNotEmpty && !_isCameraActive) {
        await _startCamera();
      }
    }
  }

  Future<void> _fetchCameras() async {
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isNotEmpty) {
        // Prefer front camera for sign language
        _selectedCameraIndex = _availableCameras.indexWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
        );
        if (_selectedCameraIndex < 0) _selectedCameraIndex = 0;
      }
    } catch (e) {
      debugPrint('[MotionToSoundScreen] Camera enumeration error: $e');
      _availableCameras = [];
    }
    if (mounted) setState(() {});
  }

  Future<void> _requestCameraPermission() async {
    final status =
        await _permissionService.requestPermission(AppPermissionType.camera);
    if (!mounted) return;

    setState(() => _cameraPermission = status);
    if (status == AppPermissionStatus.granted) {
      await _fetchCameras();
      await _startCamera();
    } else if (status == AppPermissionStatus.permanentlyDenied) {
      _showPermissionSettingsDialog();
    }
  }

  void _showPermissionSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Izin Kamera Diperlukan'),
        content: const Text(
          'Aplikasi TAUT membutuhkan izin kamera untuk mendeteksi isyarat BISINDO secara on-device. Silakan aktifkan izin di pengaturan perangkat.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _permissionService.openAppSettings();
            },
            child: const Text('Buka Pengaturan'),
          ),
        ],
      ),
    );
  }

  Future<void> _startCamera() async {
    if (_availableCameras.isEmpty) {
      await _fetchCameras();
      if (_availableCameras.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kamera tidak ditemukan pada perangkat.'),
          ),
        );
        return;
      }
    }

    setState(() => _isCameraInitializing = true);

    try {
      final camera = _availableCameras[_selectedCameraIndex];
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await controller.startImageStream((CameraImage image) {
        final isFront = camera.lensDirection == CameraLensDirection.front;
        _detectorService.processCameraImage(
          image,
          isFrontCamera: isFront,
          sensorOrientation: camera.sensorOrientation,
        );
      });

      setState(() {
        _cameraController = controller;
        _isCameraActive = true;
        _isCameraInitializing = false;
      });
    } catch (e) {
      debugPrint('[MotionToSoundScreen] Error starting camera: $e');
      if (mounted) {
        setState(() {
          _isCameraInitializing = false;
          _isCameraActive = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memulai kamera: $e')),
        );
      }
    }
  }

  Future<void> _stopCamera({bool updateUi = true}) async {
    final controller = _cameraController;
    _cameraController = null;

    if (controller != null) {
      try {
        if (controller.value.isStreamingImages) {
          await controller.stopImageStream();
        }
        await controller.dispose();
      } catch (e) {
        debugPrint('[MotionToSoundScreen] Error stopping camera: $e');
      }
    }

    if (updateUi && mounted) {
      setState(() {
        _isCameraActive = false;
        _isCameraInitializing = false;
        _currentLiveLabel = '';
        _currentConfidence = 0.0;
        _currentBox = null;
        _isProlongedUnrecognized = false;
      });
    }
  }

  Future<void> _switchCamera() async {
    if (_availableCameras.length < 2) return;

    await _stopCamera();
    _selectedCameraIndex =
        (_selectedCameraIndex + 1) % _availableCameras.length;
    await _startCamera();
  }

  void _handleDetectionEvent(BisindoDetectionEvent event) {
    if (!mounted) return;

    setState(() {
      _currentConfidence = event.result.confidence;
      _currentBox = event.boundingBox;
      _isProlongedUnrecognized = event.isProlongedUnrecognized;

      if (event.result.isRecognized) {
        _currentLiveLabel = event.result.label;
      } else {
        _currentLiveLabel = '';
      }

      // Handle validated token (passed consecutive cycle stability)
      if (event.isValidatedToken) {
        _onTokenValidated(event.result.label);
      }
    });
  }

  void _onTokenValidated(String token) {
    if (_activeMode == BisindoMode.kata) {
      // In Kata Mode: Append word + space
      final space = _sentenceBuffer.isEmpty || _sentenceBuffer.endsWith(' ')
          ? ''
          : ' ';
      _sentenceBuffer += '$space$token ';

      // Auto-speak gesture word
      if (_isAutoSpeak) {
        _ttsService.speakText(token);
      }
    } else if (_activeMode == BisindoMode.angka) {
      // In Angka Mode: Append single digit and speak natural Indonesian digit word
      _sentenceBuffer += token;
      if (_isAutoSpeak) {
        final spoken = BisindoLabels.resolveSpokenLabel(token, _activeMode);
        _ttsService.speakText(spoken);
      }
    } else {
      // In Abjad Mode: Append letter and speak letter aloud
      _sentenceBuffer += token;
      if (_isAutoSpeak) {
        _ttsService.speakText(token);
      }
    }
  }

  Future<void> _onModeChanged(BisindoMode newMode) async {
    if (_activeMode == newMode) return;

    setState(() {
      _activeMode = newMode;
      _currentLiveLabel = '';
      _currentConfidence = 0.0;
      _currentBox = null;
      _isProlongedUnrecognized = false;
    });

    await _detectorService.switchMode(newMode);
  }

  void _addSpace() {
    setState(() {
      if (!_sentenceBuffer.endsWith(' ')) {
        _sentenceBuffer += ' ';
      }
    });
  }

  void _backspace() {
    setState(() {
      if (_sentenceBuffer.isNotEmpty) {
        _sentenceBuffer =
            _sentenceBuffer.substring(0, _sentenceBuffer.length - 1);
      }
    });
  }

  void _clearSentence() {
    setState(() {
      _sentenceBuffer = '';
    });
  }

  Future<void> _speakCurrentSentence() async {
    final text = _sentenceBuffer.trim();
    if (text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bilah kalimat masih kosong untuk disuarakan.'),
        ),
      );
      return;
    }
    await _ttsService.speakText(text);
  }

  Future<void> _speakPreset(String presetText) async {
    await _ttsService.speakText(presetText);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.volume_up, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('Menyuarakan: "$presetText"')),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleSpeechListening() async {
    if (_isListening) {
      await _speechService.stopListening();
      setState(() => _isListening = false);
    } else {
      final ready = await _speechService.initialize();
      if (!ready) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat menginisialisasi mikrofon.')),
        );
        return;
      }
      setState(() {
        _isListening = true;
      });
      await _speechService.startListening(
        onResult: (text, isFinal) {
          if (!mounted) return;
          setState(() {
            _sttTranscribedText = text;
          });
        },
      );
    }
  }

  void _appendSttToSentence() {
    if (_sttTranscribedText.trim().isEmpty) return;
    setState(() {
      final space = _sentenceBuffer.isEmpty || _sentenceBuffer.endsWith(' ') ? '' : ' ';
      _sentenceBuffer += '$space${_sttTranscribedText.trim()} ';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teks ucapan disalin ke bilah kalimat.'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _stopCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _landmarkAnimController.dispose();
    _speechSubscription?.cancel();
    _speechService.dispose();
    _detectionSubscription?.cancel();
    _modelStateSubscription?.cancel();
    _stopCamera(updateUi: false);
    _ttsService.stopSpeaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Isyarat BISINDO ke Suara',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_availableCameras.length > 1 && _isCameraActive)
            IconButton(
              icon: const Icon(Icons.flip_camera_ios_rounded),
              tooltip: 'Ganti Kamera (Depan/Belakang)',
              onPressed: _switchCamera,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Badge & Privacy Banner
            _buildPrivacyBanner(),

            // Model Loading / Download Progress Indicator (if active)
            if (_modelState != null && _modelState!.isLoading)
              _buildModelLoadingBar(_modelState!),

            // 1. Viewfinder & Camera Feed with Detection Overlay
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildCameraViewfinder(),
            ),

            const SizedBox(height: 12),

            // 2. Fallback Notice Banner (When prolonged unrecognized)
            if (_isProlongedUnrecognized)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _buildUnrecognizedAlert(),
              ),

            const SizedBox(height: 8),

            // 3. 3-Tab Detection Mode Selector (Kata, Abjad, Angka)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildModeSelector(),
            ),

            const SizedBox(height: 12),

            // 4. Bilah Kalimat & TTS Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSentenceBuilder(isDark),
            ),

            const SizedBox(height: 16),

            // 5. Ucapan Lawan Bicara (Speech-to-Text) Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSpeechToTextCard(isDark),
            ),

            const SizedBox(height: 16),

            // 6. Fallback Quick Preset Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildQuickPresets(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModelLoadingBar(ModelState state) {
    return Container(
      color: AppColors.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.status == ModelLoadStatus.downloading
                  ? 'Mengunduh model AI ${(state.downloadProgress * 100).toStringAsFixed(0)}%...'
                  : 'Memuat model ke memori...',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyBanner() {
    return Container(
      color: AppColors.surfaceVariant.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          StatusBadge.development(),
          const SizedBox(width: 8),
          const Spacer(),
          const Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: AppColors.primary,
          ),
          const SizedBox(width: 4),
          const Flexible(
            child: Text(
              'On-Device AI (Privasi Terjamin)',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraViewfinder() {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isProlongedUnrecognized
              ? AppColors.error
              : (_currentLiveLabel.isNotEmpty
                  ? AppColors.primary
                  : AppColors.outline),
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera Stream Preview or Inactive Placeholder
            if (_isCameraActive &&
                _cameraController != null &&
                _cameraController!.value.isInitialized)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardW = constraints.maxWidth;
                  final cardH = constraints.maxHeight;
                  final sensorRatio = _cameraController!.value.aspectRatio;
                  final previewRatio = 1.0 / sensorRatio;

                  return SizedBox(
                    width: cardW,
                    height: cardH,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: cardW,
                        height: cardW / previewRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  );
                },
              )
            else
              _buildCameraPlaceholder(),

            // Target Guide Frame Overlay
            if (_isCameraActive) _buildGuideFrame(),

            // Dynamic Bounding Box from Object Detection
            if (_isCameraActive &&
                _currentBox != null &&
                _currentBox!.isValid &&
                _currentConfidence >= 0.65)
              _buildBoundingBoxOverlay(_currentBox!),

            // Top Status Badge (Live Detection Feedback)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildDetectionHeaderBadge(),
            ),

            // Bottom Camera Toggle Button
            Positioned(
              bottom: 12,
              right: 12,
              child: FloatingActionButton.small(
                heroTag: 'camera_toggle',
                backgroundColor:
                    _isCameraActive ? AppColors.error : AppColors.primary,
                foregroundColor: Colors.white,
                onPressed: _isCameraActive ? _stopCamera : _startCamera,
                child: Icon(
                  _isCameraActive
                      ? Icons.videocam_off_rounded
                      : Icons.videocam_rounded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPlaceholder() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isCameraInitializing) ...[
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),
              const Text(
                'Menginisialisasi Kamera...',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ] else ...[
              Icon(
                _cameraPermission == AppPermissionStatus.granted
                    ? Icons.videocam_outlined
                    : Icons.no_photography_outlined,
                size: 56,
                color: Colors.white70,
              ),
              const SizedBox(height: 12),
              Text(
                _cameraPermission == AppPermissionStatus.granted
                    ? 'Kamera Tidak Aktif\nTekan tombol untuk memulai deteksi gerakan'
                    : 'Izin Kamera Belum Diberikan',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _cameraPermission == AppPermissionStatus.granted
                    ? _startCamera
                    : _requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.camera_alt_rounded, size: 18),
                label: Text(
                  _cameraPermission == AppPermissionStatus.granted
                      ? 'Aktifkan Kamera'
                      : 'Beri Izin Kamera',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuideFrame() {
    return Center(
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.4),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Arahkan Isyarat Tangan ke Sini',
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBoundingBoxOverlay(BoundingBox box) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final top = box.ymin * constraints.maxHeight;
        final left = box.xmin * constraints.maxWidth;
        final width = (box.xmax - box.xmin) * constraints.maxWidth;
        final height = (box.ymax - box.ymin) * constraints.maxHeight;

        return Positioned(
          top: top,
          left: left,
          width: width.clamp(20.0, constraints.maxWidth),
          height: height.clamp(20.0, constraints.maxHeight),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 2.5),
              borderRadius: BorderRadius.circular(8),
              color: Colors.greenAccent.withValues(alpha: 0.1),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetectionHeaderBadge() {
    final hasDetection =
        _currentLiveLabel.isNotEmpty && _currentConfidence >= 0.65;
    final pct = (_currentConfidence * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: hasDetection
            ? Colors.green.shade900.withValues(alpha: 0.9)
            : Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDetection ? Colors.greenAccent : Colors.white24,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasDetection
                ? Icons.check_circle_rounded
                : Icons.motion_photos_on_rounded,
            color: hasDetection ? Colors.greenAccent : Colors.white70,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasDetection
                  ? 'Terdeteksi: $_currentLiveLabel ($pct%)'
                  : (_isCameraActive
                      ? 'Menunggu gerakan isyarat...'
                      : 'Kamera Siaga'),
              style: TextStyle(
                color: hasDetection ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnrecognizedAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.secondary),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Isyarat belum dikenali — Gunakan Mode Eja Abjad atau Tombol Kalimat Cepat di bawah.',
              style: TextStyle(
                color: AppColors.onSecondaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (_activeMode != BisindoMode.abjad)
            TextButton(
              onPressed: () => _onModeChanged(BisindoMode.abjad),
              child: const Text('Mode Eja'),
            ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mode Deteksi Gerakan',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        SegmentedButton<BisindoMode>(
          segments: const [
            ButtonSegment(
              value: BisindoMode.kata,
              label: Text('Kata (23)'),
              icon: Icon(Icons.chat_bubble_outline_rounded, size: 16),
            ),
            ButtonSegment(
              value: BisindoMode.abjad,
              label: Text('Abjad A–Z'),
              icon: Icon(Icons.spellcheck_rounded, size: 16),
            ),
            ButtonSegment(
              value: BisindoMode.angka,
              label: Text('Angka 0–10'),
              icon: Icon(Icons.pin_outlined, size: 16),
            ),
          ],
          selected: {_activeMode},
          onSelectionChanged: (set) => _onModeChanged(set.first),
          style: SegmentedButton.styleFrom(
            selectedBackgroundColor: AppColors.primaryContainer,
            selectedForegroundColor: AppColors.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceBuilder(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariant : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.article_outlined,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 6),
              const Text(
                'Bilah Kalimat & Ejaan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Suara Otomatis',
                    style: TextStyle(fontSize: 11),
                  ),
                  Switch(
                    value: _isAutoSpeak,
                    onChanged: (val) =>
                        setState(() => _isAutoSpeak = val),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Sentence Display Box
          Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black38 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              _sentenceBuffer.isEmpty
                  ? 'Rangkaian kata atau ejaan akan tersusun di sini...'
                  : _sentenceBuffer,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _sentenceBuffer.isEmpty
                    ? Colors.grey
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Edit Controls: Space, Backspace, Clear
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addSpace,
                  icon: const Icon(Icons.space_bar_rounded, size: 16),
                  label: const Text('Spasi', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _backspace,
                  icon: const Icon(Icons.backspace_outlined, size: 16),
                  label: const Text('Hapus 1', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Bersihkan Kalimat',
                onPressed: _clearSentence,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Large High-Contrast "Suarakan Sekarang" Button
          AppButton(
            label: 'Suarakan Sekarang 🔊',
            onPressed:
                _sentenceBuffer.trim().isEmpty ? null : _speakCurrentSentence,
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechToTextCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariant : const Color(0xFFF0F5EE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isListening ? AppColors.primary : AppColors.outline,
          width: _isListening ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.record_voice_over_rounded,
                size: 18,
                color: _isListening ? AppColors.primary : AppColors.darkGreen,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Ucapan Lawan Bicara (STT)',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isListening
                      ? const Color(0xFF2E7D32).withValues(alpha: 0.15)
                      : Colors.grey.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.green : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isListening ? 'Mendengar' : 'Nonaktif',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _isListening
                            ? Colors.green.shade800
                            : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Speech Output Bubble
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? Colors.black38 : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.outline),
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              _sttTranscribedText.isEmpty
                  ? 'Tekan tombol mikrofon di bawah agar suara lawan bicara otomatis diubah menjadi teks di sini...'
                  : _sttTranscribedText,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _sttTranscribedText.isEmpty
                    ? Colors.grey
                    : (isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _toggleSpeechListening,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isListening
                        ? const Color(0xFFD32F2F)
                        : AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _isListening ? 'Berhenti Dengar' : 'Dengarkan Ucapan',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              if (_sttTranscribedText.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Salin ke Bilah Kalimat',
                  onPressed: _appendSttToSentence,
                  icon: const Icon(Icons.add_comment_outlined, size: 18),
                ),
                const SizedBox(width: 4),
                IconButton.outlined(
                  tooltip: 'Hapus Teks Ucapan',
                  onPressed: () => setState(() => _sttTranscribedText = ''),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tombol Cepat Pesan Ringkas (Darurat & Umum)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickPresets.map((preset) {
            return ActionChip(
              avatar: const Icon(
                Icons.volume_up,
                size: 16,
                color: AppColors.primary,
              ),
              label: Text(
                preset,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              backgroundColor:
                  AppColors.primaryContainer.withValues(alpha: 0.5),
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              onPressed: () => _speakPreset(preset),
            );
          }).toList(),
        ),
      ],
    );
  }
}
