import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class TautIllustration {
  TautIllustration._();

  static Widget communicationHero({double height = 150}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _CommunicationHeroPainter(),
        size: Size.infinite,
      ),
    );
  }

  static Widget onboardingWelcome({double height = 240}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _OnboardingWelcomePainter(),
        size: Size.infinite,
      ),
    );
  }

  static Widget clinicHeaderBanner({double height = 180}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _ClinicHeaderPainter(),
        size: Size.infinite,
      ),
    );
  }

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

  static Widget mapPlaceholder({double height = 170}) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _MapPlaceholderPainter(),
        size: Size.infinite,
      ),
    );
  }

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

class _CommunicationHeroPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final scale = (size.width / 230).clamp(0.0, size.height / 230);
    final dx = (size.width - 230 * scale) / 2;
    final dy = (size.height - 230 * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(116, 205), width: 190, height: 24),
      Paint()..color = const Color(0xFFB8CBB0)..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      const Offset(129, 101),
      86,
      Paint()..color = const Color(0xFFE7EFDF)..style = PaintingStyle.fill,
    );

    final leftBody = Path()
      ..moveTo(30, 200)
      ..lineTo(30, 145)
      ..quadraticBezierTo(30, 107, 70, 107)
      ..quadraticBezierTo(110, 107, 110, 145)
      ..lineTo(110, 200)
      ..close();
    canvas.drawPath(
      leftBody,
      Paint()..color = const Color(0xFF527B5D)..style = PaintingStyle.fill,
    );

    final rightBody = Path()
      ..moveTo(125, 200)
      ..lineTo(125, 139)
      ..quadraticBezierTo(125, 107, 159, 107)
      ..quadraticBezierTo(193, 107, 198, 139)
      ..lineTo(198, 200)
      ..close();
    canvas.drawPath(
      rightBody,
      Paint()..color = const Color(0xFFA7B997)..style = PaintingStyle.fill,
    );

    final leftArm = Path()
      ..moveTo(53, 143)
      ..lineTo(83, 174)
      ..lineTo(133, 146);
    canvas.drawPath(
      leftArm,
      Paint()
        ..color = const Color(0xFFD6AA8B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final rightArm = Path()
      ..moveTo(176, 143)
      ..lineTo(153, 171)
      ..lineTo(128, 153);
    canvas.drawPath(
      rightArm,
      Paint()
        ..color = const Color(0xFFB87D61)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(69, 79), width: 50, height: 62),
      Paint()..color = const Color(0xFFD6AA8B)..style = PaintingStyle.fill,
    );

    final leftHair = Path()
      ..moveTo(44, 80)
      ..quadraticBezierTo(29, 40, 66, 42)
      ..quadraticBezierTo(101, 41, 94, 78)
      ..lineTo(82, 62)
      ..quadraticBezierTo(71, 77, 44, 72)
      ..close();
    canvas.drawPath(
      leftHair,
      Paint()..color = const Color(0xFF263D2F)..style = PaintingStyle.fill,
    );

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(159, 82), width: 48, height: 60),
      Paint()..color = const Color(0xFFB87D61)..style = PaintingStyle.fill,
    );

    final rightHair = Path()
      ..moveTo(135, 79)
      ..quadraticBezierTo(123, 44, 154, 40)
      ..quadraticBezierTo(190, 34, 184, 81)
      ..lineTo(170, 58)
      ..quadraticBezierTo(155, 71, 135, 70)
      ..close();
    canvas.drawPath(
      rightHair,
      Paint()..color = const Color(0xFF384A38)..style = PaintingStyle.fill,
    );

    final eyePaint = Paint()
      ..color = const Color(0xFF263D2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(82, 84), const Offset(85, 84), eyePaint);
    canvas.drawLine(const Offset(152, 84), const Offset(155, 84), eyePaint);

    final smilePaint = Paint()
      ..color = const Color(0xFF79533C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final leftSmile = Path()
      ..moveTo(79, 95)
      ..quadraticBezierTo(86, 100, 90, 94);
    canvas.drawPath(leftSmile, smilePaint);

    final rightSmile = Path()
      ..moveTo(140, 95)
      ..quadraticBezierTo(146, 100, 151, 95);
    canvas.drawPath(rightSmile, smilePaint);

    final bubblePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(85, 7, 55, 33),
        const Radius.circular(14),
      ),
      bubblePaint,
    );
    final tail = Path()
      ..moveTo(108, 38)
      ..lineTo(100, 47)
      ..lineTo(102, 35)
      ..close();
    canvas.drawPath(tail, bubblePaint);

    final dotPaint = Paint()..color = const Color(0xFF527B5D)..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(102, 23), 3, dotPaint);
    canvas.drawCircle(const Offset(113, 23), 3, dotPaint);
    canvas.drawCircle(const Offset(124, 23), 3, dotPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OnboardingWelcomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.lightGreen, AppColors.sageGreen.withValues(alpha: 0.8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    canvas.drawCircle(Offset(w * 0.5, h * 0.5), h * 0.46, bgPaint);

    final bubblePaint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.2, h * 0.22), 16, bubblePaint);
    canvas.drawCircle(Offset(w * 0.82, h * 0.28), 22, bubblePaint);
    canvas.drawCircle(Offset(w * 0.85, h * 0.65), 14, bubblePaint);

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

    final scrubPaint = Paint()..color = AppColors.primaryGreen;
    final scrubPath = Path()
      ..moveTo(w * 0.45, h * 0.48)
      ..lineTo(w * 0.55, h * 0.48)
      ..lineTo(w * 0.50, h * 0.65)
      ..close();
    canvas.drawPath(scrubPath, scrubPaint);

    final skinPaint = Paint()..color = const Color(0xFFF3C59D);
    canvas.drawCircle(Offset(w * 0.5, h * 0.35), h * 0.14, skinPaint);

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

    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppColors.sageGreen, AppColors.lightGreen],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    final buildingPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final buildingRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.15, w * 0.7, h * 0.85),
      const Radius.circular(16),
    );
    canvas.drawRRect(buildingRect, buildingPaint);

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

    final bgPaint = Paint()
      ..color = AppColors.accentMtsBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.48, bgPaint);

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

    final bgPaint = Paint()
      ..color = AppColors.accentSttBg
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.48, bgPaint);

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

    final ringPaint = Paint()
      ..color = AppColors.accentLocation.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.38, ringPaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.24, ringPaint);

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

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFFE6ECDF),
    );

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

    final routePaint = Paint()
      ..color = const Color(0xFF527B5D)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final routePath = Path()
      ..moveTo(w * 0.28, h * 0.82)
      ..lineTo(w * 0.33, h * 0.40)
      ..lineTo(w * 0.66, h * 0.56);
    canvas.drawPath(routePath, routePaint);

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

    final destRect = Rect.fromCenter(
      center: Offset(w * 0.66, h * 0.56),
      width: 26,
      height: 26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(destRect, const Radius.circular(8)),
      Paint()..color = const Color(0xFF527B5D),
    );

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

