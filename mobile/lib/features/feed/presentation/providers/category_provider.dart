import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/feed_repository.dart';

part 'category_provider.g.dart';

@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() {
    return 'All';
  }

  void setCategory(String category) {
    state = category;
  }
}

@riverpod
Future<List<String>> availableCategories(AvailableCategoriesRef ref) async {
  final categories = await ref.read(feedRepositoryProvider).getCategories();
  return ['All', ...categories];
}
