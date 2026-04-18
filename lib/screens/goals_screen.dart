import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});
  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final List<Goal> _goals = Goal.defaultGoals();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bg,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(Icons.menu, color: AppTheme.textMuted, size: 22),
                const SizedBox(width: 12),
                Text('REPFORGE', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
                const Spacer(),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: AppTheme.card2, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
                  child: const Icon(Icons.person, color: AppTheme.textMuted, size: 20),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MISSION PROTOCOL', style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2))
                      .animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('OPERATIONAL', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 40, fontWeight: FontWeight.w900, height: 1)),
                      Text('OBJECTIVES', style: GoogleFonts.barlow(color: AppTheme.neonBlue, fontSize: 40, fontWeight: FontWeight.w900, height: 1, fontStyle: FontStyle.italic)),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // Weekly completion
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WEEKLY COMPLETION', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2)),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('84', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 42, fontWeight: FontWeight.w900)),
                            Text('%', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 24, fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: 0.84, minHeight: 3,
                            backgroundColor: AppTheme.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // Goals list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _GoalCard(goal: _goals[i], delay: i * 100),
              ),
              childCount: _goals.length,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                children: [
                  // Deploy new goal
                  GestureDetector(
                    onTap: () => _showAddGoalSheet(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add, color: AppTheme.textDim, size: 28),
                          const SizedBox(height: 6),
                          Text('DEPLOY NEW GOAL', style: GoogleFonts.spaceMono(
                            color: AppTheme.textDim, fontSize: 10, letterSpacing: 2,
                          )),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                  const SizedBox(height: 20),

                  // Recent clearances
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('RECENT CLEARANCES', style: GoogleFonts.spaceMono(
                      color: AppTheme.textMuted, fontSize: 10, letterSpacing: 2,
                    )),
                  ),
                  const SizedBox(height: 12),

                  _clearanceItem(Icons.emoji_events, 'IRON LUNGS', 'LEVEL 4 COMPLETED', AppTheme.neonGreen),
                  const SizedBox(height: 8),
                  _clearanceItem(Icons.flag_outlined, 'TITAN MODE', 'IN PROGRESS', AppTheme.textMuted),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const RepForgeNavBar(currentIndex: 3),
    );
  }

  Widget _clearanceItem(IconData icon, String title, String sub, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
              Text(sub, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms);
  }

  void _showAddGoalSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DEPLOY NEW GOAL', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const SizedBox(height: 16),
            TextField(
              style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
              decoration: const InputDecoration(hintText: 'Goal title...'),
            ),
            const SizedBox(height: 12),
            TextField(
              style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
              decoration: const InputDecoration(hintText: 'Target value...'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonGreen, foregroundColor: AppTheme.bg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: Text('DEPLOY', style: GoogleFonts.barlow(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final int delay;
  const _GoalCard({required this.goal, required this.delay});

  @override
  Widget build(BuildContext context) {
    final isStrength = goal.title.contains('STRENGTH');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.neonGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.fitness_center, color: AppTheme.neonGreen, size: 16),
                    ),
                    const Spacer(),
                  ],
                ),
                const SizedBox(height: 12),
                Text(goal.title, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1)),

                if (goal.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(goal.subtitle, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1.5)),
                ],

                const SizedBox(height: 14),

                // Progress bar with values
                Row(
                  children: [
                    Text('${goal.current.toInt()}', style: GoogleFonts.barlow(color: AppTheme.neonBlue, fontSize: 22, fontWeight: FontWeight.w900)),
                    Text(' / ${goal.target.toInt()} ${goal.unit}', style: GoogleFonts.barlow(color: AppTheme.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
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
              ],
            ),
          ),

          // Action buttons (for first goal only)
          if (isStrength) ...[
            const Divider(height: 1, color: AppTheme.border),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonBlue, foregroundColor: AppTheme.bg,
                        elevation: 0, padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: Text('UPDATE METRIC', style: GoogleFonts.spaceMono(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.border),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {},
                      child: Text('DETAILS', style: GoogleFonts.spaceMono(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay + 200));
  }
}
