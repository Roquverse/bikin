import 'dart:io';
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

  Future<String?> uploadMedia(File file) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post('/media/upload', data: formData);
      return response.data['url'] as String;
    } catch (e) {
      LoggerUtil.error('Failed to upload media', e);
      return null;
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required String date,
    required String time,
    required String location,
    required String price,
    String? mediaUrl,
    List<Map<String, dynamic>>? tiers,
  }) async {
    try {
      final eventDate = DateTime.parse(date);
      
      final payload = {
        'title': title,
        'description': description,
        'date': eventDate.toIso8601String(),
        'location': location,
        'price': double.tryParse(price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0,
        if (mediaUrl != null) 'mediaUrl': mediaUrl,
        if (tiers != null) 'tiers': tiers,
      };

      final response = await _dio.post('/events', data: payload);
      return response.statusCode == 201;
    } catch (e) {
      LoggerUtil.error('Failed to create event', e);
      return false;
    }
  }
}

@riverpod
EventsRepository eventsRepository(Ref ref) {
  final apiClient = ref.watch(authApiClientProvider);
  return EventsRepository(apiClient.dio);
}
