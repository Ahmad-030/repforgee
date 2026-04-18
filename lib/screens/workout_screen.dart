import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
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
  int _seconds = 42 * 60 + 18;
  Timer? _timer;
  bool _timerRunning = true;

  // Session data
  double _totalVolume = 12450;
  final int _bpm = 144;
  final List<ExerciseLog> _exercises = [];

  String get _timerStr {
    final m = (_seconds ~/ 60).toString().padLeft(2, '0');
    final s = (_seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Add default exercise for demo
    _exercises.add(ExerciseLog(
      name: 'BARBELL DEADLIFT',
      category: 'PULL DAY',
      previousBest: '120KG',
      sets: [
        WorkoutSet(weight: 80, reps: 12, rpe: 7),
        WorkoutSet(weight: 90, reps: 10, rpe: 8),
      ],
    ));
  }

  void _startTimer() {
    _timerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
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
          setState(() {
            _exercises.add(ExerciseLog(
              name: name.toUpperCase(),
              category: category,
              previousBest: _getPreviousBest(name),
            ));
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('$name ADDED', style: GoogleFonts.spaceMono(color: AppTheme.bg, fontSize: 10, letterSpacing: 1)),
            backgroundColor: AppTheme.neonGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ));
        },
      ),
    );
  }

  String? _getPreviousBest(String name) {
    const bests = {'Deadlift': '180KG', 'Bench Press': '100KG', 'Squats': '160KG'};
    return bests[name];
  }

  void _finishSession() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
        title: Text('FINISH SESSION?', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 2)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Duration: $_timerStr', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Total volume: ${_totalVolume.toInt()}kg', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 4),
            Text('Exercises: ${_exercises.length}', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 10))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonGreen, foregroundColor: AppTheme.bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/history');
            },
            child: Text('FINISH', style: GoogleFonts.barlow(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bg,
            automaticallyImplyLeading: false,
            elevation: 0,
            title: Row(
              children: [
                const Icon(Icons.menu, color: AppTheme.textMuted, size: 22),
                const SizedBox(width: 12),
                Text('REPFORGE', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
                const Spacer(),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
                  child: const Icon(Icons.person, color: AppTheme.textMuted, size: 20),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Session header ─────────────────────────────────────────
              _buildSessionHeader(),
              const SizedBox(height: 16),

              // ── Search bar ─────────────────────────────────────────────
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
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                        const SizedBox(width: 10),
                        Text('SEARCH EXERCISE OR MUSCLE GROUP...', style: GoogleFonts.spaceMono(
                          color: AppTheme.textDim, fontSize: 10, letterSpacing: 0.5,
                        )),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ),

              const SizedBox(height: 14),

              // ── Category chips ─────────────────────────────────────────
              _buildCategoryChips(),

              const SizedBox(height: 20),

              // ── Current Set label ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text('CURRENT SET', style: GoogleFonts.barlow(
                      color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w900, fontStyle: FontStyle.italic,
                    )),
                    const SizedBox(width: 10),
                    Container(width: 48, height: 2, color: AppTheme.neonGreen),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.history, color: AppTheme.neonBlue, size: 12),
                        const SizedBox(width: 4),
                        Text('PREVIOUS BEST: 120KG', style: GoogleFonts.spaceMono(color: AppTheme.neonBlue, fontSize: 8, letterSpacing: 0.5)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Exercise cards ─────────────────────────────────────────
              ..._exercises.map((ex) => ExerciseCard(
                key: ValueKey(ex.id),
                exercise: ex,
                onSetLogged: (set) => setState(() {
                  ex.sets.add(set);
                  _totalVolume += set.volume;
                }),
                onRemove: () => setState(() => _exercises.removeWhere((e) => e.id == ex.id)),
              )),

              // ── Add Exercise button ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
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

              // ── Quick log chips ────────────────────────────────────────
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text('QUICK LOG', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2)),
              ),
              const SizedBox(height: 10),
              _buildQuickLogChips(),

              const SizedBox(height: 100),
            ],
          )),
        ],
      ),

      // Finish session FAB
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
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2,
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
      child: Row(
        children: [
          // Timer
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACTIVE SESSION', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text(_timerStr, style: GoogleFonts.barlow(
                color: AppTheme.neonGreen, fontSize: 38, fontWeight: FontWeight.w900, letterSpacing: 2, height: 1,
              )),
            ],
          ),
          const Spacer(),
          // Volume
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('VOLUME', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Text('${(_totalVolume / 1000).toStringAsFixed(1).replaceAll('.', ',')}', style: GoogleFonts.barlow(
                color: AppTheme.primary, fontSize: 22, fontWeight: FontWeight.w800,
              )),
              Text('KG', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9)),
            ],
          ),
          const SizedBox(width: 20),
          // BPM
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('BPM', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.favorite, color: AppTheme.neonPink, size: 14),
                  const SizedBox(width: 4),
                  Text('$_bpm', style: GoogleFonts.barlow(
                    color: AppTheme.neonPink, fontSize: 22, fontWeight: FontWeight.w800,
                  )),
                ],
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.08);
  }

  String _selectedCategory = 'PULL DAY';

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
      ('💪 PUSHUPS', 'Pushups', '30 REPS'),
      ('🏃 RUNNING', 'Running', '10 MIN'),
      ('⏱️ PLANK', 'Plank', '60 SEC'),
      ('🔝 PULL-UPS', 'Pull-ups', '12 REPS'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: quickItems.map((item) => GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _exercises.add(ExerciseLog(
                name: '${item.$2} (${item.$3})',
                category: 'QUICK',
              ));
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('⚡ ${item.$2} LOGGED', style: GoogleFonts.spaceMono(color: AppTheme.bg, fontSize: 10)),
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
