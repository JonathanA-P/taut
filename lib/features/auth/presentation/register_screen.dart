import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';
import '../../../shared/models/taut_app_state.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_repository.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final AuthRepository? authRepository;

  const RegisterScreen({super.key, this.authRepository});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController(
    text: 'Adriel',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'adriel@email.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: 'password123',
  );

  bool _isPasswordVisible = false;
  bool _termsAccepted = true;
  bool _isLoading = false;

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? AuthRepositoryImpl();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegisterSubmit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty) {
      _showFeedback('Mohon isi nama lengkap / panggilan.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showFeedback('Mohon isi alamat email yang valid.');
      return;
    }
    if (password.length < 6) {
      _showFeedback('Kata sandi minimal harus terdiri dari 6 karakter.');
      return;
    }
    if (!_termsAccepted) {
      _showFeedback('Mohon setujui Ketentuan Layanan & Privasi TAUT.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // [BACKEND CONNECT]: Supabase Auth signUp via AuthRepository
      final profile = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: name,
      );

      TautAppState().setUserName(profile.displayName);

      if (mounted) {
        _showFeedback('Akun $name berhasil dibuat! Mengarahkan ke Beranda...');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } catch (e) {
      TautAppState().setUserName(name);
      if (mounted) {
        _showFeedback(
          'Mode Demo/Offline: Akun $name aktif lokal. ($e)',
          isError: false,
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    // [BACKEND CONNECT]: Supabase Auth OAuth with Google
    _showFeedback('Menghubungkan akun Google SSO...');
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      TautAppState().setUserName('Pengguna Google');
      _showFeedback('Berhasil masuk via Google! Menuju Beranda...');
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _handleGuestMode() {
    TautAppState().setUserName('Tamu TAUT');
    _showFeedback('Masuk Mode Tamu: Menuju Beranda TAUT...');
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.darkGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.darkGreen,
          tooltip: 'Kembali ke Layar Welcome',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.welcome);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 6, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mulai perjalananmu 🌿',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen,
                  letterSpacing: -0.8,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Buat akun untuk ruang komunikasi yang memahami kamu.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),

              _buildInputLabel('Nama Lengkap / Panggilan'),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _nameController,
                hintText: 'Contoh: Adriel',
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 14),

              _buildInputLabel('Alamat Email'),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _emailController,
                hintText: 'nama@email.com',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),

              _buildInputLabel('Kata Sandi Baru'),
              const SizedBox(height: 6),
              _buildInputField(
                controller: _passwordController,
                hintText: 'Minimal 6 karakter',
                prefixIcon: Icons.lock_outline_rounded,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  tooltip: _isPasswordVisible
                      ? 'Sembunyikan kata sandi'
                      : 'Lihat kata sandi',
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () {
                  setState(() => _termsAccepted = !_termsAccepted);
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _termsAccepted
                            ? AppColors.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _termsAccepted
                              ? AppColors.primary
                              : const Color(0xFFCAD6C6),
                          width: 1.5,
                        ),
                      ),
                      child: _termsAccepted
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Saya menyetujui Ketentuan Layanan & Privasi Aksesibilitas TAUT.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF495D4F),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegisterSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: const Color(0x35527B5D),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Daftar Akun Baru',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  const Expanded(
                    child: Divider(color: Color(0xFFE2E8DF), height: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'atau',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Divider(color: Color(0xFFE2E8DF), height: 1),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCCD8C8), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGoogleIcon(),
                      const SizedBox(width: 10),
                      const Text(
                        'Daftar dengan Google',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _handleGuestMode,
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
                    foregroundColor: AppColors.darkGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Jelajahi tanpa Akun (Mode Tamu)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sudah punya akun?',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Masuk di sini',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.darkGreen,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 14, color: AppColors.darkGreen),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        prefixIcon: Icon(prefixIcon, color: AppColors.textMuted, size: 20),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE4D8), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDCE4D8), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2.0),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = const LinearGradient(
                colors: [
                  Color(0xFF4285F4),
                  Color(0xFF34A853),
                  Color(0xFFFBBC05),
                  Color(0xFFEA4335),
                ],
              ).createShader(const Rect.fromLTWH(0, 0, 18, 18)),
          ),
        ),
      ),
    );
  }
}
