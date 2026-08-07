import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../profile/data/repositories/profile_repository.dart';

part 'my_tickets_provider.g.dart';

@riverpod
Future<List<dynamic>> myTickets(Ref ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getUserTickets();
}
