import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../auth/data/api/auth_api_client.dart';
import '../../../../core/utils/logger_util.dart';

part 'events_repository.g.dart';

class EventsRepository {
  final Dio _dio;

  EventsRepository(this._dio);

  Future<List<dynamic>> getEventBookings(String eventId) async {
    try {
      final response = await _dio.get('/events/$eventId/bookings');
      return response.data;
    } catch (e) {
      LoggerUtil.error('Failed to get event bookings', e);
      return [];
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      await _dio.delete('/events/$eventId');
      return true;
    } catch (e) {
      LoggerUtil.error('Failed to delete event', e);
      return false;
    }
  }
}

@riverpod
EventsRepository eventsRepository(Ref ref) {
  final apiClient = ref.watch(authApiClientProvider);
  return EventsRepository(apiClient.dio);
}
