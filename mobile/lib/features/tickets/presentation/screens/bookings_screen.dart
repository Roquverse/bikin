import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/my_tickets_provider.dart';

import '../../../auth/presentation/providers/auth_state_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/widgets/organizer_event_details_sheet.dart';
import '../../../profile/presentation/widgets/attendee_ticket_details_sheet.dart';

class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authStateProvider);
    final isOrganizer = userState.value?.role == 'ORGANIZER';

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        elevation: 0,
        title: Text(
          isOrganizer ? 'My Events' : 'My Tickets',
          style: const TextStyle(
            color: AppColors.offWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isOrganizer ? _buildOrganizerView(context, ref) : _buildAttendeeView(context, ref),
    );
  }

  Widget _buildOrganizerView(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userEventsProvider);

    return eventsAsync.when(
      data: (events) {
        if (events.isEmpty) {
          return Center(
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
                  child: const Icon(Icons.event_available, size: 40, color: AppColors.accentCta),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No events yet',
                  style: TextStyle(
                    color: AppColors.offWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an event to start selling tickets',
                  style: TextStyle(color: AppColors.secondary, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(userEventsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => OrganizerEventDetailsSheet(event: event),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accentCta.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event, color: AppColors.accentCta),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.caption, style: const TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            const Text('Tap to view bookings', style: TextStyle(color: AppColors.secondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
      error: (error, stack) => Center(child: Text('Error loading events: $error', style: const TextStyle(color: AppColors.error))),
    );
  }

  Widget _buildAttendeeView(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return Center(
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
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myTicketsProvider);
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];
              final eventTitle = ticket['event']?['title'] ?? 'Event Ticket';
              return GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AttendeeTicketDetailsSheet(ticket: ticket),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accentCta.withAlpha(30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.local_activity, color: AppColors.accentCta),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(eventTitle, style: const TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(ticket['status'] ?? 'VALID', style: const TextStyle(color: AppColors.success, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
      error: (error, stack) => Center(child: Text('Error loading tickets: $error', style: const TextStyle(color: AppColors.error))),
    );
  }
}
