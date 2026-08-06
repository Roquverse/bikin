import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: const Text(
          'My Tickets',
          style: TextStyle(
            color: AppColors.offWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.local_activity_outlined, size: 40, color: AppColors.accentCta),
            ),
            const SizedBox(height: 20),
            const Text(
              'No tickets yet',
              style: TextStyle(
                color: AppColors.offWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Book tickets to events from the feed',
              style: TextStyle(color: AppColors.secondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
