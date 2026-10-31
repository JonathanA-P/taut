import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';
import '../../../shared/widgets/taut_open_street_map.dart';
import 'widgets/friend_location_detail_sheet.dart';

class LiveLocationScreen extends StatelessWidget {
  const LiveLocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final mapMarkers = <TautMapMarker>[
          // Current User position (Malang Center)
          const TautMapMarker(
            point: LatLng(-7.9723, 112.6318),
            label: 'Posisi Saya',
            subtitle: 'Alun-Alun Tugu Malang (Akurasi GPS ±5m)',
            isUser: true,
          ),
          // Incoming Friend positions
          ...state.acceptedIncomingSessions.map((incoming) {
            return TautMapMarker(
              point: LatLng(incoming.latitude, incoming.longitude),
              label: incoming.friendName,
              subtitle: incoming.subtitle,
              avatarText: incoming.friendName.isNotEmpty ? incoming.friendName[0] : '?',
              color: const Color(0xFF2E7D32),
            );
          }),
        ];

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
              'Lokasi bersama',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // OpenStreetMap interactive viewer
                  TautOpenStreetMap(
                    initialCenter: const LatLng(-7.9723, 112.6318),
                    initialZoom: 14.2,
                    height: 250,
                    markers: mapMarkers,
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Peta ilustrasi OpenStreetMap • Posisi GPS Real-time',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sesi Dibagikan Saya
                  const Text(
                    'Sesi berbagi lokasi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Lokasimu saat ini dapat dipantau oleh kontak terpercaya yang kamu pilih.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (state.sessions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
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
                            fontSize: 13,
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

                  // Lokasi Teman yang Dibagikan ke Kita
                  const Text(
                    'Lokasi teman yang diterima',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Teman yang sedang membagikan lokasinya secara real-time kepadamu.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (state.incomingSessions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFEDF0E9)),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada teman yang membagikan lokasi.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
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
                      itemCount: state.incomingSessions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final incoming = state.incomingSessions[index];
                        return _buildIncomingFriendCard(context, state, incoming, index);
                      },
                    ),
                ],
              ),
            ),
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
    return Container(
      padding: const EdgeInsets.all(18),
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
        children: [
          Row(
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
                    ),
                    const SizedBox(height: 2),
                    Text(
                      session.remainingText(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6ECDA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF825D24),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
                'Hentikan sesi',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingFriendCard(
    BuildContext context,
    TautAppState state,
    IncomingSharingSession incoming,
    int index,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        if (incoming.isPending) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Persetujuan Berbagi Lokasi'),
              content: Text('\${incoming.friendName} ingin membagikan lokasinya kepadamu (\${incoming.remainingText()}). Apakah kamu setuju untuk menerima lokasi ini?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    state.rejectIncomingSession(incoming.id);
                  },
                  child: const Text('Tolak', style: TextStyle(color: Color(0xFF8B4435))),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    state.acceptIncomingSession(incoming.id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Setuju & Terima'),
                ),
              ],
            ),
          );
        } else {
          FriendLocationDetailSheet.show(
            context,
            incoming: incoming,
            onStopSharing: () => state.stopIncomingSessionById(incoming.id),
          );
        }
      },
      child: Container(
      padding: const EdgeInsets.all(18),
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
      child: Row(
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
                ),
                const SizedBox(height: 2),
                Text(
                  incoming.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
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
      ),
      ),
    );
  }
}