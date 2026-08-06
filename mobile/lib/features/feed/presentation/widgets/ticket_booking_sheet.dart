import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/ticket_booking_provider.dart';

class TicketBookingSheet extends ConsumerStatefulWidget {
  final String videoId;

  const TicketBookingSheet({super.key, required this.videoId});

  @override
  ConsumerState<TicketBookingSheet> createState() => _TicketBookingSheetState();
}

class _TicketBookingSheetState extends ConsumerState<TicketBookingSheet> {
  bool _isBooking = false;
  String? _selectedTierId;

  void _handleBooking(double totalAmount) async {
    if (_selectedTierId == null) return;
    setState(() => _isBooking = true);
    try {
      // Book 1 ticket of the selected tier
      await ref.read(ticketBookingProvider(widget.videoId).notifier).bookTickets();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Tickets booked successfully!', style: TextStyle(color: AppColors.offWhite, fontWeight: FontWeight.bold)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isBooking = false);
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Booking Failed', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            content: Text(e.toString(), style: const TextStyle(color: AppColors.offWhite)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: AppColors.accentCta, fontWeight: FontWeight.bold)),
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

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0C241B).withAlpha(240),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.85,
            minChildSize: 0.6,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Handle indicator
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(80),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Event Info Header block (Mock info styled premium like mockup image 2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Eko Electronic Summer Pop-up',
                          style: TextStyle(
                            color: AppColors.offWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Landmark Beach, Lagos',
                              style: TextStyle(
                                color: AppColors.secondary.withAlpha(220),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 14, color: AppColors.secondary),
                            const SizedBox(width: 6),
                            Text(
                              'Saturday, Dec 23 · 8:00 PM',
                              style: TextStyle(
                                color: AppColors.secondary.withAlpha(220),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Select Tickets',
                      style: TextStyle(
                        color: AppColors.offWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tiers listing
                  Expanded(
                    child: tiersAsync.when(
                      data: (tiers) {
                        if (tiers.isEmpty) {
                          return const Center(
                            child: Text('No ticket tiers available', style: TextStyle(color: AppColors.offWhite)),
                          );
                        }

                        // Auto-select first tier if none is selected
                        if (_selectedTierId == null && tiers.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _selectedTierId = tiers.first.id;
                              ref.read(ticketBookingProvider(widget.videoId).notifier).increment(tiers.first.id, tiers.first.availableQuantity);
                            });
                          });
                        }

                        final selectedTier = tiers.firstWhere((t) => t.id == _selectedTierId, orElse: () => tiers.first);
                        final totalAmount = selectedTier.price;

                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                itemCount: tiers.length,
                                itemBuilder: (context, index) {
                                  final tier = tiers[index];
                                  final isSelected = _selectedTierId == tier.id;

                                  // Labels matching mockup tags
                                  String? tagLabel;
                                  Color tagBg = Colors.transparent;
                                  Color tagText = Colors.transparent;
                                  if (tier.name.toLowerCase().contains('regular')) {
                                    tagLabel = 'Selling fast';
                                    tagBg = const Color(0xFFFFBA00).withAlpha(30);
                                    tagText = const Color(0xFFFFBA00);
                                  } else if (tier.name.toLowerCase().contains('vip')) {
                                    tagLabel = 'Limited';
                                    tagBg = const Color(0xFF6D9773).withAlpha(30);
                                    tagText = const Color(0xFF6D9773);
                                  } else if (tier.name.toLowerCase().contains('table')) {
                                    tagLabel = '2 left';
                                    tagBg = const Color(0xFFE57373).withAlpha(30);
                                    tagText = const Color(0xFFE57373);
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() => _selectedTierId = tier.id);
                                      // Reset other selections, set selected tier to 1 qty
                                      final notifier = ref.read(ticketBookingProvider(widget.videoId).notifier);
                                      // Clear existing
                                      for (final t in tiers) {
                                        if (selections.containsKey(t.id)) {
                                          notifier.decrement(t.id);
                                        }
                                      }
                                      notifier.increment(tier.id, tier.availableQuantity);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(bottom: 16),
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.surfaceElevated.withAlpha(220)
                                            : AppColors.surfaceElevated.withAlpha(90),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.accentCta.withAlpha(180)
                                              : AppColors.secondary.withAlpha(30),
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    tier.name,
                                                    style: const TextStyle(
                                                      color: AppColors.offWhite,
                                                      fontSize: 15.5,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  if (tagLabel != null) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: tagBg,
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        tagLabel,
                                                        style: TextStyle(
                                                          color: tagText,
                                                          fontSize: 10,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '₦${tier.price.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  color: AppColors.offWhite,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Radio custom selector
                                          Container(
                                            width: 22,
                                            height: 22,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: isSelected ? AppColors.accentCta : AppColors.secondary.withAlpha(100),
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? Center(
                                                    child: Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: const BoxDecoration(
                                                        color: AppColors.accentCta,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // Total and action footer
                            Container(
                              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0C241B),
                                border: Border(top: BorderSide(color: AppColors.secondary.withAlpha(30))),
                              ),
                              child: SafeArea(
                                top: false,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'TOTAL',
                                          style: TextStyle(
                                            color: AppColors.secondary.withAlpha(200),
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '₦${totalAmount.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            color: AppColors.offWhite,
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () => _handleBooking(totalAmount),
                                      child: Container(
                                        height: 52,
                                        padding: const EdgeInsets.symmetric(horizontal: 28),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFBB8A52), Color(0xFFFFBA00)],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(26),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.accentCta.withAlpha(50),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            if (_isBooking)
                                              const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(color: AppColors.primaryBackground, strokeWidth: 2),
                                              )
                                            else ...[
                                              const Text(
                                                'Book Now',
                                                style: TextStyle(
                                                  color: AppColors.primaryBackground,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.primaryBackground),
                                            ],
                                          ],
                                        ),
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
              );
            },
          ),
        ),
      ),
    );
  }
}
