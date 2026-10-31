import 'package:flutter/material.dart';

/// Reusable, stationary, modular background recreated directly from design reference
/// (Gemini_Generated_Image_6uhnu16uhnu16uhn).
/// Decomposed into 5 independent vector components:
/// 1. Base gradient & radial ambient glows
/// 2. Concentric circle celestial hub (8 rings + translucent core)
/// 3. Three undulating soundwave curves
/// 4. 4-pointed celestial diamond sparkle stars
/// 5. Orbiting satellite dots & constellation stardust spray
class TautModularBackground extends StatelessWidget {
  const TautModularBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: CustomPaint(
        painter: _ModularBackgroundPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _ModularBackgroundPainter extends CustomPainter {
  const _ModularBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // -------------------------------------------------------------
    // 1. BASE MULTI-STOP LINEAR GRADIENT
    // -------------------------------------------------------------
    final baseRect = Rect.fromLTWH(0, 0, w, h);
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFC7DEBF), // Crisp sage top (matching reference)
          Color(0xFFD9EADB), // Pastel light green
          Color(0xFFEBF3EA), // Soft transition
          Color(0xFFF7FAF6), // Ivory light center
          Color(0xFFFAF7EE), // Gentle pale warm transition
          Color(0xFFFBF2E3), // Warm golden peach bottom glow
        ],
        stops: [0.0, 0.18, 0.36, 0.54, 0.75, 1.0],
      ).createShader(baseRect);
    canvas.drawRect(baseRect, basePaint);

    // -------------------------------------------------------------
    // 2. AMBIENT RADIAL BLOOMS
    // -------------------------------------------------------------
    // Top-Right Vibrant Sage Bloom
    final trGlowRect = Rect.fromCircle(
      center: Offset(w * 0.90, h * 0.08),
      radius: w * 0.65,
    );
    final trPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF98C490).withValues(alpha: 0.55),
          const Color(0xFFBFDEB7).withValues(alpha: 0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(trGlowRect);
    canvas.drawOval(trGlowRect, trPaint);

    // Mid-Left Soft Pale Glow
    final mlGlowRect = Rect.fromCircle(
      center: Offset(w * 0.05, h * 0.52),
      radius: w * 0.50,
    );
    final mlPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFF7E2).withValues(alpha: 0.70),
          const Color(0xFFFFF7E2).withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.50, 1.0],
      ).createShader(mlGlowRect);
    canvas.drawOval(mlGlowRect, mlPaint);

    // Bottom-Right Warm Amber/Peach Bloom
    final brGlowRect = Rect.fromCircle(
      center: Offset(w * 0.88, h * 0.90),
      radius: w * 0.65,
    );
    final brPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFDECD4).withValues(alpha: 0.85),
          const Color(0xFFFDECD4).withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(brGlowRect);
    canvas.drawOval(brGlowRect, brPaint);

    // -------------------------------------------------------------
    // 3. CONCENTRIC CIRCLE CELESTIAL HUB (Centered at x=50%, y=28%)
    // -------------------------------------------------------------
    final hubCenter = Offset(w * 0.50, h * 0.28);
    final maxHubRadius = w * 0.44; // Extends across 88% screen width!

    // Translucent central core
    final corePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF8CBA88).withValues(alpha: 0.22);
    canvas.drawCircle(hubCenter, maxHubRadius * 0.22, corePaint);

    final circlePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final circleRatios = [0.15, 0.25, 0.36, 0.48, 0.60, 0.73, 0.86, 1.00];
    final circleOpacities = [0.55, 0.50, 0.44, 0.38, 0.32, 0.26, 0.20, 0.15];
    final circleStrokeWidths = [2.0, 1.8, 1.6, 1.5, 1.4, 1.3, 1.2, 1.1];

    for (int i = 0; i < circleRatios.length; i++) {
      final r = maxHubRadius * circleRatios[i];
      circlePaint
        ..strokeWidth = circleStrokeWidths[i]
        ..color = const Color(0xFF5D845A).withValues(alpha: circleOpacities[i]);
      canvas.drawCircle(hubCenter, r, circlePaint);
    }

    // -------------------------------------------------------------
    // 4. THREE SOUNDWAVE BEZIER HORIZONS
    // -------------------------------------------------------------
    // Upper Wavy Soundwave (crosses across upper concentric hub)
    final line1Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF527B5D).withValues(alpha: 0.60);

    final line1 = Path()
      ..moveTo(-w * 0.08, h * 0.18)
      ..cubicTo(w * 0.24, h * 0.15, w * 0.66, h * 0.23, w * 1.08, h * 0.20);
    canvas.drawPath(line1, line1Paint);

    // Middle Wavy Horizon (undulates around 58% screen height)
    final line2Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF527B5D).withValues(alpha: 0.55);

    final line2 = Path()
      ..moveTo(-w * 0.08, h * 0.58)
      ..cubicTo(w * 0.28, h * 0.55, w * 0.68, h * 0.62, w * 1.08, h * 0.58);
    canvas.drawPath(line2, line2Paint);

    // Lower Warm Horizon (gentle warm curve near bottom)
    final line3Paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFC6B796).withValues(alpha: 0.65);

    final line3 = Path()
      ..moveTo(-w * 0.08, h * 0.79)
      ..cubicTo(w * 0.34, h * 0.83, w * 0.68, h * 0.74, w * 1.08, h * 0.76);
    canvas.drawPath(line3, line3Paint);

    // -------------------------------------------------------------
    // 5. FOUR-POINTED SPARKLE STARS (Curved Diamond Beziers)
    // -------------------------------------------------------------
    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF263D2F);

    _drawFourPointStar(canvas, Offset(w * 0.21, h * 0.30), 10.5, starPaint..color = const Color(0xFF263D2F).withValues(alpha: 0.85));
    _drawFourPointStar(canvas, Offset(w * 0.82, h * 0.27), 12.0, starPaint..color = const Color(0xFF263D2F).withValues(alpha: 0.90));
    _drawFourPointStar(canvas, Offset(w * 0.80, h * 0.57), 9.5, starPaint..color = const Color(0xFF263D2F).withValues(alpha: 0.80));

    // -------------------------------------------------------------
    // 6. ORBITING SATELLITE DOTS & CONSTELLATION STARDUST
    // -------------------------------------------------------------
    final dotDark = Paint()..color = const Color(0xFF263D2F).withValues(alpha: 0.90);
    final dotMedium = Paint()..color = const Color(0xFF527B5D).withValues(alpha: 0.85);
    final dotLight = Paint()..color = const Color(0xFF88A88B).withValues(alpha: 0.80);

    // Satellite Dots
    canvas.drawCircle(Offset(w * 0.185, h * 0.285), 4.0, dotDark);
    canvas.drawCircle(Offset(w * 0.260, h * 0.340), 4.8, dotMedium);
    canvas.drawCircle(Offset(w * 0.780, h * 0.250), 4.2, dotDark);
    canvas.drawCircle(Offset(w * 0.860, h * 0.310), 4.6, dotMedium);
    canvas.drawCircle(Offset(w * 0.160, h * 0.570), 3.8, dotLight);
    canvas.drawCircle(Offset(w * 0.275, h * 0.605), 3.5, dotDark);

    // Clustered Constellation Micro-Dust Spray
    final dustPaint = Paint()..color = const Color(0xFF3F6343).withValues(alpha: 0.70);
    final dustOffsets = [
      Offset(w * 0.42, h * 0.14),
      Offset(w * 0.50, h * 0.15),
      Offset(w * 0.58, h * 0.16),
      Offset(w * 0.66, h * 0.13),
      Offset(w * 0.71, h * 0.18),
      Offset(w * 0.75, h * 0.22),
      Offset(w * 0.78, h * 0.23),
      Offset(w * 0.84, h * 0.28),
      Offset(w * 0.76, h * 0.33),
      Offset(w * 0.72, h * 0.38),
      Offset(w * 0.52, h * 0.46),
      Offset(w * 0.38, h * 0.45),
      Offset(w * 0.29, h * 0.43),
      Offset(w * 0.23, h * 0.39),
      Offset(w * 0.20, h * 0.35),
      Offset(w * 0.15, h * 0.31),
      Offset(w * 0.12, h * 0.24),
      Offset(w * 0.21, h * 0.24),
      Offset(w * 0.31, h * 0.23),
      Offset(w * 0.35, h * 0.19),
    ];

    for (int i = 0; i < dustOffsets.length; i++) {
      final r = (i % 3 == 0) ? 1.6 : (i % 2 == 0) ? 1.3 : 1.0;
      canvas.drawCircle(dustOffsets[i], r, dustPaint);
    }
  }

  /// Exact 4-pointed celestial sparkle with concave quadratic curve flanks
  void _drawFourPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    final cx = center.dx;
    final cy = center.dy;
    final r = radius;

    final path = Path()
      ..moveTo(cx, cy - r)
      ..quadraticBezierTo(cx, cy, cx + r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy + r)
      ..quadraticBezierTo(cx, cy, cx - r, cy)
      ..quadraticBezierTo(cx, cy, cx, cy - r)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
