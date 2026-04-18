import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Full local-storage service — all data persisted to SharedPreferences as JSON.
/// No static/hardcoded data returned to screens.
class StorageService {
  static const _keyWorkouts      = 'workouts_v2';
  static const _keyGoals         = 'goals_v2';
  static const _keyStreak        = 'streak_v2';
  static const _keyLastWorkout   = 'last_workout_date_v2';
  static const _keyPersonalBests = 'personal_bests_v1';

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

  // ── Streak ──────────────────────────────────────────────────────────────
  int getStreak() => _prefs.getInt(_keyStreak) ?? 0;
  Future<void> saveStreak(int s) => _prefs.setInt(_keyStreak, s);

  DateTime? getLastWorkoutDate() {
    final s = _prefs.getString(_keyLastWorkout);
    return s != null ? DateTime.tryParse(s) : null;
  }
  Future<void> saveLastWorkoutDate(DateTime d) =>
      _prefs.setString(_keyLastWorkout, d.toIso8601String());

  int updateStreakForToday() {
    final last  = getLastWorkoutDate();
    final today = DateTime.now();
    int streak  = getStreak();
    if (last == null) {
      streak = 1;
    } else {
      final todayDate = DateTime(today.year, today.month, today.day);
      final lastDate  = DateTime(last.year,  last.month,  last.day);
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 0) {
        // already logged today
      } else if (diff == 1) {
        streak++;
      } else {
        streak = 1;
      }
    }
    saveStreak(streak);
    saveLastWorkoutDate(today);
    return streak;
  }

  // ── Workout Sessions ────────────────────────────────────────────────────
  List<WorkoutSession> getWorkouts() {
    final raw = _prefs.getString(_keyWorkouts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((e) => WorkoutSession.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveWorkout(WorkoutSession session) async {
    final sessions = getWorkouts();
    final idx = sessions.indexWhere((s) => s.id == session.id);
    if (idx >= 0) {
      sessions[idx] = session;
    } else {
      sessions.insert(0, session);
    }
    await _prefs.setString(
        _keyWorkouts, jsonEncode(sessions.map((s) => s.toJson()).toList()));
    for (final ex in session.exercises) {
      for (final set in ex.sets) {
        await _updatePersonalBest(ex.name, set.weight);
      }
    }
  }

  Future<void> deleteWorkout(String id) async {
    final sessions = getWorkouts()..removeWhere((s) => s.id == id);
    await _prefs.setString(
        _keyWorkouts, jsonEncode(sessions.map((s) => s.toJson()).toList()));
  }

  // ── Personal Bests ──────────────────────────────────────────────────────
  Map<String, double> getPersonalBests() {
    final raw = _prefs.getString(_keyPersonalBests);
    if (raw == null || raw.isEmpty) return {};
    try {
      final Map<String, dynamic> map = jsonDecode(raw);
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    } catch (_) {
      return {};
    }
  }

  String? getPersonalBestDisplay(String exerciseName) {
    final bests = getPersonalBests();
    final key   = exerciseName.toLowerCase();
    final best  = bests[key];
    if (best == null || best == 0) return null;
    return '${best.truncateToDouble() == best ? best.toInt() : best.toStringAsFixed(1)}KG';
  }

  Future<void> _updatePersonalBest(String name, double weight) async {
    final bests = getPersonalBests();
    final key   = name.toLowerCase();
    if ((bests[key] ?? 0) < weight) {
      bests[key] = weight;
      await _prefs.setString(_keyPersonalBests, jsonEncode(bests));
    }
  }

  // ── Goals ───────────────────────────────────────────────────────────────
  List<Goal> getGoals() {
    final raw = _prefs.getString(_keyGoals);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((e) => Goal.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveGoal(Goal goal) async {
    final goals = getGoals();
    final idx   = goals.indexWhere((g) => g.id == goal.id);
    if (idx >= 0) {
      goals[idx] = goal;
    } else {
      goals.add(goal);
    }
    await _prefs.setString(
        _keyGoals, jsonEncode(goals.map((g) => g.toJson()).toList()));
  }

  Future<void> deleteGoal(String id) async {
    final goals = getGoals()..removeWhere((g) => g.id == id);
    await _prefs.setString(
        _keyGoals, jsonEncode(goals.map((g) => g.toJson()).toList()));
  }

  // ── Computed Stats (real data only) ─────────────────────────────────────
  double getTotalVolumeLifted() =>
      getWorkouts().fold(0.0, (sum, s) => sum + s.totalVolume);

  int getTotalWorkoutsThisMonth() {
    final now = DateTime.now();
    return getWorkouts()
        .where((s) => s.date.month == now.month && s.date.year == now.year)
        .length;
  }

  List<double> getWeeklyVolumeData() {
    final now          = DateTime.now();
    final startOfWeek  = now.subtract(Duration(days: now.weekday - 1));
    final result       = List<double>.filled(7, 0.0);
    for (final s in getWorkouts()) {
      final diff = s.date
          .difference(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day))
          .inDays;
      if (diff >= 0 && diff < 7) result[diff] += s.totalVolume / 1000;
    }
    return result;
  }

  int getWeeklyCompletionPercent() {
    const goal        = 4;
    final now         = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final thisWeek    = getWorkouts()
        .where((s) => s.date
            .isAfter(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
                .subtract(const Duration(seconds: 1))))
        .length;
    return ((thisWeek / goal) * 100).clamp(0, 100).toInt();
  }

  List<MapEntry<String, double>> getTopPRs({int limit = 3}) {
    final sorted = getPersonalBests().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).toList();
  }
}
