import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/feed_repository.dart';

part 'location_provider.g.dart';

@riverpod
class SelectedLocation extends _$SelectedLocation {
  @override
  String build() {
    return 'All';
  }

  void setLocation(String location) {
    state = location;
  }
}

@riverpod
Future<List<String>> availableLocations(AvailableLocationsRef ref) async {
  final locations = await ref.read(feedRepositoryProvider).getLocations();
  return ['All', ...locations];
}
