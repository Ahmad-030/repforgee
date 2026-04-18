import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class WorkoutSet {
  double weight;
  int reps;
  int rpe;
  DateTime loggedAt;
  WorkoutSet({required this.weight, required this.reps, this.rpe = 8})
      : loggedAt = DateTime.now();
  double get volume => weight * reps;
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
  })  : id = id ?? _uuid.v4(),
        sets = sets ?? [];
  double get totalVolume => sets.fold(0, (s, e) => s + e.volume);
}

class WorkoutSession {
  final String id;
  DateTime date;
  String title;
  List<ExerciseLog> exercises;
  int durationSeconds;
  String? subtitle;
  WorkoutSession({
    String? id,
    required this.date,
    required this.title,
    required this.exercises,
    this.durationSeconds = 0,
    this.subtitle,
  }) : id = id ?? _uuid.v4();

  double get totalVolume => exercises.fold(0.0, (s, e) => s + e.totalVolume);
  int get totalSets => exercises.fold(0, (s, e) => s + e.sets.length);

  static List<WorkoutSession> sampleData() => [
        WorkoutSession(
          date: DateTime.now().subtract(const Duration(hours: 2)),
          title: 'HEAVY PULL DAY / HYPERTROPHY',
          subtitle: 'TODAY • 06:45 AM',
          durationSeconds: 72 * 60,
          exercises: [
            ExerciseLog(
              name: 'Deadlift',
              category: 'BACK',
              previousBest: '180KG PR',
              sets: [
                WorkoutSet(weight: 180, reps: 5, rpe: 9),
                WorkoutSet(weight: 180, reps: 5, rpe: 9),
                WorkoutSet(weight: 180, reps: 5, rpe: 9),
              ],
            )
          ],
        ),
        WorkoutSession(
          date: DateTime.now().subtract(const Duration(days: 2)),
          title: 'EXPLOSIVE PUSH / METCON',
          subtitle: 'OCT 22 • 05:30 PM',
          durationSeconds: 45 * 60,
          exercises: [
            ExerciseLog(name: 'Bench Press 85KG', category: 'CHEST', sets: [WorkoutSet(weight: 85, reps: 8)]),
            ExerciseLog(name: 'Overhead Press 60KG', category: 'SHOULDERS', sets: [WorkoutSet(weight: 60, reps: 8)]),
            ExerciseLog(name: 'Dips (Weighted)', category: 'ARMS', sets: [WorkoutSet(weight: 20, reps: 10)]),
          ],
        ),
        WorkoutSession(
          date: DateTime.now().subtract(const Duration(days: 4)),
          title: 'LOWER BODY / KINETIC CHAIN',
          subtitle: 'OCT 20 • 06:00 AM',
          durationSeconds: 85 * 60,
          exercises: [
            ExerciseLog(name: 'Squats', category: 'LEGS', sets: [WorkoutSet(weight: 180, reps: 5), WorkoutSet(weight: 180, reps: 5)]),
          ],
        ),
      ];
}

class Goal {
  final String id;
  String title;
  String subtitle;
  double target;
  double current;
  String unit;
  bool completed;
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

  static List<Goal> defaultGoals() => [
        Goal(title: 'STRENGTH THRESHOLD', subtitle: 'DEADLIFT 1RM GOAL', target: 250, current: 215, unit: 'KG'),
        Goal(title: 'BENCH PRESS VOLUME', subtitle: 'MONTHLY TARGET', target: 5000, current: 4200, unit: 'KG'),
        Goal(title: 'COMPOSITION', subtitle: 'BODY FAT TARGET', target: 100, current: 75, unit: '%'),
        Goal(title: 'ENDURANCE OPS', subtitle: '5KM SPRINT TIME', target: 100, current: 60, unit: '%'),
      ];
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

  static List<Achievement> defaultList() => const [
        Achievement(id: 'kinetic_pulse', title: 'KINETIC PULSE', description: 'Complete 5 workouts at 100% intensity', emoji: '⚡', earned: true),
        Achievement(id: 'steel_forged', title: 'STEEL FORGED', description: 'Lift a cumulative 10,000kg in one week', emoji: '🛡️', earned: true),
        Achievement(id: 'chronos', title: 'CHRONOS BREAKER', description: 'Beat 3 personal record times in sequence', emoji: '⏱️', earned: true),
        Achievement(id: 'alpha_lead', title: 'ALPHA LEAD', description: 'Reach Top 5 on regional leaderboard', emoji: '👥', earned: true),
        Achievement(id: 'ignition', title: 'IGNITION POINT', description: '30-day consistent workout streak', emoji: '🔥', earned: true),
        Achievement(id: 'unbroken', title: 'UNBROKEN SHELL', description: 'Zero missed goals for three months', emoji: '🔰', earned: true),
        Achievement(id: 'apex', title: 'APEX DESCENT', description: 'Surpass original strength goal by 25%', emoji: '🚀', earned: true),
        Achievement(id: 'void_walker', title: 'VOID WALKER', description: '75% — Keep going', emoji: '🔒', earned: false),
        Achievement(id: 'titan_core', title: 'TITAN CORE', description: 'Locked: Achieve Master Rank', emoji: '🔒', earned: false),
        Achievement(id: 'zero_gravity', title: 'ZERO GRAVITY', description: 'Locked: Complete 100 calisthenic reps', emoji: '🔒', earned: false),
        Achievement(id: 'solar_flare', title: 'SOLAR FLARE', description: 'Locked: 1000kcal in one session', emoji: '🔒', earned: false),
        Achievement(id: 'obsidian_king', title: 'OBSIDIAN KING', description: 'Locked: Ultimate Achievement', emoji: '🔒', earned: false),
      ];
}

class ExerciseLibrary {
  static const Map<String, List<String>> all = {
    'PULL DAY': ['Deadlift', 'Pull-ups', 'Barbell Row', 'Lat Pulldown', 'Seated Cable Row', 'Face Pulls', 'T-Bar Row'],
    'CHEST': ['Bench Press', 'Incline Bench', 'Decline Bench', 'Cable Flyes', 'Chest Dips', 'Push-ups'],
    'BACK': ['Pull-ups', 'Barbell Row', 'Lat Pulldown', 'T-Bar Row', 'Deadlift'],
    'LEGS': ['Squats', 'Leg Press', 'Romanian Deadlift', 'Leg Curl', 'Leg Extension', 'Calf Raises'],
    'ARMS': ['Barbell Curl', 'Hammer Curl', 'Tricep Pushdown', 'Skull Crushers', 'Preacher Curl'],
    'SHOULDERS': ['Overhead Press', 'Lateral Raises', 'Front Raises', 'Arnold Press', 'Shrugs'],
    'CORE': ['Plank', 'Crunches', 'Leg Raises', 'Russian Twists', 'Ab Wheel'],
  };
}
