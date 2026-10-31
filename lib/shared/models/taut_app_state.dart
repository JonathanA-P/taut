import 'dart:async';
import 'package:flutter/material.dart';

class TautAppState extends ChangeNotifier {
  static final TautAppState _instance = TautAppState._internal();
  factory TautAppState() => _instance;

  TautAppState._internal();

  String _currentPage = 'home';
  String get currentPage => _currentPage;

  final List<String> _pageHistory = ['home'];
  List<String> get pageHistory => List.unmodifiable(_pageHistory);

  bool get canPopPage => _pageHistory.length > 1;

  void navigateTo(String page) {
    if (_currentPage == page) return;
    if (_currentPage == 'comm' && page != 'comm') {
      stopHardwareTracks();
    }
    _pageHistory.add(page);
    _currentPage = page;
    notifyListeners();
  }

  bool popPage() {
    if (_pageHistory.length > 1) {
      if (_currentPage == 'comm') {
        stopHardwareTracks();
      }
      _pageHistory.removeLast();
      _currentPage = _pageHistory.last;
      notifyListeners();
      return true;
    }
    return false;
  }

  void switchToTab(int navIndex) {
    switch (navIndex) {
      case 0:
        navigateTo('home');
        break;
      case 1:
        navigateTo('hub');
        break;
      case 2:
        navigateTo('location');
        break;
      case 3:
        navigateTo('profile');
        break;
    }
  }

  int get currentNavIndex {
    switch (_currentPage) {
      case 'home':
        return 0;
      case 'comm':
      case 'hub':
        return 1;
      case 'location':
      case 'finder':
      case 'detail':
      case 'friends':
      case 'add':
      case 'sharing':
      case 'live':
        return 2;
      case 'profile':
      case 'edit':
      case 'settings':
      case 'privacy':
        return 3;
      default:
        return 0;
    }
  }

  bool get isNavbarVisible {
    return !const ['onboard', 'login', 'register', 'splash', 'welcome'].contains(_currentPage);
  }

  String _userName = 'Adriel';
  String get userName => _userName;

  String _userHandle = 'adriel';
  String get userHandle => _userHandle;

  void setUserName(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      _userName = trimmed;
      notifyListeners();
    }
  }

  void setUserHandle(String handle) {
    final clean = handle.replaceAll('@', '').trim().toLowerCase();
    if (clean.isNotEmpty) {
      _userHandle = clean;
      notifyListeners();
    }
  }

  final List<FriendRequest> _friendRequests = [
    const FriendRequest(name: 'Budi Santoso', username: 'budi.s', avatarInitial: 'B'),
    const FriendRequest(name: 'Siti Rahma', username: 'siti.r', avatarInitial: 'S'),
  ];
  List<FriendRequest> get friendRequests => List.unmodifiable(_friendRequests);
  int get pendingRequestsCount => _friendRequests.length;

  void acceptFriendRequest(FriendRequest req) {
    _friendRequests.remove(req);
    if (!_friends.contains(req.name)) {
      _friends.add(req.name);
    }
    notifyListeners();
  }

  void rejectFriendRequest(FriendRequest req) {
    _friendRequests.remove(req);
    notifyListeners();
  }

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

  // Room Communication State (Ruangan Obrolan Jarak Jauh)
  bool _isRoomActive = false;
  bool get isRoomActive => _isRoomActive;

  String? _roomCode;
  String? get roomCode => _roomCode;

  String _roomName = 'Ruang Kelas Adriel';
  String get roomName => _roomName;

  bool _isAutoAccept = false;
  bool get isAutoAccept => _isAutoAccept;

  final List<String> _roomParticipants = [];
  List<String> get roomParticipants => List.unmodifiable(_roomParticipants);

  final List<String> _roomJoinRequests = [];
  List<String> get roomJoinRequests => List.unmodifiable(_roomJoinRequests);

  void setRoomName(String name) {
    _roomName = name.trim().isEmpty ? 'Ruang Kelas $_userName' : name.trim();
    notifyListeners();
  }

  void setAutoAccept(bool auto) {
    _isAutoAccept = auto;
    notifyListeners();
  }

  void createRoom({String? name, bool? autoAccept}) {
    _roomCode = 'TAUT-8921';
    if (name != null && name.trim().isNotEmpty) {
      _roomName = name.trim();
    } else {
      _roomName = 'Ruang Kelas $_userName';
    }
    if (autoAccept != null) {
      _isAutoAccept = autoAccept;
    }
    _roomParticipants.clear();
    _roomParticipants.add('$_userName (Host)');
    _roomJoinRequests.clear();
    notifyListeners();
  }

  void startRoomSession() {
    _isRoomActive = true;
    if (_isAutoAccept) {
      // Auto accept participants
      _roomParticipants.addAll(['Nadia (Teman)', 'Raka (Teman)']);
      _roomJoinRequests.clear();
    } else {
      // Pending approval for host
      _roomJoinRequests.clear();
      _roomJoinRequests.addAll(['Nadia (Teman)', 'Raka (Teman)']);
    }
    notifyListeners();
  }

  bool joinRoomByCode(String code, {String? participantName}) {
    final cleanCode = code.toUpperCase().trim();
    final name = participantName ?? 'Tamu_${cleanCode.replaceAll('-', '')}';
    
    if (_isAutoAccept || !_isRoomActive) {
      _roomCode = cleanCode;
      _isRoomActive = true;
      if (!_roomParticipants.contains(_userName)) {
        _roomParticipants.add(_userName);
      }
      if (!_roomParticipants.contains(name) && name != _userName) {
        _roomParticipants.add(name);
      }
      notifyListeners();
      return true; // langsung bergabung
    } else {
      // Perlu persetujuan host
      if (!_roomJoinRequests.contains(name) && !_roomParticipants.contains(name)) {
        _roomJoinRequests.add(name);
      }
      notifyListeners();
      return false; // menunggu persetujuan
    }
  }

  void acceptRoomParticipant(String name) {
    _roomJoinRequests.remove(name);
    if (!_roomParticipants.contains(name)) {
      _roomParticipants.add(name);
    }
    notifyListeners();
  }

  void rejectRoomParticipant(String name) {
    _roomJoinRequests.remove(name);
    notifyListeners();
  }

  void endRoomSession() {
    _isRoomActive = false;
    _roomCode = null;
    _roomParticipants.clear();
    _roomJoinRequests.clear();
    notifyListeners();
  }

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

  void setFacilityCategoryFilter(String filter) => setFacilityFilter(filter);

  void setFacilityQuery(String query) {
    _facilitySearchQuery = query;
    notifyListeners();
  }

  void setFacilitySearchQuery(String query) => setFacilityQuery(query);

  void stopHardwareTracks() {
    _isMicActive = false;
    _isCamActive = false;
    _isTtsActive = false;
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

  void resetDemo() {
    _userName = 'Adriel';
    _friends = ['Nadia', 'Raka', 'Dinda'];
    _sessions.clear();
    cancelTimers();
    _currentPage = 'home';
    _pageHistory.clear();
    _pageHistory.add('home');
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

class FriendRequest {
  final String name;
  final String username;
  final String avatarInitial;

  const FriendRequest({
    required this.name,
    required this.username,
    required this.avatarInitial,
  });
}

