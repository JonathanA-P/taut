import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import 'widgets/friend_location_detail_sheet.dart';

class ManageLocationSharingScreen extends StatefulWidget {
  const ManageLocationSharingScreen({super.key});

  @override
  State<ManageLocationSharingScreen> createState() =>
      _ManageLocationSharingScreenState();
}

class _ManageLocationSharingScreenState
    extends State<ManageLocationSharingScreen> {
  String? _selectedRecipient;
  int _selectedDuration = 15;
  bool _hasAgreed = false;

  void _showMinimalNotification(
    BuildContext context, {
    required String message,
    IconData icon = Icons.check_circle_rounded,
    Color iconColor = const Color(0xFF81C784),
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    final state = TautAppState();
    final bottomMargin = state.isNavbarVisible ? 94.0 : 24.0;

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 3,
        duration: duration,
        margin: EdgeInsets.only(bottom: bottomMargin, left: 24, right: 24),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: const Color(0xFF1E2D22),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final friends = TautAppState().friends;
    if (friends.isNotEmpty) {
      _selectedRecipient = friends.first;
    }
  }

  void _handleStartSharing(TautAppState state) {
    if (!_hasAgreed) {
      _showMinimalNotification(
        context,
        message: 'Centang persetujuan terlebih dahulu.',
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFFFB74D),
      );
      return;
    }

    if (_selectedRecipient == null || _selectedRecipient!.isEmpty) {
      _showMinimalNotification(
        context,
        message: 'Pilih penerima terlebih dahulu.',
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFFFB74D),
      );
      return;
    }

    state.startSharing(
      recipient: _selectedRecipient!,
      durationMinutes: _selectedDuration,
    );

    _showMinimalNotification(
      context,
      message: 'Sesi demo dimulai. Tidak ada lokasi nyata yang dikirim.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final friends = state.friends;
        if (_selectedRecipient == null && friends.isNotEmpty) {
          _selectedRecipient = friends.first;
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: (Navigator.canPop(context) || state.canPopPage)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.darkGreen,
                    onPressed: () {
                      if (state.canPopPage) {
                        state.popPage();
                      } else if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    },
                  )
                : null,
            title: const Text(
              'Berbagi lokasi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mulai sesi baru',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Bagikan kepada',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD9E2D5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: friends.contains(_selectedRecipient)
                            ? _selectedRecipient
                            : (friends.isNotEmpty ? friends.first : null),
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        onChanged: (val) {
                          setState(() {
                            _selectedRecipient = val;
                          });
                        },
                        items: friends.map((f) {
                          return DropdownMenuItem(
                            value: f,
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Durasi',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFD9E2D5)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedDuration,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedDuration = val;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 15,
                            child: Text(
                              '15 menit',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text(
                              '30 menit',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text(
                              '1 jam',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.darkGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _hasAgreed,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _hasAgreed = val ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Saya setuju memulai simulasi berbagi lokasi dengan penerima yang dipilih.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkGreen,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleStartSharing(state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Mulai berbagi demo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Sesi aktif',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '${state.sessions.length} penerima',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4C6551),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  if (state.sessions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEDF0E9)),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada sesi aktif.\nLokasimu tidak dibagikan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.sessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final session = state.sessions[index];
                        return _buildSessionCard(context, state, session, index);
                      },
                    ),

                  const SizedBox(height: 28),

                  // Permintaan Berbagi Lokasi Masuk (Perlu Persetujuan)
                  if (state.pendingIncomingSessions.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Permintaan berbagi lokasi masuk',
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGreen,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(color: const Color(0xFFFFE0B2)),
                          ),
                          child: Text(
                            '${state.pendingIncomingSessions.length} baru',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFE65100),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Teman ingin membagikan lokasinya kepadamu. Kamu diberikan pilihan untuk setuju atau menolak menerima lokasi tersebut.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.pendingIncomingSessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final incoming = state.pendingIncomingSessions[index];
                        return _buildPendingIncomingCard(context, state, incoming);
                      },
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Daftar Orang yang Diterima Berbagi Lokasinya
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Daftar orang yang diterima berbagi lokasinya',
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                            height: 1.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2EBE0),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          '${state.acceptedIncomingSessions.length} teman',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Daftar teman yang berbagi lokasi kepadamu dan telah kamu setujui.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (state.acceptedIncomingSessions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEDF0E9)),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada orang yang kamu terima berbagi lokasinya.\nSetujui permintaan masuk di atas untuk melihat lokasi teman.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.acceptedIncomingSessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final incoming = state.acceptedIncomingSessions[index];
                        return _buildIncomingSessionCard(context, state, incoming, index);
                      },
                    ),

                  const SizedBox(height: 16),
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        state.simulateNewIncomingSharing();
                        _showMinimalNotification(
                          context,
                          message: 'Simulasi permintaan berbagi lokasi baru dari Raka ditambahkan.',
                          icon: Icons.person_add_rounded,
                        );
                      },
                      icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                      label: const Text(
                        'Simulasi permintaan teman baru',
                        style: TextStyle(
                          fontSize: 12.5,
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

    Widget _buildPendingIncomingCard(
    BuildContext context,
    TautAppState state,
    IncomingSharingSession incoming,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFE0B2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0AE65100),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFE0B2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      incoming.friendName.isNotEmpty ? incoming.friendName[0] : '?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFE65100),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incoming.friendName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          incoming.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Menunggu Persetujuan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFBF9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEEF2EB)),
                ),
                child: Text(
                  '${incoming.friendName} ingin membagikan lokasinya kepadamu (${incoming.remainingText()}). Apakah kamu setuju untuk menerima lokasi ini?',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4C5D48),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (isNarrow)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          state.acceptIncomingSession(incoming.id);
                          _showMinimalNotification(
                            context,
                            message: 'Permintaan berbagi lokasi dari ${incoming.friendName} diterima.',
                          );
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text(
                          'Setuju & Terima',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          state.rejectIncomingSession(incoming.id);
                          _showMinimalNotification(
                            context,
                            message: 'Permintaan berbagi lokasi dari ${incoming.friendName} ditolak.',
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFFFFB74D),
                          );
                        },
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text(
                          'Tolak',
                          style: TextStyle(fontSize: 12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF944838),
                          side: const BorderSide(color: Color(0xFFECCDC7)),
                          backgroundColor: const Color(0xFFFDF6F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            state.acceptIncomingSession(incoming.id);
                          _showMinimalNotification(
                            context,
                            message: 'Permintaan berbagi lokasi dari ${incoming.friendName} diterima.',
                          );
                          },
                          icon: const Icon(Icons.check_circle_rounded, size: 16),
                          label: const Text(
                            'Setuju & Terima',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            state.rejectIncomingSession(incoming.id);
                          _showMinimalNotification(
                            context,
                            message: 'Permintaan berbagi lokasi dari ${incoming.friendName} ditolak.',
                            icon: Icons.info_outline_rounded,
                            iconColor: const Color(0xFFFFB74D),
                          );
                          },
                          icon: const Icon(Icons.close_rounded, size: 16),
                          label: const Text(
                            'Tolak',
                            style: TextStyle(fontSize: 12.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF944838),
                            side: const BorderSide(color: Color(0xFFECCDC7)),
                            backgroundColor: const Color(0xFFFDF6F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomingSessionCard(
    BuildContext context,
    TautAppState state,
    IncomingSharingSession incoming,
    int index,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDF0E9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05263D2F),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFD6E7D2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      incoming.friendName.isNotEmpty ? incoming.friendName[0] : '?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          incoming.friendName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          incoming.subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC8E6C9)),
                      ),
                      child: Text(
                        incoming.remainingText(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (isNarrow) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC8E6C9)),
                  ),
                  child: Text(
                    incoming.remainingText(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (isNarrow)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          FriendLocationDetailSheet.show(
                            context,
                            incoming: incoming,
                            onStopSharing: () {
                              state.stopIncomingSessionById(incoming.id);
                                _showMinimalNotification(
                                  context,
                                  message: 'Lokasi ${incoming.friendName} disembunyikan.',
                                  icon: Icons.visibility_off_outlined,
                                  iconColor: const Color(0xFFB0BEC5),
                                );
                            },
                          );
                        },
                        icon: const Icon(Icons.location_on_rounded, size: 16),
                        label: const Text(
                          'Lihat Lokasi Teman',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () {
                          state.stopIncomingSession(index);
                          _showMinimalNotification(
                            context,
                            message: 'Lokasi ${incoming.friendName} disembunyikan.',
                            icon: Icons.visibility_off_outlined,
                            iconColor: const Color(0xFFB0BEC5),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: Color(0xFFDCE2D8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Sembunyikan',
                          style: TextStyle(fontSize: 12.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton.icon(
                          onPressed: () {
                          FriendLocationDetailSheet.show(
                            context,
                            incoming: incoming,
                            onStopSharing: () {
                              state.stopIncomingSessionById(incoming.id);
                                _showMinimalNotification(
                                  context,
                                  message: 'Lokasi ${incoming.friendName} disembunyikan.',
                                  icon: Icons.visibility_off_outlined,
                                  iconColor: const Color(0xFFB0BEC5),
                                );
                            },
                          );
                        },
                          icon: const Icon(Icons.location_on_rounded, size: 16),
                          label: const Text(
                            'Lihat Lokasi Teman',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton(
                          onPressed: () {
                            state.stopIncomingSession(index);
                          _showMinimalNotification(
                            context,
                            message: 'Lokasi ${incoming.friendName} disembunyikan.',
                            icon: Icons.visibility_off_outlined,
                            iconColor: const Color(0xFFB0BEC5),
                          );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: Color(0xFFDCE2D8)),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Sembunyikan',
                            style: TextStyle(fontSize: 12.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    TautAppState state,
    SharingSession session,
    int index,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 340;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFEDF0E9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x05263D2F),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE9DDCD),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      session.name.isNotEmpty ? session.name[0] : '?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF655747),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          session.remainingText(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isNarrow) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF6ECDA),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Demo',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF825D24),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (isNarrow) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6ECDA),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Demo',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF825D24),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              if (isNarrow)
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () => state.navigateTo('live'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreen,
                          foregroundColor: AppColors.darkGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Lihat lokasi',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton(
                        onPressed: () {
                          state.stopSharing(index);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sesi berbagi dihentikan.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4E3DE),
                          foregroundColor: const Color(0xFF8B4435),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Hentikan',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                        onPressed: () => state.navigateTo('live'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lightGreen,
                            foregroundColor: AppColors.darkGreen,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Lihat lokasi',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ElevatedButton(
                          onPressed: () {
                            state.stopSharing(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sesi berbagi dihentikan.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF4E3DE),
                            foregroundColor: const Color(0xFF8B4435),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Hentikan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
