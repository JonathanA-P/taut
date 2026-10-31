import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

/// Screen 18: Edit Profile Screen.
/// Enables user to update display name, accessibility preferences, and emergency contact details.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Alfredo Jonathan Purba');
  final TextEditingController _phoneController =
      TextEditingController(text: '081234567890');
  final TextEditingController _emergencyContactController =
      TextEditingController(text: 'Ibu Alfredo (081298765432)');
  String _selectedRole = 'Teman Dengar';
  bool _isLoading = false;

  final List<String> _roles = const [
    'Teman Tuli',
    'Teman Dengar',
    'Pendamping / Relawan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui.')),
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
        title: const Text('Ubah Profil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.sageGreen,
                      child: Text(
                        'AJ',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: AppColors.darkGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Tampilan Lengkap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nomor Kontak Pengguna',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.phone_outlined, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kontak Darurat Pendamping',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emergencyContactController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.contact_phone_outlined, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Peran & Preferensi Pengguna',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _roles.map((role) {
                      final isSelected = role == _selectedRole;
                      return ChoiceChip(
                        label: Text(role),
                        selected: isSelected,
                        selectedColor: AppColors.sageGreen,
                        backgroundColor: AppColors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? AppColors.darkGreen : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.outline,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedRole = role);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Simpan Perubahan',
              backgroundColor: AppColors.darkGreen,
              isLoading: _isLoading,
              onPressed: _saveProfile,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
