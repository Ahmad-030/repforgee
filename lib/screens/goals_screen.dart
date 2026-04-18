import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  StorageService? _storage;
  List<Goal> _goals = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _storage = await StorageService.getInstance();
    setState(() {
      _goals   = _storage!.getGoals();
      _loading = false;
    });
  }

  Future<void> _deleteGoal(String id) async {
    await _storage?.deleteGoal(id);
    setState(() => _goals = _storage!.getGoals());
  }

  @override
  Widget build(BuildContext context) {
    final weeklyPct = _storage?.getWeeklyCompletionPercent() ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      drawer: const RepForgeDrawer(),
      body: CustomScrollView(
        slivers: [
          repForgeAppBar(context),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('MISSION PROTOCOL', style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2))
                    .animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 6),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('OPERATIONAL', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 40, fontWeight: FontWeight.w900, height: 1)),
                  Text('OBJECTIVES', style: GoogleFonts.barlow(color: AppTheme.neonBlue, fontSize: 40, fontWeight: FontWeight.w900, height: 1, fontStyle: FontStyle.italic)),
                ]).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                const SizedBox(height: 20),

                // Weekly completion (real)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('WEEKLY COMPLETION (TARGET: 4 SESSIONS)', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2)),
                    const SizedBox(height: 6),
                    Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
                      Text('$weeklyPct', style: GoogleFonts.barlow(
                        color: weeklyPct >= 100 ? AppTheme.neonGreen : AppTheme.neonBlue,
                        fontSize: 42, fontWeight: FontWeight.w900,
                      )),
                      Text('%', style: GoogleFonts.barlow(
                        color: weeklyPct >= 100 ? AppTheme.neonGreen : AppTheme.neonBlue,
                        fontSize: 24, fontWeight: FontWeight.w700,
                      )),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: weeklyPct / 100,
                        minHeight: 3,
                        backgroundColor: AppTheme.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          weeklyPct >= 100 ? AppTheme.neonGreen : AppTheme.neonBlue,
                        ),
                      ),
                    ),
                  ]),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                const SizedBox(height: 16),
              ]),
            ),
          ),

          if (_loading)
            const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.neonGreen, strokeWidth: 2),
              )),
            )
          else if (_goals.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(children: [
                  Icon(Icons.track_changes, color: AppTheme.textDim, size: 56),
                  const SizedBox(height: 16),
                  Text('NO GOALS YET', style: GoogleFonts.barlow(color: AppTheme.textDim, fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('Deploy your first goal below',
                    style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 10), textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                ]),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Dismissible(
                  key: ValueKey(_goals[i].id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete_outline, color: AppTheme.neonPink, size: 24),
                  ),
                  confirmDismiss: (_) async => await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppTheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
                      title: Text('DELETE GOAL?', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                      content: Text('This cannot be undone.', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13)),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('CANCEL', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 10))),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.neonPink, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('DELETE', style: GoogleFonts.spaceMono(fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ) ?? false,
                  onDismissed: (_) => _deleteGoal(_goals[i].id),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _GoalCard(goal: _goals[i], delay: i * 100, onUpdate: (g) async {
                      await _storage?.saveGoal(g);
                      setState(() => _goals = _storage!.getGoals());
                    }),
                  ),
                ),
                childCount: _goals.length,
              ),
            ),

          // Deploy new goal button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
              child: GestureDetector(
                onTap: () => _showAddGoalSheet(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.card, borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(children: [
                    Icon(Icons.add, color: AppTheme.textDim, size: 28),
                    const SizedBox(height: 6),
                    Text('DEPLOY NEW GOAL', style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 10, letterSpacing: 2)),
                  ]),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const RepForgeNavBar(currentIndex: 3),
    );
  }

  void _showAddGoalSheet(BuildContext context) {
    final titleCtrl   = TextEditingController();
    final subtitleCtrl= TextEditingController();
    final targetCtrl  = TextEditingController();
    final unitCtrl    = TextEditingController(text: 'KG');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DEPLOY NEW GOAL', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
          const SizedBox(height: 16),
          TextField(controller: titleCtrl, style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
            decoration: const InputDecoration(hintText: 'Goal title (e.g. BENCH PRESS 100KG)')),
          const SizedBox(height: 12),
          TextField(controller: subtitleCtrl, style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
            decoration: const InputDecoration(hintText: 'Subtitle (e.g. STRENGTH GOAL)')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: targetCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Target value'))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: unitCtrl,
              style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
              decoration: const InputDecoration(hintText: 'Unit (KG, %, REPS)'))),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen, foregroundColor: AppTheme.bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final title  = titleCtrl.text.trim().toUpperCase();
                final target = double.tryParse(targetCtrl.text.trim());
                if (title.isEmpty || target == null || target <= 0) return;

                final goal = Goal(
                  title:    title,
                  subtitle: subtitleCtrl.text.trim().toUpperCase().isEmpty ? 'PERSONAL GOAL' : subtitleCtrl.text.trim().toUpperCase(),
                  target:   target,
                  current:  0,
                  unit:     unitCtrl.text.trim().toUpperCase().isEmpty ? 'KG' : unitCtrl.text.trim().toUpperCase(),
                );
                await _storage?.saveGoal(goal);
                setState(() => _goals = _storage!.getGoals());
                if (mounted) Navigator.pop(context);
              },
              child: Text('DEPLOY', style: GoogleFonts.barlow(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final int delay;
  final void Function(Goal) onUpdate;

  const _GoalCard({required this.goal, required this.delay, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: goal.progress >= 1.0 ? AppTheme.neonGreen.withOpacity(0.5) : AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.neonGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                ),
                child: const Icon(Icons.track_changes, color: AppTheme.neonGreen, size: 16),
              ),
              const Spacer(),
              if (goal.progress >= 1.0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.neonGreen.withOpacity(0.5)),
                  ),
                  child: Text('COMPLETED', style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 8, letterSpacing: 1)),
                ),
            ]),
            const SizedBox(height: 12),
            Text(goal.title, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
            if (goal.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(goal.subtitle, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1.5)),
            ],
            const SizedBox(height: 14),
            Row(children: [
              Text('${goal.current.toInt()}', style: GoogleFonts.barlow(color: AppTheme.neonBlue, fontSize: 22, fontWeight: FontWeight.w900)),
              Text(' / ${goal.target.toInt()} ${goal.unit}', style: GoogleFonts.barlow(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  goal.progress >= 1.0 ? AppTheme.neonGreen : AppTheme.neonBlue,
                ),
                minHeight: 5,
              ),
            ),
          ]),
        ),

        const Divider(height: 1, color: AppTheme.border),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonBlue, foregroundColor: AppTheme.bg,
                  elevation: 0, padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => _showUpdateSheet(context),
                child: Text('UPDATE', style: GoogleFonts.spaceMono(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
            ),
          ]),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay + 200));
  }

  void _showUpdateSheet(BuildContext context) {
    final ctrl = TextEditingController(text: goal.current.toInt().toString());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('UPDATE: ${goal.title}', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 16),
          TextField(controller: ctrl, autofocus: true,
            style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'Current value (${goal.unit})')),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonGreen, foregroundColor: AppTheme.bg,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final val = double.tryParse(ctrl.text.trim());
                if (val == null) return;
                final updated = Goal(
                  id:        goal.id, title: goal.title, subtitle: goal.subtitle,
                  target:    goal.target, current: val, unit: goal.unit,
                  completed: val >= goal.target,
                );
                onUpdate(updated);
                Navigator.pop(context);
              },
              child: Text('SAVE', style: GoogleFonts.barlow(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
          ),
        ]),
      ),
    );
  }
}
