import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import '../widgets/exercise_card.dart';
import '../widgets/exercise_picker_sheet.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Timer
  int    _seconds      = 0;
  Timer? _timer;
  bool   _timerRunning = false;

  double _totalVolume = 0;
  final List<ExerciseLog> _exercises = [];

  StorageService? _storage;
  String _selectedCategory = 'PULL DAY';

  String get _timerStr {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    super.initState();
    _initStorage();
    // Timer does NOT auto-start — user presses START
  }

  Future<void> _initStorage() async {
    _storage = await StorageService.getInstance();
    setState(() {});
  }

  void _toggleTimer() {
    setState(() {
      if (_timerRunning) {
        _timer?.cancel();
        _timerRunning = false;
      } else {
        _timerRunning = true;
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() => _seconds++);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _openExercisePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExercisePickerSheet(
        onSelected: (name, category) {
          final pr = _storage?.getPersonalBestDisplay(name);
          setState(() {
            _exercises.add(ExerciseLog(
              name: name.toUpperCase(),
              category: category,
              previousBest: pr,
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$name ADDED',
                style: GoogleFonts.spaceMono(color: AppTheme.bg, fontSize: 10, letterSpacing: 1)),
            backgroundColor: AppTheme.neonGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        },
      ),
    );
  }

  void _finishSession() {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('ADD AT LEAST ONE EXERCISE',
            style: GoogleFonts.spaceMono(color: AppTheme.bg, fontSize: 10, letterSpacing: 1)),
        backgroundColor: AppTheme.neonPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        title: Text('FINISH SESSION?', style: GoogleFonts.barlow(
          color: AppTheme.primary, fontSize: 20,
          fontWeight: FontWeight.w900, letterSpacing: 2,
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: $_timerStr', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Volume: ${(_totalVolume / 1000).toStringAsFixed(1)}t',
                style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Exercises: ${_exercises.length}',
                style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Total sets: ${_exercises.fold(0, (s, e) => s + e.sets.length)}',
                style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 10)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreen, foregroundColor: AppTheme.bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _saveAndNavigate();
            },
            child: Text('FINISH', style: GoogleFonts.barlow(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndNavigate() async {
    if (_storage == null) return;
    _timer?.cancel();

    final now   = DateTime.now();
    final title = _buildSessionTitle();
    final session = WorkoutSession(
      date:            now,
      title:           title,
      exercises:       List.from(_exercises),
      durationSeconds: _seconds,
    );

    await _storage!.saveWorkout(session);
    _storage!.updateStreakForToday();

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/history');
    }
  }

  String _buildSessionTitle() {
    final cats = _exercises.map((e) => e.category).toSet();
    if (cats.length == 1) return '${cats.first} SESSION';
    if (cats.contains('PULL DAY') || cats.contains('BACK')) {
      return 'PULL DAY / HYPERTROPHY';
    }
    if (cats.contains('CHEST')) return 'PUSH DAY SESSION';
    if (cats.contains('LEGS'))  return 'LOWER BODY SESSION';
    return 'FULL BODY SESSION';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      drawer: const RepForgeDrawer(),
      body: CustomScrollView(
        slivers: [
          repForgeAppBar(context),

          SliverToBoxAdapter(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionHeader(),
              const SizedBox(height: 16),

              // Search / exercise picker
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _openExercisePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(children: [
                      const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                      const SizedBox(width: 10),
                      Text('SEARCH EXERCISE OR MUSCLE GROUP...', style: GoogleFonts.spaceMono(
                        color: AppTheme.textDim, fontSize: 10, letterSpacing: 0.5,
                      )),
                    ]),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ),

              const SizedBox(height: 14),
              _buildCategoryChips(),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(children: [
                  Text('CURRENT SET', style: GoogleFonts.barlow(
                    color: AppTheme.primary, fontSize: 22,
                    fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                  )),
                  const SizedBox(width: 10),
                  Container(width: 48, height: 2, color: AppTheme.neonGreen),
                  const Spacer(),
                  if (_exercises.isNotEmpty && _exercises.first.previousBest != null)
                    Row(children: [
                      Icon(Icons.history, color: AppTheme.neonBlue, size: 12),
                      const SizedBox(width: 4),
                      Text('PREV BEST: ${_exercises.first.previousBest}',
                          style: GoogleFonts.spaceMono(color: AppTheme.neonBlue, fontSize: 8, letterSpacing: 0.5)),
                    ]),
                ]),
              ),

              const SizedBox(height: 12),

              ..._exercises.map((ex) => ExerciseCard(
                key: ValueKey(ex.id),
                exercise: ex,
                onSetLogged: (set) => setState(() {
                  ex.sets.add(set);
                  _totalVolume += set.volume;
                }),
                onRemove: () => setState(() {
                  _totalVolume -= ex.totalVolume;
                  _exercises.removeWhere((e) => e.id == ex.id);
                }),
              )),

              // Empty state
              if (_exercises.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(children: [
                    Icon(Icons.fitness_center, color: AppTheme.textDim, size: 48),
                    const SizedBox(height: 12),
                    Text('NO EXERCISES YET', style: GoogleFonts.barlow(
                      color: AppTheme.textDim, fontSize: 16, fontWeight: FontWeight.w800,
                    )),
                    const SizedBox(height: 4),
                    Text('Tap "ADD EXERCISE" or use Quick Log below',
                      style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),

              // Add Exercise button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.neonGreen,
                    side: const BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('ADD EXERCISE', style: GoogleFonts.spaceMono(
                    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2,
                  )),
                  onPressed: _openExercisePicker,
                ).animate().fadeIn(duration: 300.ms),
              ),

              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('QUICK LOG', style: GoogleFonts.spaceMono(
                  color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2,
                )),
              ),
              const SizedBox(height: 10),
              _buildQuickLogChips(),
              const SizedBox(height: 100),
            ],
          )),
        ],
      ),

      floatingActionButton: GestureDetector(
        onTap: _finishSession,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.neonPink,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: AppTheme.neonPink.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('FINISH SESSION', style: GoogleFonts.barlow(
                color: Colors.white, fontSize: 14,
                fontWeight: FontWeight.w900, letterSpacing: 2,
              )),
            ],
          ),
        ),
      ).animate().slideY(begin: 0.5, delay: 800.ms).fadeIn(delay: 800.ms),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      bottomNavigationBar: const RepForgeNavBar(currentIndex: 0),
    );
  }

  Widget _buildSessionHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.25)),
        boxShadow: [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.04), blurRadius: 24)],
      ),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('ACTIVE SESSION', style: GoogleFonts.spaceMono(
            color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1.5,
          )),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Text(_timerStr, style: GoogleFonts.barlow(
              color: _timerRunning ? AppTheme.neonGreen : AppTheme.textDim,
              fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 2, height: 1,
            )),
            const SizedBox(width: 10),
            // ── START / PAUSE button ────────────────────────────
            GestureDetector(
              onTap: _toggleTimer,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _timerRunning
                      ? AppTheme.neonPink.withOpacity(0.15)
                      : AppTheme.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _timerRunning ? AppTheme.neonPink : AppTheme.neonGreen,
                    width: 1,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    _timerRunning ? Icons.pause : Icons.play_arrow,
                    color: _timerRunning ? AppTheme.neonPink : AppTheme.neonGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _timerRunning ? 'PAUSE' : 'START',
                    style: GoogleFonts.spaceMono(
                      color: _timerRunning ? AppTheme.neonPink : AppTheme.neonGreen,
                      fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1,
                    ),
                  ),
                ]),
              ),
            ),
          ]),
        ]),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('VOLUME', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(
            _totalVolume >= 1000
                ? '${(_totalVolume / 1000).toStringAsFixed(1)}t'
                : '${_totalVolume.toInt()}kg',
            style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ]),
        const SizedBox(width: 20),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('SETS', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1.5)),
          const SizedBox(height: 4),
          Text(
            '${_exercises.fold(0, (s, e) => s + e.sets.length)}',
            style: GoogleFonts.barlow(color: AppTheme.neonBlue, fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ]),
      ]),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.08);
  }

  Widget _buildCategoryChips() {
    final cats = ExerciseLibrary.all.keys.toList();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final cat = cats[i];
          final sel = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: 200.ms,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: sel ? AppTheme.neonGreen : AppTheme.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: sel ? AppTheme.neonGreen : AppTheme.border),
              ),
              child: Text(cat, style: GoogleFonts.spaceMono(
                color: sel ? AppTheme.bg : AppTheme.textMuted,
                fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
              )),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickLogChips() {
    final quickItems = [
      ('💪 PUSHUPS', 'Pushups', 'BODY'),
      ('🏃 RUNNING', 'Running', 'CARDIO'),
      ('⏱️ PLANK', 'Plank', 'CORE'),
      ('🔝 PULL-UPS', 'Pull-ups', 'BACK'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: quickItems.map((item) => GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _exercises.add(ExerciseLog(name: item.$2.toUpperCase(), category: item.$3));
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('⚡ ${item.$2} ADDED',
                  style: GoogleFonts.spaceMono(color: AppTheme.bg, fontSize: 10)),
              backgroundColor: AppTheme.neonBlue,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(item.$1, style: GoogleFonts.spaceMono(
              color: AppTheme.textMuted, fontSize: 10, letterSpacing: 0.5,
            )),
          ),
        )).toList(),
      ),
    );
  }
}