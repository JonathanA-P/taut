import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Clean, self-contained vector illustrations crafted specifically for TAUT.
/// Follows the friendly healthcare aesthetic of the Dribbble reference:
/// soft pastel fills, rounded human silhouettes, sage green harmony, and zero external network dependency.
class TautIllustration {
  TautIllustration._();

  /// Hero Illustration for the Personal Dashboard and Communication Hub.
  /// Depicts friendly human two-way communication (sound waves & visual interaction).
  static Widget communicationHero({double height = 150}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _CommunicationHeroPainter(),
        size: Size.infinite,
      ),
    );
  }

  /// Onboarding Welcome Illustration inspired by Dribbble Screen 1:
  /// Friendly healthcare professional welcoming the user with clipboard and accessibility smile.
  static Widget onboardingWelcome({double height = 240}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _OnboardingWelcomePainter(),
        size: Size.infinite,
      ),
    );
  }

  /// Detail Header Banner Illustration inspired by Dribbble Screen 3:
  /// Doctors collaborating in a modern accessible clinic.
  static Widget clinicHeaderBanner({double height = 180}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _ClinicHeaderPainter(),
        size: Size.infinite,
      ),
    );
  }

  /// Sign Language & Gesture Recognition Illustration.
  static Widget signLanguage({double size = 100}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SignLanguagePainter(),
        size: Size(size, size),
      ),
    );
  }

  /// Hearing Accessibility & Audio Wave Illustration.
  static Widget hearingAccessibility({double size = 100}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HearingAccessibilityPainter(),
        size: Size(size, size),
      ),
    );
  }

  /// Location & Emergency Sharing Illustration.
  static Widget locationSharing({double size = 100}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LocationSharingPainter(),
        size: Size(size, size),
      ),
    );
  }

  /// Friendly Avatar Placeholder for Doctors / Healthcare Staff.
  static Widget healthcareAvatar({
    double radius = 28,
    Color backgroundColor = AppColors.lightGreen,
    Color iconColor = AppColors.primaryGreen,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Icon(
        Icons.local_hospital_rounded,
        size: radius * 1.1,
        color: iconColor,
      ),
    );
  }

  /// Map illustration card placeholder strictly matching the HTML prototype vector.
  static Widget mapPlaceholder({double height = 170}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _MapPlaceholderPainter(),
        size: Size.infinite,
      ),
    );
  }

  /// Friendly two-person inclusive communication vector for Onboarding.
  static Widget friendlyConversationHero({double width = 260, double height = 220}) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _CommunicationHeroPainter(),
        size: Size(width, height),
      ),
    );
  }

  /// Friendly Avatar Placeholder for Connected Friends.
  static Widget friendAvatar({
    required String initials,
    double radius = 24,
    Color? backgroundColor,
    Color? textColor,
  }) {
    final bg = backgroundColor ?? AppColors.sageGreen;
    final fg = textColor ?? AppColors.darkGreen;
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Text(
        initials,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CUSTOM PAINTER IMPLEMENTATIONS (Lightweight, pure native canvas rendering)
// ---------------------------------------------------------------------------

class _CommunicationHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft organic background blob
    final blobPaint = Paint()
      ..color = AppColors.sageGreen.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(w * 0.1, h * 0.5)
      ..quadraticBezierTo(w * 0.15, h * 0.05, w * 0.55, h * 0.1)
      ..quadraticBezierTo(w * 0.95, h * 0.15, w * 0.9, h * 0.6)
      ..quadraticBezierTo(w * 0.85, h * 0.95, w * 0.45, h * 0.9)
      ..quadraticBezierTo(w * 0.05, h * 0.85, w * 0.1, h * 0.5)
      ..close();
    canvas.drawPath(path, blobPaint);

    // Accent soft circle
    final accentPaint = Paint()
      ..color = AppColors.lightGreen
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.78, h * 0.35), h * 0.28, accentPaint);

    // Left Figure (Friendly Teal/Green)
    final figurePaint1 = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(w * 0.32, h * 0.36), h * 0.14, figurePaint1);
    // Torso (rounded pill)
    final torso1 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.32, h * 0.76),
        width: w * 0.22,
        height: h * 0.5,
      ),
      const Radius.circular(24),
    );
    canvas.drawRRect(torso1, figurePaint1);

    // Right Figure (Dark Green)
    final figurePaint2 = Paint()
      ..color = AppColors.darkGreen
      ..style = PaintingStyle.fill;

    // Head
    canvas.drawCircle(Offset(w * 0.68, h * 0.36), h * 0.14, figurePaint2);
    // Torso
    final torso2 = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.68, h * 0.76),
        width: w * 0.22,
        height: h * 0.5,
      ),
      const Radius.circular(24),
    );
    canvas.drawRRect(torso2, figurePaint2);

    // Speech bubble connecting them in the center
    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final bubbleShadow = Paint()
      ..color = AppColors.darkGreen.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.34),
        width: w * 0.26,
        height: h * 0.32,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(bubbleRect.shift(const Offset(0, 3)), bubbleShadow);
    canvas.drawRRect(bubbleRect, bubblePaint);

    // Sound wave lines inside bubble
    final wavePaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.44, h * 0.34),
      Offset(w * 0.44, h * 0.34),
      wavePaint,
    );
    canvas.drawLine(
      Offset(w * 0.48, h * 0.28),
      Offset(w * 0.48, h * 0.40),
      wavePaint,
    );
    canvas.drawLine(
      Offset(w * 0.52, h * 0.25),
      Offset(w * 0.52, h * 0.43),
      wavePaint,
    );
    canvas.drawLine(
      Offset(w * 0.56, h * 0.30),
      Offset(w * 0.56, h * 0.38),
      wavePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingWelcomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft sage gradient background circle
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.lightGreen, AppColors.sageGreen.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), h * 0.46, bgPaint);

    // Small decorative bubbles
    final bubblePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.2, h * 0.22), 16, bubblePaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.28), 22, bubblePaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.65), 14, bubblePaint);

    // Central Doctor / Specialist Figure
    // Stethoscope / Coat
    final coatPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    final coatShadow = Paint()
      ..color = AppColors.darkGreen.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final coatRRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.68),
        width: w * 0.48,
        height: h * 0.46,
      ),
      const Radius.circular(32),
    );
    canvas.drawRRect(coatRRect.shift(const Offset(0, 4)), coatShadow);
    canvas.drawRRect(coatRRect, coatPaint);

    // Dark green scrub collar / tie
    final scrubPaint = Paint()..color = AppColors.primaryGreen;
    final scrubPath = Path()
      ..moveTo(w * 0.45, h * 0.48)
      ..lineTo(w * 0.55, h * 0.48)
      ..lineTo(w * 0.50, h * 0.65)
      ..close();
    canvas.drawPath(scrubPath, scrubPaint);

    // Head
    final skinPaint = Paint()..color = const Color(0xFFF3C59D);
    canvas.drawCircle(Offset(w * 0.5, h * 0.35), h * 0.14, skinPaint);

    // Hair (Dark Green / Black style)
    final hairPaint = Paint()..color = AppColors.darkGreen;
    final hairPath = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.34),
          width: h * 0.30,
          height: h * 0.28,
        ),
        3.14,
        3.14,
      );
    canvas.drawPath(hairPath, hairPaint);

    // Clipboard held with checkmark (symbolizing verification & accessibility)
    final clipPaint = Paint()..color = AppColors.sageGreen;
    final clipRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.68, h * 0.65),
        width: w * 0.22,
        height: h * 0.26,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(clipRect, clipPaint);

    final checkPaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final checkPath = Path()
      ..moveTo(w * 0.62, h * 0.65)
      ..lineTo(w * 0.66, h * 0.69)
      ..lineTo(w * 0.74, h * 0.60);
    canvas.drawPath(checkPath, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ClinicHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Pastel gradient background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.sageGreen, AppColors.lightGreen],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Clinic Building / Medical Cross in backdrop
    final buildingPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.85),
      const Radius.circular(16),
    );
    canvas.drawRRect(buildingRect, buildingPaint);

    // Medical Cross
    final crossPaint = Paint()
      ..color = AppColors.primaryGreen
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.5, h * 0.28),
      Offset(w * 0.5, h * 0.44),
      crossPaint,
    );
    canvas.drawLine(
      Offset(w * 0.45, h * 0.36),
      Offset(w * 0.55, h * 0.36),
      crossPaint,
    );

    // Doctors standing in front (Silhouettes like Dribbble Screen 3)
    final d1 = Paint()..color = AppColors.darkGreen;
    canvas.drawCircle(Offset(w * 0.36, h * 0.54), h * 0.10, d1);
    final d1Torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.36, h * 0.82),
        width: w * 0.16,
        height: h * 0.45,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(d1Torso, d1);

    final d2 = Paint()..color = AppColors.primaryGreen;
    canvas.drawCircle(Offset(w * 0.64, h * 0.54), h * 0.10, d2);
    final d2Torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.64, h * 0.82),
        width: w * 0.16,
        height: h * 0.45,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(d2Torso, d2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SignLanguagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft warm amber background circle
    final bgPaint = Paint()
      ..color = AppColors.accentMtsBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.48, bgPaint);

    // Stylized hand silhouette
    final handPaint = Paint()
      ..color = AppColors.accentMts
      ..style = PaintingStyle.fill;

    final palmRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.6),
        width: w * 0.42,
        height: h * 0.42,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(palmRect, handPaint);

    // Fingers
    final fingerPaint = Paint()
      ..color = AppColors.accentMts
      ..strokeWidth = w * 0.08
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.38, h * 0.42),
      Offset(w * 0.38, h * 0.22),
      fingerPaint,
    );
    canvas.drawLine(
      Offset(w * 0.46, h * 0.42),
      Offset(w * 0.46, h * 0.18),
      fingerPaint,
    );
    canvas.drawLine(
      Offset(w * 0.54, h * 0.42),
      Offset(w * 0.54, h * 0.20),
      fingerPaint,
    );
    canvas.drawLine(
      Offset(w * 0.62, h * 0.44),
      Offset(w * 0.62, h * 0.26),
      fingerPaint,
    );

    // Motion spark lines
    final sparkPaint = Paint()
      ..color = AppColors.darkGreen
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(w * 0.22, h * 0.30),
      Offset(w * 0.16, h * 0.24),
      sparkPaint,
    );
    canvas.drawLine(
      Offset(w * 0.78, h * 0.30),
      Offset(w * 0.84, h * 0.24),
      sparkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HearingAccessibilityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft coral background circle
    final bgPaint = Paint()
      ..color = AppColors.accentSttBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.48, bgPaint);

    // Microphone capsule
    final micPaint = Paint()
      ..color = AppColors.accentStt
      ..style = PaintingStyle.fill;

    final micCapsule = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.42),
        width: w * 0.28,
        height: h * 0.40,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(micCapsule, micPaint);

    // Base & Stand
    final standPaint = Paint()
      ..color = AppColors.accentStt
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final arcPath = Path()
      ..addArc(
        Rect.fromCenter(
          center: Offset(w * 0.5, h * 0.46),
          width: w * 0.44,
          height: h * 0.42,
        ),
        0,
        3.14,
      );
    canvas.drawPath(arcPath, standPaint);

    canvas.drawLine(
      Offset(w * 0.5, h * 0.67),
      Offset(w * 0.5, h * 0.78),
      standPaint,
    );
    canvas.drawLine(
      Offset(w * 0.36, h * 0.78),
      Offset(w * 0.64, h * 0.78),
      standPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LocationSharingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..color = AppColors.accentLocationBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.48, bgPaint);

    // Radar pulse rings
    final ringPaint = Paint()
      ..color = AppColors.accentLocation.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.38, ringPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.24, ringPaint);

    // Map Pin
    final pinPaint = Paint()
      ..color = AppColors.accentLocation
      ..style = PaintingStyle.fill;

    final pinPath = Path()
      ..moveTo(w * 0.5, h * 0.72)
      ..quadraticBezierTo(w * 0.32, h * 0.50, w * 0.32, h * 0.40)
      ..arcToPoint(
        Offset(w * 0.68, h * 0.40),
        radius: Radius.circular(w * 0.18),
      )
      ..quadraticBezierTo(w * 0.68, h * 0.50, w * 0.5, h * 0.72)
      ..close();
    canvas.drawPath(pinPath, pinPaint);

    // White dot inside pin
    final dotPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.40), w * 0.08, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE6ECDF),
    );

    // White Roads
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadPath = Path()
      ..moveTo(0, h * 0.24)
      ..lineTo(w, h * 0.65)
      ..moveTo(w * 0.22, 0)
      ..lineTo(w * 0.16, h)
      ..moveTo(w * 0.75, 0)
      ..lineTo(w * 0.61, h)
      ..moveTo(0, h * 0.88)
      ..lineTo(w, h * 0.12);
    canvas.drawPath(roadPath, roadPaint);

    // River
    final riverPaint = Paint()
      ..color = const Color(0xFFC6DCE0)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.28, h * 0.25, w * 0.47, h * 0.72)
      ..quadraticBezierTo(w * 0.74, h * 0.84, w, h * 0.60);
    canvas.drawPath(riverPath, riverPaint);

    // Dotted route
    final routePaint = Paint()
      ..color = const Color(0xFF527B5D)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(w * 0.28, h * 0.82)
      ..lineTo(w * 0.33, h * 0.40)
      ..lineTo(w * 0.66, h * 0.56);
    canvas.drawPath(routePath, routePaint);

    // Origin Pin
    final originPaint = Paint()..color = const Color(0xFF527B5D);
    canvas.drawCircle(Offset(w * 0.28, h * 0.80), 8, originPaint);
    canvas.drawCircle(
      Offset(w * 0.28, h * 0.80),
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Destination Hospital Pin
    final destRect = Rect.fromCenter(
      center: Offset(w * 0.66, h * 0.56),
      width: 26,
      height: 26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(destRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF527B5D),
    );

    // Cross icon inside destination
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.66 - 6, h * 0.56),
      Offset(w * 0.66 + 6, h * 0.56),
      crossPaint,
    );
    canvas.drawLine(
      Offset(w * 0.66, h * 0.56 - 6),
      Offset(w * 0.66, h * 0.56 + 6),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
