import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/utils/place_search_matcher.dart';

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

  String? _userAvatarUrl;
  String? get userAvatarUrl => _userAvatarUrl;

  void setUserAvatarUrl(String? url) {
    _userAvatarUrl = url?.trim().isEmpty ?? true ? null : url?.trim();
    notifyListeners();
  }

  final Map<String, String> _friendAvatars = {
    'Nadia': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    'Raka': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    'Dinda': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
  };

  String? getFriendAvatar(String name) => _friendAvatars[name];

  final List<FriendRequest> _friendRequests = [
    const FriendRequest(
      name: 'Budi Santoso',
      username: 'budi.s',
      avatarInitial: 'B',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    ),
    const FriendRequest(
      name: 'Siti Rahma',
      username: 'siti.r',
      avatarInitial: 'S',
      avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
    ),
  ];
  List<FriendRequest> get friendRequests => List.unmodifiable(_friendRequests);
  int get pendingRequestsCount => _friendRequests.length;

  void acceptFriendRequest(FriendRequest req) {
    _friendRequests.remove(req);
    if (!_friends.contains(req.name)) {
      _friends.add(req.name);
    }
    if (req.avatarUrl != null) {
      _friendAvatars[req.name] = req.avatarUrl!;
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

  bool _isHost = false;
  bool get isHost => _isHost;

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

  bool createRoom({String? name, bool? autoAccept}) {
    // Constraint: 1 user can only create or join 1 active room at a time
    if (_isRoomActive) {
      return false;
    }
    _isHost = true;
    _isRoomActive = false;
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
    return true;
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
    // Constraint: 1 user can only participate in 1 active room at a time
    if (_isRoomActive) {
      return false;
    }
    final cleanCode = code.toUpperCase().trim();
    final name = participantName ?? 'Tamu_${cleanCode.replaceAll('-', '')}';
    
    _isHost = false;
    _roomCode = cleanCode;
    _isRoomActive = true;
    if (!_roomParticipants.contains(_userName)) {
      _roomParticipants.add('$_userName (Peserta)');
    }
    if (!_roomParticipants.contains(name) && name != _userName) {
      _roomParticipants.add(name);
    }
    notifyListeners();
    return true; // langsung bergabung
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
    _isHost = false;
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

  final List<IncomingSharingSession> _incomingSessions = [
    IncomingSharingSession(
      id: 'inc-1',
      friendName: 'Nadia',
      subtitle: 'Dekat Alun-Alun Malang • 0,6 km',
      latitude: -7.9826,
      longitude: 112.6308,
      expiry: DateTime.now().add(const Duration(minutes: 42)),
    ),
    IncomingSharingSession(
      id: 'inc-2',
      friendName: 'Budi Setiawan',
      subtitle: 'Dekat Kampus UB • 2,1 km',
      latitude: -7.9526,
      longitude: 112.6144,
      expiry: DateTime.now().add(const Duration(minutes: 58)),
    ),
  ];

  List<IncomingSharingSession> get incomingSessions =>
      List.unmodifiable(_incomingSessions);

  void stopIncomingSession(int index) {
    if (index >= 0 && index < _incomingSessions.length) {
      _incomingSessions.removeAt(index);
      notifyListeners();
    }
  }

  void stopIncomingSessionById(String id) {
    _incomingSessions.removeWhere((s) => s.id == id);
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

  final List<FacilityItem> _facilities = [];

  bool _isRealHealthcareLoaded = false;
  bool get isRealHealthcareLoaded => _isRealHealthcareLoaded;

  bool _isSearchingHealthcare = false;
  bool get isSearchingHealthcare => _isSearchingHealthcare;

  double? _userGpsLatitude;
  double? get userGpsLatitude => _userGpsLatitude;

  double? _userGpsLongitude;
  double? get userGpsLongitude => _userGpsLongitude;

  void setRealHealthcareFacilities(
    List<FacilityItem> realFacilities, {
    required double lat,
    required double lon,
  }) {
    _facilities.clear();
    _facilities.addAll(realFacilities);
    _isRealHealthcareLoaded = true;
    _userGpsLatitude = lat;
    _userGpsLongitude = lon;
    _selectedFacilityIndex = 0;
    notifyListeners();
  }

  void setSearchingHealthcare(bool searching) {
    _isSearchingHealthcare = searching;
    notifyListeners();
  }

  List<FacilityItem> get allFacilities => _facilities;

  String _facilityCategoryFilter = 'Semua';
  String get facilityCategoryFilter => _facilityCategoryFilter;

  String _facilitySearchQuery = '';
  String get facilitySearchQuery => _facilitySearchQuery;

  int _selectedFacilityIndex = 0;
  int get selectedFacilityIndex => _selectedFacilityIndex;

  FacilityItem get selectedFacility {
    if (_facilities.isNotEmpty &&
        _selectedFacilityIndex >= 0 &&
        _selectedFacilityIndex < _facilities.length) {
      return _facilities[_selectedFacilityIndex];
    }
    return const FacilityItem(
      name: 'Fasilitas Kesehatan',
      type: 'Klinik',
      address: 'Lokasi belum diketahui',
      distance: '-',
    );
  }

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
    if (!_isRealHealthcareLoaded) {
      return const [];
    }

    final inCategory = _facilities.where((f) {
      if (_facilityCategoryFilter == 'Semua') return true;
      return f.type.toLowerCase() == _facilityCategoryFilter.toLowerCase();
    }).toList();

    final query = _facilitySearchQuery.trim();
    if (query.isEmpty) {
      return inCategory;
    }

    final scored = <({FacilityItem item, double score})>[];
    for (final item in inCategory) {
      final score = PlaceSearchMatcher.matchScore(
        query: query,
        name: item.name,
        address: item.address,
        category: item.type,
      );
      if (score >= 35.0) {
        scored.add((item: item, score: score));
      }
    }

    scored.sort((a, b) {
      final scoreDiff = b.score.compareTo(a.score);
      if (scoreDiff != 0) return scoreDiff;
      return a.item.distance.compareTo(b.item.distance);
    });

    return scored.map((s) => s.item).toList();
  }

  void resetDemo() {
    _userName = 'Adriel';
    _userAvatarUrl = null;
    _friends = ['Nadia', 'Raka', 'Dinda'];
    _sessions.clear();
    cancelTimers();
    _currentPage = 'home';
    _pageHistory.clear();
    _pageHistory.add('home');
    _messages.clear();
    _signText = '';
    _transcriptText = 'Ucapan teman dengar akan tampil di sini.';
    _facilities.clear();
    _isRealHealthcareLoaded = false;
    _isSearchingHealthcare = false;
    _userGpsLatitude = null;
    _userGpsLongitude = null;
    _facilityCategoryFilter = 'Semua';
    _facilitySearchQuery = '';
    _selectedFacilityIndex = 0;
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

class IncomingSharingSession {
  final String id;
  final String friendName;
  final String subtitle;
  final double latitude;
  final double longitude;
  final DateTime expiry;

  IncomingSharingSession({
    required this.id,
    required this.friendName,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
    required this.expiry,
  });

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
  final double latitude;
  final double longitude;
  final bool isReal;
  final bool isWheelchairAccessible;

  const FacilityItem({
    required this.name,
    required this.type,
    required this.address,
    required this.distance,
    this.latitude = -7.9723,
    this.longitude = 112.6318,
    this.isReal = false,
    this.isWheelchairAccessible = true,
  });
}

class FriendRequest {
  final String name;
  final String username;
  final String avatarInitial;
  final String? avatarUrl;

  const FriendRequest({
    required this.name,
    required this.username,
    required this.avatarInitial,
    this.avatarUrl,
  });
}

