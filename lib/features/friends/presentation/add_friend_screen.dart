import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Screen 14: Add Friend Screen.
/// Facilitates mutual, consent-driven friend connections using unique invitation tokens.
class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String _myInviteCode = 'TAUT-ALFREDO-8831';
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _connectFriend() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode undangan teman terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Undangan terkirim ke pemilik kode "$code". Menunggu persetujuan.'),
          ),
        );
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tambah Teman Terpercaya'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StatusBadge.active(label: 'Token SHA-256 Aman'),
            ),
            const SizedBox(height: 16),
            Text(
              'Hubungkan Teman & Pendamping',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hanya teman yang Anda setujui yang dapat saling melihat posisi lokasi langsung.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),

            // MY INVITATION CODE CARD
            AppCard(
              margin: EdgeInsets.zero,
              backgroundColor: AppColors.lightGreen,
              borderColor: AppColors.sageGreen,
              child: Column(
                children: [
                  const Text(
                    'Kode Undangan Anda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.sageGreen),
                    ),
                    child: SelectableText(
                      _myInviteCode,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        color: AppColors.darkGreen,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Salin Kode'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(120, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kode undangan disalin ke clipboard!'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.share_rounded, size: 16),
                        label: const Text('Bagikan'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(120, 40),
                          backgroundColor: AppColors.darkGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Membuka lembar berbagi kode undangan...'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ENTER FRIEND'S CODE CARD
            AppCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Masukkan Kode Undangan Teman',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Dapatkan kode unik dari teman atau dokter pendamping Anda.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: TAUT-ADRIEL-9921',
                      prefixIcon: Icon(Icons.vpn_key_rounded, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppButton(
                    label: 'Hubungkan Teman Sekarang',
                    icon: Icons.check_circle_rounded,
                    backgroundColor: AppColors.primary,
                    isLoading: _isLoading,
                    onPressed: _connectFriend,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
