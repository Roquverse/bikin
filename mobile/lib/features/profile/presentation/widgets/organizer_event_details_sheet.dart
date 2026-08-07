import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/events_provider.dart';
import '../../data/repositories/events_repository.dart';

class OrganizerEventDetailsSheet extends ConsumerWidget {
  final dynamic event;

  const OrganizerEventDetailsSheet({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingsState = ref.watch(eventBookingsProvider(event.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Event Details',
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
          const SizedBox(height: 16),
          Text(
            event.caption ?? 'Event Name',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement Edit Event logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit coming soon')),
                  );
                },
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCta,
                  foregroundColor: Colors.black,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: AppColors.surfaceElevated,
                      title: const Text('Delete Event?', style: TextStyle(color: AppColors.offWhite)),
                      content: const Text('Are you sure you want to delete this event? This action cannot be undone.', style: TextStyle(color: AppColors.secondary)),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.secondary)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: AppColors.error)),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final success = await ref.read(eventsRepositoryProvider).deleteEvent(event.id);
                    if (success && context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event deleted successfully')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete, size: 16, color: AppColors.error),
                label: const Text('Delete', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: AppColors.border),
          const Text(
            'Bookings',
            style: TextStyle(
              color: AppColors.offWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: bookingsState.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return const Center(
                    child: Text('No tickets booked yet.', style: TextStyle(color: AppColors.secondary)),
                  );
                }
                return ListView.separated(
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final user = booking['user'] ?? {};
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Text(
                              user['name']?[0] ?? '?',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['name'] ?? 'Unknown User', style: const TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.w600)),
                                Text(user['email'] ?? '', style: const TextStyle(color: AppColors.secondary, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              booking['status'] ?? 'VALID',
                              style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
              error: (err, stack) => const Center(
                child: Text('Failed to load bookings', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
