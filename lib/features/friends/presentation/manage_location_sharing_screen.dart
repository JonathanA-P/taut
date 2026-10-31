import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Screen 16: Manage Location Sharing Permissions & Sessions.
/// Allows user to toggle live location broadcasting per friend or globally.
class ManageLocationSharingScreen extends StatefulWidget {
  const ManageLocationSharingScreen({super.key});

  @override
  State<ManageLocationSharingScreen> createState() => _ManageLocationSharingScreenState();
}

class _ManageLocationSharingScreenState extends State<ManageLocationSharingScreen> {
  bool _isGlobalSharingEnabled = true;
  bool _shareWithAdriel = true;
  bool _shareWithRoganda = false;
  bool _shareWithDoctor = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Berbagi Lokasi'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        children: [
          Row(
            children: [
              StatusBadge.active(
                label: _isGlobalSharingEnabled ? 'Siaran GPS Aktif' : 'Siaran GPS Nonaktif',
              ),
              const Spacer(),
              const Text(
                'Supabase RLS Enforced',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // MASTER SWITCH CARD
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: _isGlobalSharingEnabled ? AppColors.lightGreen : AppColors.white,
            borderColor: _isGlobalSharingEnabled ? AppColors.sageGreen : AppColors.outline,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Siaran Lokasi Langsung',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isGlobalSharingEnabled
                            ? 'Lokasi Anda disiarkan ke teman tercentang'
                            : 'Semua siaran lokasi ditangguhkan',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isGlobalSharingEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _isGlobalSharingEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Siaran lokasi diaktifkan.'
                              : 'Semua pembagian lokasi dihentikan seketika.',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // PER-FRIEND ACCESS CONTROL
          const Text(
            'Izin Per Teman Terhubung',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Pilih siapa saja teman yang memiliki akses untuk melihat posisi koordinat Anda.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),

          AppCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                _buildFriendSwitch(
                  name: 'Adriel Christo Lumbantoruan',
                  role: 'Frontend & Healthcare Lead',
                  value: _shareWithAdriel && _isGlobalSharingEnabled,
                  enabled: _isGlobalSharingEnabled,
                  onChanged: (val) => setState(() => _shareWithAdriel = val),
                ),
                const Divider(color: AppColors.lightGreen, height: 16),
                _buildFriendSwitch(
                  name: 'Roganda Tua Tampubolon',
                  role: 'Communication AI Lead',
                  value: _shareWithRoganda && _isGlobalSharingEnabled,
                  enabled: _isGlobalSharingEnabled,
                  onChanged: (val) => setState(() => _shareWithRoganda = val),
                ),
                const Divider(color: AppColors.lightGreen, height: 16),
                _buildFriendSwitch(
                  name: 'dr. Stella Kane',
                  role: 'Dokter Pendamping Medis',
                  value: _shareWithDoctor && _isGlobalSharingEnabled,
                  enabled: _isGlobalSharingEnabled,
                  onChanged: (val) => setState(() => _shareWithDoctor = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // PRIVACY EXPLANATION CARD
          AppCard(
            margin: EdgeInsets.zero,
            backgroundColor: AppColors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Keamanan Row Level Security (RLS)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hanya teman dengan izin aktif yang dapat menerima stream koordinat GPS Anda melalui database PostgreSQL Supabase.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Simpan Perubahan Izin',
            backgroundColor: AppColors.darkGreen,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pengaturan sesi berbagi lokasi berhasil diperbarui.'),
                ),
              );
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFriendSwitch({
    required String name,
    required String role,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              Text(
                role,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.primary,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
