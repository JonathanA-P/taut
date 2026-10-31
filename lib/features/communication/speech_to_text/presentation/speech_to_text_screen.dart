import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../data/flutter_text_to_speech_service.dart';
import '../data/speech_service_impl.dart';
import '../domain/speech_service.dart';
import '../domain/text_to_speech_service.dart';

/// Screen for Speech-to-Text and Text-to-Speech communication.
/// Bridges two-way communication between Deaf and hearing individuals.
/// Feature Owner: Roganda Tua Tampubolon (Branch: feature/speech-to-text).
class SpeechToTextScreen extends StatefulWidget {
  final TextToSpeechService? ttsService;
  final SpeechService? speechService;

  const SpeechToTextScreen({super.key, this.ttsService, this.speechService});

  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late final TextToSpeechService _ttsService;
  late final SpeechService _speechService;

  final TextEditingController _ttsTextController = TextEditingController();
  final TextEditingController _sttTextController = TextEditingController();

  StreamSubscription<bool>? _speakingSubscription;
  bool _isSpeaking = false;
  bool _isListening = false;

  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;

  static const List<String> _quickPhrases = [
    'Halo, salam kenal!',
    'Saya teman Tuli, mohon bantuannya.',
    'Bisa tolong tuliskan di layar?',
    'Terima kasih banyak!',
    'Saya butuh bantuan medis segera.',
    'Di mana ruang periksa atau apotek?',
    'Permisi, boleh saya bertanya?',
  ];

  @override
  void initState() {
    super.initState();
    _ttsService = widget.ttsService ?? FlutterTextToSpeechService();
    _speechService = widget.speechService ?? SpeechServiceImpl();

    _ttsService.initialize(language: 'id-ID');
    _speechService.initialize();

    _speakingSubscription = _ttsService.isSpeakingStream.listen((speaking) {
      if (mounted) {
        setState(() {
          _isSpeaking = speaking;
        });
      }
    });
  }

  @override
  void dispose() {
    _speakingSubscription?.cancel();
    _ttsTextController.dispose();
    _sttTextController.dispose();
    _ttsService.stopSpeaking();
    _speechService.dispose();
    super.dispose();
  }

  Future<void> _speakText(String text) async {
    final target = text.trim();
    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ketik pesan atau pilih ungkapan terlebih dahulu.'),
        ),
      );
      return;
    }

    await _ttsService.speakText(target);
    if (mounted) {
      setState(() {
        _isSpeaking = _ttsService.isSpeaking;
      });
    }
  }

  Future<void> _stopSpeaking() async {
    await _ttsService.stopSpeaking();
    if (mounted) {
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _toggleListening() {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      _speechService.startListening(
        onResult: (text, isFinal) {
          if (mounted) {
            setState(() {
              _sttTextController.text = text;
            });
          }
        },
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Mendengarkan ucapan bahasa Indonesia (Mikrofon aktif)...',
          ),
        ),
      );
    } else {
      _speechService.stopListening();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perekaman audio dihentikan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Komunikasi Suara & Teks'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.onSurfaceVariant,
            tabs: [
              Tab(
                icon: Icon(Icons.record_voice_over_rounded),
                text: 'Teks ke Suara (TTS)',
              ),
              Tab(icon: Icon(Icons.mic_rounded), text: 'Suara ke Teks (STT)'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildTtsTab(), _buildSttTab()]),
      ),
    );
  }

  Widget _buildTtsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: StatusBadge.active()),
          const SizedBox(height: 16),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Text-to-Speech (Bahasa Indonesia)',
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Ketik pesan atau pilih ungkapan cepat di bawah. TAUT akan membacakan teks dengan suara lantang dalam bahasa Indonesia untuk lawan bicara.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Ungkapan Cepat (Quick Phrases)',
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickPhrases.map((phrase) {
              return ActionChip(
                label: Text(phrase),
                avatar: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                onPressed: () {
                  setState(() {
                    _ttsTextController.text = phrase;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pesan yang Akan Diucapkan',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (_ttsTextController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          tooltip: 'Hapus Teks',
                          onPressed: () {
                            setState(() {
                              _ttsTextController.clear();
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ttsTextController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Ketik kalimat yang ingin dibacakan oleh suara sistem...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16, height: 1.4),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          if (_isSpeaking) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sedang berbicara dalam bahasa Indonesia...',
                      style: TextStyle(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: AppButton(
                  label: _isSpeaking
                      ? 'Sedang Bicara...'
                      : 'Ucapkan Suara (TTS)',
                  icon: Icons.volume_up_rounded,
                  onPressed: () => _speakText(_ttsTextController.text),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: AppButton(
                  label: 'Hentikan',
                  icon: Icons.stop_rounded,
                  isOutlined: true,
                  onPressed: _isSpeaking ? _stopSpeaking : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            leading: const Icon(Icons.tune_rounded, color: AppColors.primary),
            title: const Text('Pengaturan Suara'),
            subtitle: const Text('Kecepatan Bicara, Nada & Volume'),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Kecepatan:'),
                        Expanded(
                          child: Slider(
                            value: _speechRate,
                            min: 0.2,
                            max: 1.0,
                            divisions: 8,
                            label: '${_speechRate.toStringAsFixed(1)}x',
                            onChanged: (val) {
                              setState(() => _speechRate = val);
                              _ttsService.setSpeechRate(val);
                            },
                          ),
                        ),
                        Text('${_speechRate.toStringAsFixed(1)}x'),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Nada (Pitch):'),
                        Expanded(
                          child: Slider(
                            value: _pitch,
                            min: 0.5,
                            max: 1.5,
                            divisions: 10,
                            label: _pitch.toStringAsFixed(1),
                            onChanged: (val) {
                              setState(() => _pitch = val);
                              _ttsService.setPitch(val);
                            },
                          ),
                        ),
                        Text(_pitch.toStringAsFixed(1)),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Volume:'),
                        Expanded(
                          child: Slider(
                            value: _volume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: '${(_volume * 100).toInt()}%',
                            onChanged: (val) {
                              setState(() => _volume = val);
                              _ttsService.setVolume(val);
                            },
                          ),
                        ),
                        Text('${(_volume * 100).toInt()}%'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSttTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: StatusBadge.development()),
          const SizedBox(height: 16),
          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Panduan Suara ke Teks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tekan tombol mikrofon untuk merekam ucapan lawan bicara. Ucapan bahasa Indonesia akan dikonversi menjadi teks yang dapat dibaca dengan jelas oleh teman Tuli.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.outline),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hasil Transkripsi',
                        style: Theme.of(context).textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (_isListening)
                        const Row(
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Mendengarkan...',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _sttTextController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Teks transkripsi ucapan akan muncul di sini. Anda juga dapat mengetik langsung...',
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 18, height: 1.5),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 76,
              height: 76,
              child: ElevatedButton(
                onPressed: _toggleListening,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.zero,
                  backgroundColor: _isListening
                      ? AppColors.error
                      : AppColors.primary,
                ),
                child: Icon(
                  _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                  size: 34,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isListening ? 'Ketuk untuk berhenti' : 'Ketuk untuk mulai bicara',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Putar TTS',
                  icon: Icons.volume_up_rounded,
                  isOutlined: true,
                  onPressed: _sttTextController.text.trim().isNotEmpty
                      ? () => _speakText(_sttTextController.text)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Bersihkan',
                  isOutlined: true,
                  onPressed: () {
                    setState(() {
                      _sttTextController.clear();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
