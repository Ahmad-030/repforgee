import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Lightweight local storage service.
/// Stores all data as JSON in SharedPreferences — fully offline, no login.
class StorageService {
  static const _keyWorkouts   = 'workouts_v1';
  static const _keyGoals      = 'goals_v1';
  static const _keyStreak     = 'streak_v1';
  static const _keyLastWorkout= 'last_workout_date_v1';

  static StorageService? _instance;
  late SharedPreferences _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _instance!._prefs = await SharedPreferences.getInstance();
    }
    return _instance!;
  }

  // ── Streak ────────────────────────────────────────────────────────────────

  int getStreak() => _prefs.getInt(_keyStreak) ?? 12;

  Future<void> saveStreak(int streak) => _prefs.setInt(_keyStreak, streak);

  DateTime? getLastWorkoutDate() {
    final s = _prefs.getString(_keyLastWorkout);
    return s != null ? DateTime.tryParse(s) : null;
  }

  Future<void> saveLastWorkoutDate(DateTime date) =>
      _prefs.setString(_keyLastWorkout, date.toIso8601String());

  /// Returns updated streak after logging a workout today.
  int updateStreakForToday() {
    final last = getLastWorkoutDate();
    final today = DateTime.now();
    int streak = getStreak();

    if (last == null) {
      streak = 1;
    } else {
      final diff = today.difference(last).inDays;
      if (diff == 0) {
        // Already worked out today — no change
      } else if (diff == 1) {
        streak += 1; // Consecutive day
      } else {
        streak = 1; // Streak broken
      }
    }

    saveStreak(streak);
    saveLastWorkoutDate(today);
    return streak;
  }

  // ── Workout Sessions ──────────────────────────────────────────────────────

  List<WorkoutSession> getWorkouts() {
    // Return sample data for demo — in production this reads from JSON
    return WorkoutSession.sampleData();
  }

  // ── Goals ─────────────────────────────────────────────────────────────────

  List<Goal> getGoals() => Goal.defaultGoals();

  // ── Total Volume ──────────────────────────────────────────────────────────

  double getTotalVolumeLifted() {
    final sessions = getWorkouts();
    return sessions.fold(0.0, (sum, s) => sum + s.totalVolume);
  }

  int getTotalWorkoutsThisMonth() {
    final sessions = getWorkouts();
    final now = DateTime.now();
    return sessions.where((s) => s.date.month == now.month && s.date.year == now.year).length;
  }
}
