import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class WorkoutSet {
  double weight;
  int    reps;
  int    rpe;
  DateTime loggedAt;

  WorkoutSet({required this.weight, required this.reps, this.rpe = 8})
      : loggedAt = DateTime.now();

  double get volume => weight * reps;

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'reps':   reps,
    'rpe':    rpe,
    'loggedAt': loggedAt.toIso8601String(),
  };

  factory WorkoutSet.fromJson(Map<String, dynamic> j) {
    final ws = WorkoutSet(
      weight: (j['weight'] as num).toDouble(),
      reps:   j['reps'] as int,
      rpe:    (j['rpe'] as int?) ?? 8,
    );
    ws.loggedAt = DateTime.tryParse(j['loggedAt'] as String? ?? '') ?? DateTime.now();
    return ws;
  }
}

class ExerciseLog {
  final String id;
  String name;
  String category;
  List<WorkoutSet> sets;
  String? previousBest;

  ExerciseLog({
    String? id,
    required this.name,
    required this.category,
    List<WorkoutSet>? sets,
    this.previousBest,
  })  : id   = id ?? _uuid.v4(),
        sets = sets ?? [];

  double get totalVolume => sets.fold(0, (s, e) => s + e.volume);

  Map<String, dynamic> toJson() => {
    'id':           id,
    'name':         name,
    'category':     category,
    'previousBest': previousBest,
    'sets':         sets.map((s) => s.toJson()).toList(),
  };

  factory ExerciseLog.fromJson(Map<String, dynamic> j) => ExerciseLog(
    id:           j['id'] as String,
    name:         j['name'] as String,
    category:     j['category'] as String,
    previousBest: j['previousBest'] as String?,
    sets:         (j['sets'] as List<dynamic>)
        .map((s) => WorkoutSet.fromJson(s as Map<String, dynamic>))
        .toList(),
  );
}

class WorkoutSession {
  final String id;
  DateTime     date;
  String       title;
  List<ExerciseLog> exercises;
  int          durationSeconds;
  String?      subtitle;

  WorkoutSession({
    String? id,
    required this.date,
    required this.title,
    required this.exercises,
    this.durationSeconds = 0,
    this.subtitle,
  }) : id = id ?? _uuid.v4();

  double get totalVolume => exercises.fold(0.0, (s, e) => s + e.totalVolume);
  int    get totalSets   => exercises.fold(0,   (s, e) => s + e.sets.length);

  Map<String, dynamic> toJson() => {
    'id':              id,
    'date':            date.toIso8601String(),
    'title':           title,
    'subtitle':        subtitle,
    'durationSeconds': durationSeconds,
    'exercises':       exercises.map((e) => e.toJson()).toList(),
  };

  factory WorkoutSession.fromJson(Map<String, dynamic> j) {
    final date = DateTime.tryParse(j['date'] as String? ?? '') ?? DateTime.now();
    return WorkoutSession(
      id:              j['id'] as String,
      date:            date,
      title:           j['title'] as String,
      subtitle:        j['subtitle'] as String?,
      durationSeconds: (j['durationSeconds'] as int?) ?? 0,
      exercises:       (j['exercises'] as List<dynamic>)
          .map((e) => ExerciseLog.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Human-readable subtitle: "TODAY • 06:45 AM" or "APR 12 • 09:30 AM"
  String get autoSubtitle {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date.year == now.year && date.month == now.month && date.day == now.day - 1;
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    if (isToday)     return 'TODAY • $timeStr';
    if (isYesterday) return 'YESTERDAY • $timeStr';
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return '${months[date.month - 1]} ${date.day} • $timeStr';
  }
}

class Goal {
  final String id;
  String  title;
  String  subtitle;
  double  target;
  double  current;
  String  unit;
  bool    completed;

  Goal({
    String? id,
    required this.title,
    required this.subtitle,
    required this.target,
    required this.current,
    required this.unit,
    this.completed = false,
  }) : id = id ?? _uuid.v4();

  double get progress => (current / target).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id':        id,
    'title':     title,
    'subtitle':  subtitle,
    'target':    target,
    'current':   current,
    'unit':      unit,
    'completed': completed,
  };

  factory Goal.fromJson(Map<String, dynamic> j) => Goal(
    id:        j['id'] as String,
    title:     j['title'] as String,
    subtitle:  j['subtitle'] as String,
    target:    (j['target'] as num).toDouble(),
    current:   (j['current'] as num).toDouble(),
    unit:      j['unit'] as String,
    completed: (j['completed'] as bool?) ?? false,
  );
}

class Achievement {
  final String id, title, description, emoji;
  final bool earned;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.earned = false,
  });

  static List<Achievement> buildFromStats({
    required int totalWorkouts,
    required double totalVolumeKg,
    required int streakDays,
    required int totalSets,
  }) {
    bool has(int threshold, int value) => value >= threshold;
    bool hasD(double threshold, double value) => value >= threshold;

    return [
      Achievement(
        id:          'first_rep',
        title:       'FIRST FORGE',
        description: 'Complete your first workout',
        emoji:       '🔥',
        earned:      totalWorkouts >= 1,
      ),
      Achievement(
        id:          'five_sessions',
        title:       'KINETIC PULSE',
        description: 'Complete 5 workouts',
        emoji:       '⚡',
        earned:      has(5, totalWorkouts),
      ),
      Achievement(
        id:          'ten_sessions',
        title:       'IRON FORGED',
        description: 'Complete 10 workouts',
        emoji:       '🛡️',
        earned:      has(10, totalWorkouts),
      ),
      Achievement(
        id:          'twenty_five',
        title:       'ALPHA LEAD',
        description: 'Complete 25 workouts',
        emoji:       '👥',
        earned:      has(25, totalWorkouts),
      ),
      Achievement(
        id:          'fifty',
        title:       'CHRONOS BREAKER',
        description: 'Complete 50 workouts',
        emoji:       '⏱️',
        earned:      has(50, totalWorkouts),
      ),
      Achievement(
        id:          'hundred',
        title:       'STEEL FORGED',
        description: 'Complete 100 workouts',
        emoji:       '🏆',
        earned:      has(100, totalWorkouts),
      ),
      Achievement(
        id:          'volume_10t',
        title:       'HEAVY CARRIER',
        description: 'Lift 10,000 kg total volume',
        emoji:       '💪',
        earned:      hasD(10000, totalVolumeKg),
      ),
      Achievement(
        id:          'volume_100t',
        title:       'TITAN CORE',
        description: 'Lift 100,000 kg total volume',
        emoji:       '🗿',
        earned:      hasD(100000, totalVolumeKg),
      ),
      Achievement(
        id:          'streak_7',
        title:       'IGNITION POINT',
        description: '7-day workout streak',
        emoji:       '🔥',
        earned:      has(7, streakDays),
      ),
      Achievement(
        id:          'streak_30',
        title:       'UNBROKEN SHELL',
        description: '30-day workout streak',
        emoji:       '🔰',
        earned:      has(30, streakDays),
      ),
      Achievement(
        id:          'sets_100',
        title:       'SET MACHINE',
        description: 'Log 100 total sets',
        emoji:       '🎯',
        earned:      has(100, totalSets),
      ),
      Achievement(
        id:          'sets_500',
        title:       'APEX DESCENT',
        description: 'Log 500 total sets',
        emoji:       '🚀',
        earned:      has(500, totalSets),
      ),
    ];
  }
}

class ExerciseLibrary {
  static const Map<String, List<String>> all = {
    'PULL DAY': ['Deadlift', 'Pull-ups', 'Barbell Row', 'Lat Pulldown', 'Seated Cable Row', 'Face Pulls', 'T-Bar Row'],
    'CHEST':    ['Bench Press', 'Incline Bench', 'Decline Bench', 'Cable Flyes', 'Chest Dips', 'Push-ups'],
    'BACK':     ['Pull-ups', 'Barbell Row', 'Lat Pulldown', 'T-Bar Row', 'Deadlift', 'Single-Arm Row'],
    'LEGS':     ['Squats', 'Leg Press', 'Romanian Deadlift', 'Leg Curl', 'Leg Extension', 'Calf Raises', 'Bulgarian Split Squat'],
    'ARMS':     ['Barbell Curl', 'Hammer Curl', 'Tricep Pushdown', 'Skull Crushers', 'Preacher Curl', 'Cable Curl', 'Dips'],
    'SHOULDERS':['Overhead Press', 'Lateral Raises', 'Front Raises', 'Arnold Press', 'Shrugs', 'Face Pulls', 'Rear Delt Fly'],
    'CORE':     ['Plank', 'Crunches', 'Leg Raises', 'Russian Twists', 'Ab Wheel', 'Hanging Knee Raise', 'Cable Crunch'],
  };
}
