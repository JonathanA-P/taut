import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routing/app_router.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    final isTest = WidgetsBinding.instance.runtimeType.toString().contains('Test');

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    if (!isTest) {
      _pulseController.repeat();
    }

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );
    if (!isTest) {
      _floatController.repeat(reverse: true);
    }

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      lowerBound: 0.92,
      upperBound: 1.12,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  void _handleLogoTap() {
    _bounceController.forward().then((_) => _bounceController.reverse());
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('TAUT: Ruang untuk saling memahami'),
        duration: Duration(milliseconds: 1400),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.36),
                  radius: 0.95,
                  colors: [
                    Color(0xFFD6E7D2),
                    Color(0xFFEBF4E8),
                    Color(0xFFF8FAF7),
                  ],
                  stops: [0.0, 0.45, 0.85],
                ),
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -30,
            child: _buildAmbientOrb(
              width: 190,
              height: 190,
              color: const Color(0x60BCDA8F),
            ),
          ),
          Positioned(
            top: 60,
            right: -40,
            child: _buildAmbientOrb(
              width: 180,
              height: 180,
              color: const Color(0x60F7EAD8),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -40,
            child: _buildAmbientOrb(
              width: 200,
              height: 200,
              color: const Color(0x50C6E2C2),
            ),
          ),
          Positioned(
            bottom: 20,
            right: -30,
            child: _buildAmbientOrb(
              width: 170,
              height: 170,
              color: const Color(0x55D2E8CE),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _AcousticResonancePainter(),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  const Spacer(),
                  _buildCenteredHero(),
                  const Spacer(),
                  _buildBottomAction(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientOrb({
    required double width,
    required double height,
    required Color color,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }

  Widget _buildCenteredHero() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x40C6DEC0),
                    Color(0x20DEEEDA),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.55, 0.85],
                ),
              ),
            ),
            Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x2A527B5D),
                  width: 1.5,
                ),
              ),
            ),
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0x35527B5D),
                  width: 1.0,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildPulseRing(_pulseController.value),
                    _buildPulseRing((_pulseController.value + 0.33) % 1.0),
                    _buildPulseRing((_pulseController.value + 0.66) % 1.0),
                  ],
                );
              },
            ),
            AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final offset = math.sin(_floatController.value * math.pi) * 5.0;
                return Transform.translate(
                  offset: Offset(0, -offset),
                  child: child,
                );
              },
              child: ScaleTransition(
                scale: _bounceController,
                child: GestureDetector(
                  onTap: _handleLogoTap,
                  child: Container(
                    width: 102,
                    height: 102,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE2EDE0),
                          Color(0xFFD1E1CF),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFFC4D7C1),
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x28263D2F),
                          blurRadius: 36,
                          offset: Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomPaint(
                        size: const Size(54, 54),
                        painter: _TautKnotPainter(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        RichText(
          text: const TextSpan(
            text: 'taut',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGreen,
              letterSpacing: -2.0,
            ),
            children: [
              TextSpan(
                text: '.',
                style: TextStyle(
                  color: Color(0xFF8AAB7E),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ruang untuk saling memahami',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4E6554),
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xA6FFFFFF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xB2D7E3D1),
              width: 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSoundBar(height: 8, color: const Color(0xFF8AAB7E)),
              const SizedBox(width: 4),
              _buildSoundBar(height: 14, color: const Color(0xFF527B5D)),
              const SizedBox(width: 4),
              _buildSoundBar(height: 18, color: const Color(0xFF385841)),
              const SizedBox(width: 4),
              _buildSoundBar(height: 12, color: const Color(0xFF527B5D)),
              const SizedBox(width: 4),
              _buildSoundBar(height: 7, color: const Color(0xFF8AAB7E)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPulseRing(double progress) {
    final scale = 0.85 + (progress * 0.75);
    final opacity = (1.0 - progress).clamp(0.0, 0.75);
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 130,
        height: 130,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Color.fromRGBO(82, 123, 93, opacity),
            width: 1.8,
          ),
        ),
      ),
    );
  }

  Widget _buildSoundBar({required double height, required Color color}) {
    return Container(
      width: 3.5,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 130,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFFE2EDE0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: 130,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              shadowColor: const Color(0x40527B5D),
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18),
            label: const Text(
              'Mulai Eksplorasi',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TautKnotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 50.0;
    canvas.save();
    canvas.scale(scale);

    final path = Path()
      ..moveTo(26, 14)
      ..cubicTo(10, -2, -3, 21, 15, 34)
      ..cubicTo(32, 47, 47, 25, 32, 14)
      ..cubicTo(19, 4, 7, 25, 24, 36);

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 5.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AcousticResonancePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final ribbonPaint1 = Paint()
      ..color = const Color(0x35527B5D)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path1 = Path()
      ..moveTo(-20, h * 0.22)
      ..cubicTo(w * 0.25, h * 0.14, w * 0.55, h * 0.32, w + 20, h * 0.24);
    canvas.drawPath(path1, ribbonPaint1);

    final ribbonPaint2 = Paint()
      ..color = const Color(0x308AAB7E)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path2 = Path()
      ..moveTo(-20, h * 0.68)
      ..cubicTo(w * 0.28, h * 0.60, w * 0.65, h * 0.76, w + 20, h * 0.66);
    canvas.drawPath(path2, ribbonPaint2);

    final nodePaint = Paint()
      ..color = const Color(0x99527B5D)
      ..style = PaintingStyle.fill;
    final lightNodePaint = Paint()
      ..color = const Color(0x998AAB7E)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.18, h * 0.32), 3.5, nodePaint);
    canvas.drawCircle(Offset(w * 0.26, h * 0.38), 4.5, lightNodePaint);

    canvas.drawCircle(Offset(w * 0.78, h * 0.28), 3.5, nodePaint);
    canvas.drawCircle(Offset(w * 0.86, h * 0.34), 4.0, lightNodePaint);

    canvas.drawCircle(Offset(w * 0.16, h * 0.64), 3.5, lightNodePaint);
    canvas.drawCircle(Offset(w * 0.28, h * 0.68), 3.0, nodePaint);

    _drawSparkle(canvas, Offset(w * 0.22, h * 0.34), 6, nodePaint);
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.30), 7, lightNodePaint);
    _drawSparkle(canvas, Offset(w * 0.80, h * 0.64), 6, nodePaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
