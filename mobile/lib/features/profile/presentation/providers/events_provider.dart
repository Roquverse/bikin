import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/events_repository.dart';

part 'events_provider.g.dart';

@riverpod
class EventBookings extends _$EventBookings {
  @override
  FutureOr<List<dynamic>> build(String eventId) async {
    return ref.watch(eventsRepositoryProvider).getEventBookings(eventId);
  }
}
