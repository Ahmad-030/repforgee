import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sessions = WorkoutSession.sampleData();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bg,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const Icon(Icons.menu, color: AppTheme.textMuted, size: 22),
                const SizedBox(width: 12),
                Text('REPFORGE', style: GoogleFonts.barlow(
                  color: AppTheme.neonGreen, fontSize: 18,
                  fontWeight: FontWeight.w900, letterSpacing: 3,
                )),
                const Spacer(),
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.card2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
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
                  // Header label
                  Text('LOG_ARCHIVE_v4.2', style: GoogleFonts.spaceMono(
                    color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2,
                  )).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 6),

                  // Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WORKOUT', style: GoogleFonts.barlow(
                        color: AppTheme.primary, fontSize: 44,
                        fontWeight: FontWeight.w900, height: 1,
                      )),
                      Text('HISTORY', style: GoogleFonts.barlow(
                        color: AppTheme.textDim, fontSize: 44,
                        fontWeight: FontWeight.w900, height: 1,
                      )),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Stats cards
                  ...[
                    _StatCard(label: 'TOTAL VOLUME', value: '142.5', unit: 'TONS'),
                    const SizedBox(height: 10),
                    _StatCard(label: 'AVG INTENSITY', value: '88', unit: '%'),
                    const SizedBox(height: 10),
                    _StatCard(label: 'SESSIONS (MONTH)', value: '24', unit: 'GOAL', unitColor: AppTheme.neonPink),
                  ],

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          // Timeline sessions
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _SessionTile(
                session: sessions[index],
                isFirst: index == 0,
                delay: index * 100,
              ),
              childCount: sessions.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/workout'),
        backgroundColor: AppTheme.neonBlue,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.black, size: 28),
      ),

      bottomNavigationBar: const RepForgeNavBar(currentIndex: 1),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, unit;
  final Color? unitColor;
  const _StatCard({required this.label, required this.value, required this.unit, this.unitColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.spaceMono(
            color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2,
          )),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.barlow(
                color: AppTheme.primary, fontSize: 36,
                fontWeight: FontWeight.w900, height: 1,
              )),
              const SizedBox(width: 8),
              Text(unit, style: GoogleFonts.barlow(
                color: unitColor ?? AppTheme.textMuted,
                fontSize: 18, fontWeight: FontWeight.w700,
              )),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05);
  }
}

class _SessionTile extends StatelessWidget {
  final WorkoutSession session;
  final bool isFirst;
  final int delay;
  const _SessionTile({required this.session, required this.isFirst, required this.delay});

  @override
  Widget build(BuildContext context) {
    final vol = (session.totalVolume / 1000).toStringAsFixed(1);
    final durMin = session.durationSeconds ~/ 60;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 36,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFirst ? AppTheme.neonGreen : AppTheme.textDim,
                          boxShadow: isFirst ? [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.5), blurRadius: 8)] : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 1, margin: const EdgeInsets.only(left: 24),
                    color: AppTheme.border,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.subtitle ?? '', style: GoogleFonts.spaceMono(
                    color: isFirst ? AppTheme.neonGreen : AppTheme.textMuted,
                    fontSize: 9, letterSpacing: 2,
                  )),
                  const SizedBox(height: 6),
                  Text(session.title, style: GoogleFonts.barlow(
                    color: AppTheme.primary, fontSize: 20,
                    fontWeight: FontWeight.w900, height: 1.1,
                  )),
                  const SizedBox(height: 12),

                  // Duration & Load row
                  Row(
                    children: [
                      _metaCell('DURATION', '${durMin}m'),
                      const SizedBox(width: 24),
                      _metaCell('LOAD', '${(session.totalVolume / 1000 * 10).toStringAsFixed(1).replaceAll('.', ',')}kg'),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppTheme.textDim, size: 18),
                    ],
                  ),

                  if (isFirst) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _detailCell('DEADLIFT', '180kg'),
                              const SizedBox(width: 24),
                              _detailCell('SETS/REPS', '5 x 5'),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _detailCell('INTENSITY', '92%'),
                              const SizedBox(width: 24),
                              _detailCell('REST', '180s'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: session.exercises.map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(e.name.toUpperCase(), style: GoogleFonts.spaceMono(
                          color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1,
                        )),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay));
  }

  Widget _metaCell(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _detailCell(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1)),
          const SizedBox(height: 2),
          Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
