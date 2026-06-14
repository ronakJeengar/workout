import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/program.dart';
import 'program_repository.dart';

class LocalProgramRepository implements ProgramRepository {
  static const String _programsKey = 'programs_v1';
  static const int _currentSchemaVersion = 1;

  final SharedPreferences _prefs;

  LocalProgramRepository(this._prefs);

  @override
  Future<List<Program>> getPrograms() async {
    try {
      final String? data = _prefs.getString(_programsKey);
      if (data == null) return [];

      final Map<String, dynamic> envelope = jsonDecode(data);
      final List decoded = envelope['data'] as List;
      return decoded.map((p) => Program.fromJson(p as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> createProgram(Program program) async {
    final programs = await getPrograms();
    programs.add(program);
    await _savePrograms(programs);
  }

  @override
  Future<void> updateProgram(Program program) async {
    final programs = await getPrograms();
    final index = programs.indexWhere((p) => p.id == program.id);
    if (index != -1) {
      programs[index] = program;
      await _savePrograms(programs);
    }
  }

  @override
  Future<void> deleteProgram(String id) async {
    final programs = await getPrograms();
    programs.removeWhere((p) => p.id == id);
    await _savePrograms(programs);
  }

  Future<void> _savePrograms(List<Program> programs) async {
    final envelope = {
      'version': _currentSchemaVersion,
      'data': programs.map((p) => p.toJson()).toList(),
    };
    await _prefs.setString(_programsKey, jsonEncode(envelope));
  }
}
