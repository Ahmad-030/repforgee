import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Manages the active workout session state.
/// Shared across the WorkoutScreen and its sub-widgets.
class WorkoutState extends ChangeNotifier {
  // Timer
  int _seconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  // Session data
  String _sessionTitle = 'WORKOUT SESSION';
  final List<ExerciseLog> _exercises = [];
  double _totalVolume = 0;

  // Getters
  int get seconds => _seconds;
  bool get isRunning => _isRunning;
  String get sessionTitle => _sessionTitle;
  List<ExerciseLog> get exercises => List.unmodifiable(_exercises);
  double get totalVolume => _totalVolume;
  bool get hasExercises => _exercises.isNotEmpty;

  String get timerDisplay {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Timer Controls ────────────────────────────────────────────────────────

  void startTimer() {
    if (_isRunning) return;
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _seconds++;
      notifyListeners();
    });
    notifyListeners();
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    _isRunning = false;
    _seconds = 0;
    notifyListeners();
  }

  // ── Exercises ─────────────────────────────────────────────────────────────

  void addExercise(String name, String category) {
    _exercises.add(ExerciseLog(
      name: name,
      category: category,
      previousBest: _getPreviousBest(name),
    ));
    notifyListeners();
  }

  void removeExercise(String id) {
    _exercises.removeWhere((e) => e.id == id);
    _recalcVolume();
    notifyListeners();
  }

  void logSet(String exerciseId, WorkoutSet set) {
    final ex = _exercises.firstWhere((e) => e.id == exerciseId);
    ex.sets.add(set);
    _totalVolume += set.volume;
    notifyListeners();
  }

  void _recalcVolume() {
    _totalVolume = _exercises.fold(0, (sum, e) => sum + e.totalVolume);
  }

  String? _getPreviousBest(String name) {
    // In production, look up from StorageService
    const bests = {
      'Deadlift': '180KG',
      'Bench Press': '100KG',
      'Squats': '160KG',
      'Overhead Press': '80KG',
    };
    return bests[name];
  }

  // ── Finish Session ────────────────────────────────────────────────────────

  WorkoutSession finishSession() {
    pauseTimer();
    final session = WorkoutSession(
      date: DateTime.now(),
      title: _sessionTitle.toUpperCase(),
      exercises: List.from(_exercises),
      durationSeconds: _seconds,
    );
    _reset();
    return session;
  }

  void _reset() {
    _seconds = 0;
    _isRunning = false;
    _exercises.clear();
    _totalVolume = 0;
    _sessionTitle = 'WORKOUT SESSION';
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
