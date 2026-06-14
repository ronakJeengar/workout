import '../domain/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getGoals();
  Future<void> saveGoal(Goal goal);
  Future<void> deleteGoal(String id);
  Future<List<Achievement>> getAchievements();
  Future<void> saveAchievement(Achievement achievement);
}
