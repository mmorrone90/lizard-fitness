import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lizard_fitness/theme/app_theme.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogle;
  final VoidCallback onApple;
  final bool isLoading;

  const SocialAuthButtons({
    super.key,
    required this.onGoogle,
    required this.onApple,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SocialButton(
          onPressed: isLoading ? null : onGoogle,
          label: 'Google',
          icon: _GoogleIcon(),
        )),
        const SizedBox(width: 12),
        if (Platform.isIOS)
          Expanded(child: _SocialButton(
            onPressed: isLoading ? null : onApple,
            label: 'Apple',
            icon: const Icon(Icons.apple, size: 20, color: Colors.white),
          )),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final Widget icon;

  const _SocialButton({required this.onPressed, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: kCardLight, width: 1.5),
        backgroundColor: kCard,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // Background circle
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    // Draw G segments
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.85);

    paint.color = const Color(0xFF4285F4); // Blue
    canvas.drawArc(rect, -0.52, 1.57, true, paint);

    paint.color = const Color(0xFF34A853); // Green
    canvas.drawArc(rect, 1.05, 1.57, true, paint);

    paint.color = const Color(0xFFFBBC05); // Yellow
    canvas.drawArc(rect, 2.62, 0.79, true, paint);

    paint.color = const Color(0xFFEA4335); // Red
    canvas.drawArc(rect, -1.57, 1.05, true, paint);

    // White center cutout
    paint.color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, paint);

    // Blue right bar (horizontal part of G)
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(Rect.fromLTWH(cx, cy - r * 0.14, r * 0.9, r * 0.28), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
