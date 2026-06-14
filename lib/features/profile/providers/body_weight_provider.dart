import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database.dart';
import '../data/isar_body_weight_entry.dart';
import '../data/body_weight_repository.dart';

final bodyWeightRepositoryProvider = Provider<BodyWeightRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return BodyWeightRepository(isar);
});

class BodyWeightNotifier extends AsyncNotifier<List<IsarBodyWeightEntry>> {
  @override
  Future<List<IsarBodyWeightEntry>> build() async {
    return ref.read(bodyWeightRepositoryProvider).getWeightLogs();
  }

  Future<void> logWeight(double weight, {String? photoPath}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bodyWeightRepositoryProvider);
      await repo.logWeight(weight, DateTime.now(), photoPath: photoPath);
      return repo.getWeightLogs();
    });
  }

  Future<void> deleteLog(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(bodyWeightRepositoryProvider);
      await repo.deleteLog(id);
      return repo.getWeightLogs();
    });
  }
}

final bodyWeightProvider = AsyncNotifierProvider<BodyWeightNotifier, List<IsarBodyWeightEntry>>(() {
  return BodyWeightNotifier();
});
