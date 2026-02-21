import 'package:flutter/material.dart';

class CloudBackground extends StatelessWidget {
  final double height;
  final bool isShowCloud;

  const CloudBackground({
    super.key,
    this.height = 240,
    this.isShowCloud = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: Colors.transparent,
      child: CustomPaint(painter: _CloudPainter(isShowCloud: isShowCloud)),
    );
  }
}

class _CloudPainter extends CustomPainter {
  final bool isShowCloud;

  _CloudPainter({this.isShowCloud = true});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw sky gradient background
    final skyPaint = Paint();
    final rect = Offset.zero & size;
    final skyGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF64B5F6), // Blue 300
        Color(0xFFE3F2FD), // Blue 50
        Color(0x00FFFFFF), // Transparent at the bottom edge
      ],
      stops: [0.0, 0.6, 1.0],
    );
    skyPaint.shader = skyGradient.createShader(rect);
    canvas.drawRect(rect, skyPaint);

    // 2. Define cloud path
    final cloudPath = Path();

    if (isShowCloud) {
      // Smooth overlapping clouds scattered across the width at the middle/bottom
      cloudPath.addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.1, size.height * 0.8),
          radius: 55,
        ),
      );
      cloudPath.addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.35, size.height * 0.6),
          radius: 75,
        ),
      );
      cloudPath.addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.65, size.height * 0.65),
          radius: 80,
        ),
      );
      cloudPath.addOval(
        Rect.fromCircle(
          center: Offset(size.width * 0.9, size.height * 0.55),
          radius: 65,
        ),
      );
      cloudPath.addOval(
        Rect.fromCircle(
          center: Offset(size.width * 1.05, size.height * 0.7),
          radius: 60,
        ),
      );
    }

    // Fill the bottom space beneath the clouds so it blends fully towards the bottom
    cloudPath.addRect(
      Rect.fromLTRB(-50, size.height * 0.7, size.width + 50, size.height),
    );

    // 3. Draw a soft shadow under the clouds to make them pop
    //canvas.drawShadow(cloudPath, Colors.black12, 8.0, true);

    // 4. Draw clouds (gradient fading to transparent at the bottom)
    final cloudGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.white, Colors.white, Color(0x00FFFFFF)],
      stops: [0.0, 0.7, 1.0],
    );

    final cloudPaint = Paint()
      ..shader = cloudGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(cloudPath, cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
