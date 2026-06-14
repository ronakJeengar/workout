import 'package:isar/isar.dart';
import 'isar_body_weight_entry.dart';

class BodyWeightRepository {
  final Isar _isar;

  BodyWeightRepository(this._isar);

  Future<List<IsarBodyWeightEntry>> getWeightLogs() async {
    return _isar.isarBodyWeightEntrys.where().sortByDateDesc().findAll();
  }

  Future<void> logWeight(double weight, DateTime date, {String? photoPath}) async {
    final entry = IsarBodyWeightEntry()
      ..weight = weight
      ..date = date
      ..photoPath = photoPath;
    await _isar.writeTxn(() async {
      await _isar.isarBodyWeightEntrys.put(entry);
    });
  }

  Future<void> deleteLog(int id) async {
    await _isar.writeTxn(() async {
      await _isar.isarBodyWeightEntrys.delete(id);
    });
  }
}
