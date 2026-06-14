import 'package:isar/isar.dart';

part 'isar_body_weight_entry.g.dart';

@collection
class IsarBodyWeightEntry {
  Id id = Isar.autoIncrement;

  late DateTime date;
  late double weight;
  late String? photoPath; // Local file path for progress photo

  IsarBodyWeightEntry();
}
