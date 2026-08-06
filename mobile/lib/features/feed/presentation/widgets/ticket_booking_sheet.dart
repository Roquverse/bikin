import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/buttons/primary_button.dart';
import '../providers/ticket_booking_provider.dart';

class TicketBookingSheet extends ConsumerStatefulWidget {
  final String videoId;

  const TicketBookingSheet({super.key, required this.videoId});

  @override
  ConsumerState<TicketBookingSheet> createState() => _TicketBookingSheetState();
}

class _TicketBookingSheetState extends ConsumerState<TicketBookingSheet> {
  bool _isBooking = false;

  void _handleBooking() async {
    setState(() => _isBooking = true);
    try {
      await ref.read(ticketBookingProvider(widget.videoId).notifier).bookTickets();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tickets booked successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBooking = false);
        // Display inline error state
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            title: const Text('Booking Failed', style: TextStyle(color: AppColors.error)),
            content: Text(e.toString(), style: const TextStyle(color: AppColors.offWhite)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: AppColors.accentCta)),
              )
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiersAsync = ref.watch(ticketTiersProvider(widget.videoId));
    final selections = ref.watch(ticketBookingProvider(widget.videoId));
    final totalItems = ref.watch(ticketBookingProvider(widget.videoId).notifier).totalItems;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.tertiaryNeutral,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Tickets',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.offWhite,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: tiersAsync.when(
                  data: (tiers) {
                    final totalAmount = ref.watch(ticketBookingProvider(widget.videoId).notifier).calculateTotal(tiers);
                    return Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(24),
                            itemCount: tiers.length,
                            separatorBuilder: (_, __) => const Divider(color: AppColors.tertiaryNeutral),
                            itemBuilder: (context, index) {
                              final tier = tiers[index];
                              final currentQty = selections[tier.id] ?? 0;
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          tier.name,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.offWhite,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₦${tier.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: AppColors.accentCta,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: currentQty > 0
                                            ? () => ref.read(ticketBookingProvider(widget.videoId).notifier).decrement(tier.id)
                                            : null,
                                        icon: const Icon(Icons.remove_circle_outline),
                                        color: currentQty > 0 ? AppColors.offWhite : AppColors.tertiaryNeutral,
                                      ),
                                      SizedBox(
                                        width: 32,
                                        child: Text(
                                          currentQty.toString(),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.offWhite,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: currentQty < tier.availableQuantity
                                            ? () => ref.read(ticketBookingProvider(widget.videoId).notifier).increment(tier.id, tier.availableQuantity)
                                            : null,
                                        icon: const Icon(Icons.add_circle_outline),
                                        color: currentQty < tier.availableQuantity ? AppColors.accentCta : AppColors.tertiaryNeutral,
                                      ),
                                    ],
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBackground,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              )
                            ],
                          ),
                          child: SafeArea(
                            top: false,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Total ($totalItems items)',
                                        style: TextStyle(
                                          color: AppColors.offWhite.withOpacity(0.7),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '₦${totalAmount.toStringAsFixed(0)}',
                                        style: const TextStyle(
                                          color: AppColors.accentCta,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 140,
                                  child: PrimaryButton(
                                    text: 'Book Now',
                                    isLoading: _isBooking,
                                    onPressed: totalItems > 0 ? _handleBooking : null,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCta)),
                  error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
