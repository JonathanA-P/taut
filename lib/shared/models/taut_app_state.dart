import 'dart:async';
import 'package:flutter/material.dart';

/// Single source of truth state for the TAUT prototype.
/// Replicates the exact reactive state and behaviors of the HTML prototype:
/// - User name
/// - Friends list
/// - Active location sharing sessions with live countdown
/// - Conversation history (Speech, Sign, Typed)
/// - Facility filtering & searching
/// - Font size scaling (16px, 19px, 22px)
/// - Microphone & Camera states
/// - TTS speech echo protection
class TautAppState extends ChangeNotifier {
  static final TautAppState _instance = TautAppState._internal();
  factory TautAppState() => _instance;

  TautAppState._internal() {
    // Timers are started on demand when active sessions exist
  }

  // User Profile
  String _userName = 'Adriel';
  String get userName => _userName;

  void setUserName(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      _userName = trimmed;
      notifyListeners();
    }
  }

  // Friends
  List<String> _friends = ['Nadia', 'Raka', 'Dinda'];
  List<String> get friends => List.unmodifiable(_friends);

  bool addFriend(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    if (_friends.any((f) => f.toLowerCase() == trimmed.toLowerCase())) {
      return false;
    }
    _friends.add(trimmed);
    notifyListeners();
    return true;
  }

  // Location Sharing Sessions
  final List<SharingSession> _sessions = [];
  List<SharingSession> get sessions => List.unmodifiable(_sessions);
  bool get isSharingLocation => _sessions.isNotEmpty;

  void startSharing({required String recipient, required int durationMinutes}) {
    _sessions.removeWhere((s) => s.name == recipient);
    final expiry = DateTime.now().add(Duration(minutes: durationMinutes));
    _sessions.add(SharingSession(name: recipient, expiry: expiry));
    _startSessionExpiryTimer();
    notifyListeners();
  }

  void stopSharing(int index) {
    if (index >= 0 && index < _sessions.length) {
      _sessions.removeAt(index);
      if (_sessions.isEmpty) {
        _expiryTimer?.cancel();
        _expiryTimer = null;
      }
      notifyListeners();
    }
  }

  void stopSharingByName(String name) {
    _sessions.removeWhere((s) => s.name == name);
    if (_sessions.isEmpty) {
      _expiryTimer?.cancel();
      _expiryTimer = null;
    }
    notifyListeners();
  }

  Timer? _expiryTimer;
  void _startSessionExpiryTimer() {
    _expiryTimer?.cancel();
    if (_sessions.isEmpty) return;
    _expiryTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final countBefore = _sessions.length;
      _sessions.removeWhere((s) => s.expiry.isBefore(now));
      if (_sessions.isEmpty) {
        _expiryTimer?.cancel();
        _expiryTimer = null;
      }
      if (_sessions.length != countBefore) {
        notifyListeners();
      }
    });
  }

  void cancelTimers() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
  }

  // Conversation History
  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void addMessage({
    required String text,
    required String type, // 'Ucapan' | 'Isyarat' | 'Ketik'
    bool isDemo = false,
  }) {
    _messages.add(ChatMessage(text: text, type: type, isDemo: isDemo));
    notifyListeners();
  }

  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  // Communication Channel States
  bool _isMicActive = false;
  bool get isMicActive => _isMicActive;

  bool _isCamActive = false;
  bool get isCamActive => _isCamActive;

  bool _isTtsActive = false;
  bool get isTtsActive => _isTtsActive;

  String _signText = '';
  String get signText => _signText;

  String _transcriptText = 'Ucapan teman dengar akan tampil di sini.';
  String get transcriptText => _transcriptText;

  int _demoStep = 0;

  void setMicActive(bool active) {
    _isMicActive = active;
    notifyListeners();
  }

  void setCamActive(bool active) {
    _isCamActive = active;
    notifyListeners();
  }

  void setTtsActive(bool active) {
    _isTtsActive = active;
    notifyListeners();
  }

  void setSignText(String text) {
    _signText = text;
    notifyListeners();
  }

  void setTranscriptText(String text) {
    _transcriptText = text;
    notifyListeners();
  }

  void demoSign() {
    final samples = [
      'Halo, senang bertemu denganmu.',
      'Terima kasih.',
      'Saya ingin bertanya.',
    ];
    _signText = samples[_demoStep++ % samples.length];
    notifyListeners();
  }

  void demoSpeech() {
    const text = 'Halo! Ada yang bisa saya bantu?';
    _transcriptText = text;
    addMessage(text: text, type: 'Ucapan', isDemo: true);
  }

  void endCommunicationSession() {
    _isMicActive = false;
    _isCamActive = false;
    _isTtsActive = false;
    _signText = '';
    _transcriptText = 'Ucapan teman dengar akan tampil di sini.';
    _messages.clear();
    notifyListeners();
  }

  // Healthcare Facilities & Filtering
  final List<FacilityItem> _facilities = const [
    FacilityItem(
      name: 'Klinik Harmoni',
      type: 'Klinik',
      address: 'Jl. Contoh Sehat No. 12',
      distance: '0,8 km',
    ),
    FacilityItem(
      name: 'RS Taman Sehat',
      type: 'Rumah sakit',
      address: 'Jl. Contoh Utama No. 8',
      distance: '1,6 km',
    ),
    FacilityItem(
      name: 'Puskesmas Cempaka',
      type: 'Puskesmas',
      address: 'Jl. Contoh Cempaka No. 4',
      distance: '2,3 km',
    ),
  ];

  List<FacilityItem> get allFacilities => _facilities;

  String _facilityCategoryFilter = 'Semua';
  String get facilityCategoryFilter => _facilityCategoryFilter;

  String _facilitySearchQuery = '';
  String get facilitySearchQuery => _facilitySearchQuery;

  int _selectedFacilityIndex = 0;
  int get selectedFacilityIndex => _selectedFacilityIndex;

  FacilityItem get selectedFacility => _facilities[_selectedFacilityIndex];

  void setFacilityFilter(String filter) {
    _facilityCategoryFilter = filter;
    notifyListeners();
  }

  void setFacilityQuery(String query) {
    _facilitySearchQuery = query;
    notifyListeners();
  }

  void setSelectedFacilityIndex(int index) {
    if (index >= 0 && index < _facilities.length) {
      _selectedFacilityIndex = index;
      notifyListeners();
    }
  }

  List<FacilityItem> get filteredFacilities {
    return _facilities.where((f) {
      final matchesCategory = _facilityCategoryFilter == 'Semua' ||
          f.type == _facilityCategoryFilter;
      final matchesQuery = _facilitySearchQuery.isEmpty ||
          f.name.toLowerCase().contains(_facilitySearchQuery.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  // Accessibility Font Scaling
  double _fontSize = 16.0;
  double get fontSize => _fontSize;

  void cycleFont() {
    if (_fontSize == 16.0) {
      _fontSize = 19.0;
    } else if (_fontSize == 19.0) {
      _fontSize = 22.0;
    } else {
      _fontSize = 16.0;
    }
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  // Reset Demo
  void resetDemo() {
    _userName = 'Adriel';
    _friends = ['Nadia', 'Raka', 'Dinda'];
    _sessions.clear();
    cancelTimers();
    _messages.clear();
    _signText = '';
    _transcriptText = 'Ucapan teman dengar akan tampil di sini.';
    _facilityCategoryFilter = 'Semua';
    _facilitySearchQuery = '';
    _selectedFacilityIndex = 0;
    _fontSize = 16.0;
    _isMicActive = false;
    _isCamActive = false;
    _isTtsActive = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    super.dispose();
  }
}

class SharingSession {
  final String name;
  final DateTime expiry;

  SharingSession({required this.name, required this.expiry});

  String remainingText() {
    final diff = expiry.difference(DateTime.now());
    if (diff.isNegative) return 'Sesi berakhir';
    final minutes = diff.inMinutes + (diff.inSeconds % 60 > 0 ? 1 : 0);
    return '$minutes menit tersisa';
  }
}

class ChatMessage {
  final String text;
  final String type; // 'Ucapan' | 'Isyarat' | 'Ketik'
  final bool isDemo;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.type,
    this.isDemo = false,
  }) : timestamp = DateTime.now();
}

class FacilityItem {
  final String name;
  final String type;
  final String address;
  final String distance;

  const FacilityItem({
    required this.name,
    required this.type,
    required this.address,
    required this.distance,
  });
}
