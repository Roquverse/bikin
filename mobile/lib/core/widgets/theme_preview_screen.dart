import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'buttons/primary_button.dart';
import 'buttons/secondary_button.dart';
import 'buttons/outline_button.dart';

class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bikin Theme Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Typography', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Text('Display Large (Sora)', style: Theme.of(context).textTheme.displayLarge),
            Text('Headline Medium (Sora)', style: Theme.of(context).textTheme.headlineMedium),
            Text('Body Large (Inter)', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 32),
            Text('Color Palette', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                _ColorSwatch(color: AppColors.primaryBackground, name: 'Background'),
                _ColorSwatch(color: AppColors.accentCta, name: 'Accent'),
                _ColorSwatch(color: AppColors.secondary, name: 'Secondary'),
                _ColorSwatch(color: AppColors.tertiaryNeutral, name: 'Tertiary'),
              ],
            ),
            const SizedBox(height: 32),
            Text('Buttons', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            PrimaryButton(text: 'Primary Button', onPressed: () {}),
            const SizedBox(height: 16),
            SecondaryButton(text: 'Secondary Button', onPressed: () {}),
            const SizedBox(height: 16),
            OutlineButton(text: 'Outline Button', onPressed: () {}),
          ],
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final String name;

  const _ColorSwatch({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.offWhite.withOpacity(0.2)),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
