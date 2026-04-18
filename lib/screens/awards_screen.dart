import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AwardsScreen extends StatefulWidget {
  const AwardsScreen({super.key});
  @override
  State<AwardsScreen> createState() => _AwardsScreenState();
}

class _AwardsScreenState extends State<AwardsScreen> {
  StorageService? _storage;
  List<Achievement> _achievements = [];
  int _totalWorkouts = 0;
  double _totalVolumeKg = 0;
  int _streak = 0;
  int _totalSets = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _storage = await StorageService.getInstance();
    final sessions = _storage!.getWorkouts();
    setState(() {
      _totalWorkouts  = sessions.length;
      _totalVolumeKg  = sessions.fold(0.0, (s, e) => s + e.totalVolume);
      _streak         = _storage!.getStreak();
      _totalSets      = sessions.fold(0, (s, e) => s + e.totalSets);
      _achievements   = Achievement.buildFromStats(
        totalWorkouts:  _totalWorkouts,
        totalVolumeKg:  _totalVolumeKg,
        streakDays:     _streak,
        totalSets:      _totalSets,
      );
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final earned = _achievements.where((a) => a.earned).toList();
    final locked = _achievements.where((a) => !a.earned).toList();

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
                Text('HALL OF EXCELLENCE', style: GoogleFonts.spaceMono(
                  color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2,
                )).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 6),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FORGE YOUR', style: GoogleFonts.barlow(
                    color: AppTheme.primary, fontSize: 40, fontWeight: FontWeight.w900, height: 1,
                  )),
                  Text('LEGACY', style: GoogleFonts.barlow(
                    color: AppTheme.neonGreen, fontSize: 40, fontWeight: FontWeight.w900, height: 1, fontStyle: FontStyle.italic,
                  )),
                ]).animate().fadeIn(duration: 500.ms),

                const SizedBox(height: 12),

                if (_loading)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(color: AppTheme.neonGreen, strokeWidth: 2),
                  ))
                else ...[
                  Text(
                    earned.isEmpty
                        ? 'Complete workouts to earn achievements. Your journey begins with a single rep.'
                        : 'Every rep, every drop of sweat. Your journey is carved in these artifacts of performance. ${earned.length} of ${_achievements.length} milestones conquered.',
                    style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 20),

                  // Real stats row
                  Row(children: [
                    Expanded(child: _rankCard('WORKOUTS',   '$_totalWorkouts',        AppTheme.primary)),
                    const SizedBox(width: 12),
                    Expanded(child: _rankCard('DAY STREAK', '$_streak',               AppTheme.neonGreen)),
                  ]).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: _rankCard('TOTAL SETS', '$_totalSets',            AppTheme.neonBlue)),
                    const SizedBox(width: 12),
                    Expanded(child: _rankCard('UNLOCKED',   '${earned.length}/${_achievements.length}', AppTheme.neonPink)),
                  ]).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                  const SizedBox(height: 24),
                ],
              ]),
            ),
          ),

          if (!_loading) ...[
            // ── Earned section ───────────────────────────────────────────
            if (earned.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text('EARNED — ${earned.length}', style: GoogleFonts.spaceMono(
                    color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2,
                  )),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _AchievementCard(achievement: earned[i], delay: i * 80, earned: true),
                    childCount: earned.length,
                  ),
                ),
              ),
            ],

            // ── Empty earned state ───────────────────────────────────────
            if (earned.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(children: [
                      const Text('🏋️', style: TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text('NO ACHIEVEMENTS YET', style: GoogleFonts.barlow(
                        color: AppTheme.textDim, fontSize: 16, fontWeight: FontWeight.w800,
                      )),
                      const SizedBox(height: 6),
                      Text('Complete your first workout to earn\nyour first achievement badge',
                        style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 9, letterSpacing: 0.5),
                        textAlign: TextAlign.center),
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.neonGreen,
                          side: const BorderSide(color: AppTheme.neonGreen),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.fitness_center, size: 16),
                        label: Text('START WORKOUT', style: GoogleFonts.spaceMono(
                          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2,
                        )),
                        onPressed: () => Navigator.pushReplacementNamed(context, '/workout'),
                      ),
                    ]),
                  ),
                ),
              ),

            // ── Locked section ───────────────────────────────────────────
            if (locked.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text('LOCKED — ${locked.length}', style: GoogleFonts.spaceMono(
                    color: AppTheme.textMuted, fontSize: 10, letterSpacing: 2,
                  )),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _AchievementCard(achievement: locked[i], delay: (earned.length + i) * 60, earned: false),
                    childCount: locked.length,
                  ),
                ),
              ),
            ],

            // ── Next milestone footer ────────────────────────────────────
            if (locked.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('NEXT MILESTONE:', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1)),
                      const SizedBox(height: 4),
                      Text(locked.first.title, style: GoogleFonts.barlow(
                        color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1,
                      )),
                      const SizedBox(height: 2),
                      Text(locked.first.description, style: GoogleFonts.dmSans(
                        color: AppTheme.textMuted, fontSize: 11,
                      )),
                    ])),
                    const SizedBox(width: 12),
                    Text(locked.first.emoji, style: const TextStyle(fontSize: 32)),
                  ]),
                ).animate().fadeIn(duration: 400.ms),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: const RepForgeNavBar(currentIndex: 4),
    );
  }

  Widget _rankCard(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1.5)),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.barlow(color: valueColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
      ]),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final int delay;
  final bool earned;
  const _AchievementCard({required this.achievement, required this.delay, required this.earned});

  Color get _accentColor {
    const colors = [AppTheme.neonGreen, AppTheme.neonBlue, AppTheme.neonPink];
    return colors[achievement.id.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: earned ? _accentColor.withOpacity(0.06) : AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: earned ? _accentColor.withOpacity(0.4) : AppTheme.border,
          width: earned ? 1.5 : 1,
        ),
        boxShadow: earned
            ? [BoxShadow(color: _accentColor.withOpacity(0.10), blurRadius: 16, spreadRadius: 1)]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: earned ? _accentColor.withOpacity(0.15) : AppTheme.bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: earned ? _accentColor.withOpacity(0.5) : AppTheme.border),
          ),
          alignment: Alignment.center,
          child: earned
              ? Text(achievement.emoji, style: const TextStyle(fontSize: 22))
              : const Icon(Icons.lock_outline, color: AppTheme.textDim, size: 20),
        ),
        const Spacer(),
        Text(
          achievement.title,
          style: GoogleFonts.barlow(
            color: earned ? AppTheme.primary : AppTheme.textDim,
            fontSize: 13, fontWeight: FontWeight.w900,
            letterSpacing: 0.5, height: 1.1,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          achievement.description,
          style: GoogleFonts.dmSans(
            color: earned ? AppTheme.textMuted : AppTheme.textDim,
            fontSize: 10, height: 1.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay));
  }
}
