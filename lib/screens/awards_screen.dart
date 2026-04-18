import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class AwardsScreen extends StatelessWidget {
  const AwardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = Achievement.defaultList();
    final earned = achievements.where((a) => a.earned).toList();
    final locked = achievements.where((a) => !a.earned).toList();

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
                  Text('HALL OF EXCELLENCE', style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2))
                      .animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 6),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FORGE YOUR', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 40, fontWeight: FontWeight.w900, height: 1)),
                      Text('LEGACY', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 40, fontWeight: FontWeight.w900, height: 1, fontStyle: FontStyle.italic)),
                    ],
                  ).animate().fadeIn(duration: 500.ms),
                  const SizedBox(height: 12),
                  Text(
                    'Every rep, every drop of sweat, every limit broken. Your journey is carved in these artifacts of performance. 7 of 12 milestones conquered.',
                    style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 20),

                  // Rank & XP row
                  Row(
                    children: [
                      Expanded(child: _rankCard('RANK', 'ELITE IV', AppTheme.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: _rankCard('TOTAL XP', '14,200', AppTheme.neonGreen)),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _rankCard('SUCCESS RATE', '92%', AppTheme.neonPink)),
                      const SizedBox(width: 12),
                      Expanded(child: _rankCard('UNLOCKS', '07/12', AppTheme.primary)),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Earned achievements grid
          SliverToBoxAdapter(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: earned.length,
              itemBuilder: (_, i) => _AchievementCard(
                achievement: earned[i],
                delay: i * 80,
                earned: true,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Locked achievements grid
          SliverToBoxAdapter(
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: locked.length,
              itemBuilder: (_, i) => _AchievementCard(
                achievement: locked[i],
                delay: (earned.length + i) * 80,
                earned: false,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // Next milestone footer
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NEXT MILESTONE:', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text('OBSIDIAN KING', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonBlue,
                      foregroundColor: AppTheme.bg,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: Text('VIEW\nREQUIREMENTS', style: GoogleFonts.spaceMono(fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.5, height: 1.4)),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1.5)),
          const SizedBox(height: 6),
          Text(value, style: GoogleFonts.barlow(color: valueColor, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final int delay;
  final bool earned;
  const _AchievementCard({required this.achievement, required this.delay, required this.earned});

  @override
  Widget build(BuildContext context) {
    final Color borderColor = earned ? _earnedBorderColor() : AppTheme.border;
    final Color bgColor = earned ? _earnedBgColor() : AppTheme.card;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: earned ? 1.5 : 1),
        boxShadow: earned
            ? [BoxShadow(color: _earnedBorderColor().withOpacity(0.12), blurRadius: 16, spreadRadius: 1)]
            : null,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon box
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: earned ? _earnedBorderColor().withOpacity(0.15) : AppTheme.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: earned ? _earnedBorderColor().withOpacity(0.4) : AppTheme.border),
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
              fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5, height: 1.1,
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
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay));
  }

  Color _earnedBorderColor() {
    final colors = [AppTheme.neonGreen, AppTheme.neonBlue, AppTheme.neonPink, AppTheme.neonGreen];
    return colors[achievement.id.length % colors.length];
  }

  Color _earnedBgColor() {
    return _earnedBorderColor().withOpacity(0.06);
  }
}
