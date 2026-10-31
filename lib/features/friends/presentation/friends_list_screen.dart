import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';

/// Friends List Screen strictly implementing the TAUT HTML prototype:
/// - Screen title: "Teman terhubung"
/// - Subtitle: "Tetap dekat dengan orang yang kamu percaya."
/// - List of friends with avatar, name, and status ("Sesi berbagi demo aktif" or "Tidak ada sesi berbagi")
/// - "+ Tambah teman" CTA button
/// - Hint: "Daftar teman contoh. Menambahkan nama tidak mengirim undangan sungguhan."
class FriendsListScreen extends StatelessWidget {
  const FriendsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
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
              'Teman terhubung',
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
                  const Text(
                    'Tetap dekat dengan orang yang kamu percaya.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Friends Stack
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.friends.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final name = state.friends[index];
                      final isSharing = state.sessions.any((s) => s.name == name);
                      return _buildFriendCard(context, state, name, isSharing, index);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Add Friend CTA
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () => state.navigateTo('add'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text(
                        'Tambah teman',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Daftar teman contoh. Menambahkan nama tidak mengirim undangan sungguhan.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
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

  Widget _buildFriendCard(
    BuildContext context,
    TautAppState state,
    String name,
    bool isSharing,
    int index,
  ) {
    const avatarColors = [
      Color(0xFFE9DDCD),
      Color(0xFFDCE7DC),
      Color(0xFFE6E2EF),
    ];
    const textColors = [
      Color(0xFF655747),
      Color(0xFF527B5D),
      Color(0xFF6A6086),
    ];

    final colorBg = avatarColors[index % avatarColors.length];
    final colorTxt = textColors[index % textColors.length];

    return InkWell(
      onTap: () => state.navigateTo('sharing'),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE4E9E1)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05263D2F),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorBg,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colorTxt,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isSharing
                        ? 'Sesi berbagi demo aktif'
                        : 'Tidak ada sesi berbagi',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSharing
                          ? const Color(0xFF825D24)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9EAFA3),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
