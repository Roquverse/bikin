import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class AttendeeTicketDetailsSheet extends StatelessWidget {
  final dynamic ticket;

  const AttendeeTicketDetailsSheet({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final eventTitle = ticket['event']['title'] ?? 'Unknown Event';
    final ticketStatus = ticket['status'] ?? 'VALID';
    final ticketId = ticket['id'] ?? '';
    final organizerName = ticket['event']['organizer']?['name'] ?? 'Unknown Organizer';

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Ticket',
                style: TextStyle(
                  color: AppColors.offWhite,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.offWhite),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: QrImageView(
              data: ticketId,
              version: QrVersions.auto,
              size: 200.0,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            eventTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'By $organizerName',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ticketStatus == 'VALID' ? AppColors.success.withAlpha(30) : AppColors.error.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ticketStatus == 'VALID' ? AppColors.success : AppColors.error,
              ),
            ),
            child: Text(
              ticketStatus,
              style: TextStyle(
                color: ticketStatus == 'VALID' ? AppColors.success : AppColors.error,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Present this QR code at the entrance.',
            style: TextStyle(color: AppColors.secondary, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
