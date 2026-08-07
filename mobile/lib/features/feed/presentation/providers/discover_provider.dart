import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/video_model.dart';
import '../../../../core/network/api_client.dart';

final discoverProvider = FutureProvider<List<VideoModel>>((ref) async {
  try {
    final response = await ApiClient.get('/feed/discover');
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => VideoModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load discover events');
    }
  } catch (e) {
    throw Exception('Failed to load discover events: $e');
  }
});
