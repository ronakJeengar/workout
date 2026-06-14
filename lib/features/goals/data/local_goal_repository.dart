import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/goal.dart';
import 'goal_repository.dart';

class LocalGoalRepository implements GoalRepository {
  static const String _goalsKey = 'goals_v1';
  static const String _achievementsKey = 'achievements_v1';
  static const int _currentSchemaVersion = 1;

  final SharedPreferences _prefs;

  LocalGoalRepository(this._prefs);

  @override
  Future<List<Goal>> getGoals() async {
    try {
      final String? data = _prefs.getString(_goalsKey);
      if (data == null) return [];
      final Map<String, dynamic> envelope = jsonDecode(data);
      final List decoded = envelope['data'] as List;
      return decoded.map((g) => Goal.fromJson(g as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveGoal(Goal goal) async {
    final goals = await getGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = goal;
    } else {
      goals.add(goal);
    }
    await _saveGoalsList(goals);
  }

  @override
  Future<void> deleteGoal(String id) async {
    final goals = await getGoals();
    goals.removeWhere((g) => g.id == id);
    await _saveGoalsList(goals);
  }

  @override
  Future<List<Achievement>> getAchievements() async {
    try {
      final String? data = _prefs.getString(_achievementsKey);
      if (data == null) return _getDefaultAchievements();
      final Map<String, dynamic> envelope = jsonDecode(data);
      final List decoded = envelope['data'] as List;
      return decoded.map((a) => Achievement.fromJson(a as Map<String, dynamic>)).toList();
    } catch (e) {
      return _getDefaultAchievements();
    }
  }

  @override
  Future<void> saveAchievement(Achievement achievement) async {
    final achievements = await getAchievements();
    final index = achievements.indexWhere((a) => a.id == achievement.id);
    if (index != -1) {
      achievements[index] = achievement;
      await _saveAchievementsList(achievements);
    }
  }

  Future<void> _saveGoalsList(List<Goal> goals) async {
    final envelope = {
      'version': _currentSchemaVersion,
      'data': goals.map((g) => g.toJson()).toList(),
    };
    await _prefs.setString(_goalsKey, jsonEncode(envelope));
  }

  Future<void> _saveAchievementsList(List<Achievement> achievements) async {
    final envelope = {
      'version': _currentSchemaVersion,
      'data': achievements.map((a) => a.toJson()).toList(),
    };
    await _prefs.setString(_achievementsKey, jsonEncode(envelope));
  }

  List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(id: 'first_workout', title: 'First Workout', description: 'Complete your first session', iconData: Icons.fitness_center.codePoint),
      Achievement(id: 'streak_7', title: '7 Day Streak', description: 'Train 7 days in a row', iconData: Icons.local_fire_department.codePoint),
      Achievement(id: 'sets_50', title: '50 Sets', description: 'Log 50 total sets', iconData: Icons.layers.codePoint),
      Achievement(id: 'sessions_100', title: '100 Sessions', description: 'Log 100 total sessions', iconData: Icons.emoji_events.codePoint),
      Achievement(id: 'first_program', title: 'First Program', description: 'Start a training program', iconData: Icons.assignment.codePoint),
      Achievement(id: 'pr_10', title: '10 Personal Records', description: 'Break 10 personal records', iconData: Icons.star.codePoint),
      Achievement(id: 'consistency_master', title: 'Consistency Master', description: 'Maintain a 80% monthly score', iconData: Icons.verified.codePoint),
    ];
  }
}
