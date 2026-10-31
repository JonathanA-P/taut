import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/taut_app_state.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = TautAppState();

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
          'Privasi & izin',
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
            children: [
              _buildHero(),
              const SizedBox(height: 24),

              _buildLegalCard(),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    state.stopHardwareTracks();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Akses kamera dan mikrofon dihentikan.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: Color(0xFFB9C9B6)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Hentikan akses perangkat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.sageGreen,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Kendalinya ada padamu.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Izin diminta saat fitur digunakan.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kamera',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Preview kamera hanya aktif setelah kamu memilih tombol kamera dan memberi izin browser. Tidak ada model BISINDO terhubung.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Mikrofon',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Pengenalan ucapan memakai kemampuan browser, jika tersedia. Penyedia browser dapat memproses audio melalui internet.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Lokasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Peta dan berbagi lokasi pada prototipe menggunakan data contoh. Tidak ada koordinat nyata yang dikirim.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 18),
          Text(
            'Penyimpanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGreen,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Data demo disimpan dalam memori halaman. Muat ulang akan menghapus perubahan. Tidak ada audio, video, atau kata sandi yang disimpan.',
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

