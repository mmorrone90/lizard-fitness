import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          icon: SvgPicture.asset('assets/icons/google_icon.svg', width: 20, height: 20),
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
