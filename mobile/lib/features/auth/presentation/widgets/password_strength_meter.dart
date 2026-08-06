import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  int _calculateStrength() {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'\d').hasMatch(password)) score++;
    if (RegExp(r'[a-zA-Z]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(password)) score++; // extra for special char
    return score;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = _calculateStrength();
    final width = MediaQuery.of(context).size.width - 48; // padding
    final segmentWidth = (width - 16) / 4;

    Color getColor(int index) {
      if (index >= strength) return AppColors.surface60;
      if (strength == 1) return AppColors.error;
      if (strength == 2) return AppColors.accentCta;
      return AppColors.success;
    }

    String getLabel() {
      if (strength == 0) return '';
      if (strength == 1) return 'Weak';
      if (strength == 2) return 'Fair';
      if (strength >= 3) return 'Strong';
      return '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(4, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              width: segmentWidth,
              decoration: BoxDecoration(
                color: getColor(index),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          getLabel(),
          style: TextStyle(
            color: getColor(strength - 1),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
