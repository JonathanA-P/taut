import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/status_badge.dart';

/// Clean, healthcare-oriented Login Screen.
/// Follows the sage green aesthetic with comfortable inputs and clear accessibility.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(text: 'alfredo@ub.ac.id');
  final TextEditingController _passwordController = TextEditingController(text: '••••••••');
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil masuk sebagai Alfredo Jonathan (Mode Terverifikasi).'),
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
        title: const Text('Masuk ke TAUT'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StatusBadge.active(label: 'Supabase RLS Siap Terhubung'),
            ),
            const SizedBox(height: 20),
            Text(
              'Selamat Datang Kembali',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGreen,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masuk untuk mengakses sinkronisasi teman terpercaya dan berbagi lokasi real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            AppCard(
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email Pengguna',
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
                  const SizedBox(height: 18),
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
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Masukkan kata sandi',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppColors.textMuted,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tautan pemulihan kata sandi akan dikirim ke email terdaftar.'),
                          ),
                        );
                      },
                      child: const Text('Lupa Kata Sandi?'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Masuk Akun',
                    isLoading: _isLoading,
                    onPressed: _handleLogin,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.outline.withValues(alpha: 0.5))),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'atau',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.outline.withValues(alpha: 0.5))),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Daftar Akun Baru',
              isOutlined: true,
              icon: Icons.person_add_alt_rounded,
              onPressed: () {
                Navigator.pushNamed(context, AppConstants.routeRegister);
              },
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Lanjutkan Sebagai Tamu',
              isOutlined: true,
              backgroundColor: AppColors.textSecondary,
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppConstants.routeHome);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
