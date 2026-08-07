import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/video_model.dart';
import '../widgets/ticket_booking_sheet.dart';
import 'package:intl/intl.dart';

class EventDetailsScreen extends StatelessWidget {
  final VideoModel video;

  const EventDetailsScreen({
    super.key,
    required this.video,
  });

  void _openTickets(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TicketBookingSheet(video: video),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.offWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(video.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.primaryBackground,
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.4],
                  ),
                ),
              ),
            ),
            
            // Event Info
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.caption,
                    style: GoogleFonts.montserrat(
                      color: AppColors.offWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location & Date
                  _buildInfoRow(
                    Icons.location_on,
                    video.location ?? 'Location not specified',
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.calendar_today,
                    video.date != null 
                        ? DateFormat('EEEE, MMMM d, y • h:mm a').format(DateTime.parse(video.date!).toLocal())
                        : 'Date not specified',
                  ),
                  const SizedBox(height: 24),
                  
                  // Organizer
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(video.organizerAvatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Organized by',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            video.organizerName,
                            style: const TextStyle(
                              color: AppColors.offWhite,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Action Button
                  if (video.hasTickets)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _openTickets(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentCta,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Get Tickets',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.accentCta, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.offWhite,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
