import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../feed/domain/models/video_model.dart';

part 'profile_provider.g.dart';

@riverpod
class UserEvents extends _$UserEvents {
  @override
  FutureOr<List<VideoModel>> build() async {
    return ref.watch(profileRepositoryProvider).getUserEvents();
  }
}

@riverpod
class UserStats extends _$UserStats {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    return ref.watch(profileRepositoryProvider).getUserStats();
  }
}

@riverpod
class UserTickets extends _$UserTickets {
  @override
  FutureOr<List<dynamic>> build() async {
    return ref.watch(profileRepositoryProvider).getUserTickets();
  }
}
