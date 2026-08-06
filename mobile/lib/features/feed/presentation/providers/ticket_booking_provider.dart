import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/ticket_tier_model.dart';
import '../../data/feed_repository.dart';

part 'ticket_booking_provider.g.dart';

@riverpod
class TicketTiers extends _$TicketTiers {
  @override
  FutureOr<List<TicketTierModel>> build(String videoId) async {
    return ref.watch(feedRepositoryProvider).getTicketTiers(videoId);
  }
}

@riverpod
class TicketBooking extends _$TicketBooking {
  @override
  Map<String, int> build(String videoId) {
    return {};
  }

  void increment(String tierId, int maxAvailable) {
    final current = state[tierId] ?? 0;
    if (current < maxAvailable) {
      state = {...state, tierId: current + 1};
      HapticFeedback.lightImpact();
    }
  }

  void decrement(String tierId) {
    final current = state[tierId] ?? 0;
    if (current > 0) {
      final newState = {...state};
      if (current - 1 == 0) {
        newState.remove(tierId);
      } else {
        newState[tierId] = current - 1;
      }
      state = newState;
      HapticFeedback.lightImpact();
    }
  }

  double calculateTotal(List<TicketTierModel> tiers) {
    double total = 0;
    for (final tier in tiers) {
      total += tier.price * (state[tier.id] ?? 0);
    }
    return total;
  }
  
  int get totalItems {
    return state.values.fold(0, (sum, val) => sum + val);
  }

  Future<void> bookTickets() async {
    if (state.isEmpty) return;
    
    // Will throw exception if failed (simulated sold out)
    await ref.read(feedRepositoryProvider).bookTickets(videoId, state);
  }
}
