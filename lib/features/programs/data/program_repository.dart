import '../domain/program.dart';

abstract class ProgramRepository {
  Future<List<Program>> getPrograms();
  Future<void> createProgram(Program program);
  Future<void> updateProgram(Program program);
  Future<void> deleteProgram(String id);
}
