import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';

/// Clean, healthcare-oriented Register Screen.
/// Collects user name, email, password, and accessibility preference.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'Teman Tuli';
  bool _isLoading = false;

  final List<String> _roles = const [
    'Teman Tuli',
    'Teman Dengar',
    'Pendamping / Relawan',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Akun berhasil didaftarkan sebagai $_selectedRole. Selamat datang di TAUT!'),
          ),
        );
        Navigator.pushReplacementNamed(context, AppConstants.routeHome);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Bergabung Bersama TAUT',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Daftarkan diri Anda untuk pengalaman aksesibilitas yang dipersonalisasi dan aman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24),
            AppCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Alfredo Jonathan',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'nama@email.com',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kata Sandi',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Minimal 8 karakter',
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preferensi Pengguna',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
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
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Buat Akun TAUT',
                    isLoading: _isLoading,
                    onPressed: _handleRegister,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Sudah punya akun? Masuk kembali'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
