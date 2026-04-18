import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showVolume = true;

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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/avatar.png', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppTheme.textMuted, size: 20)),
                  ),
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
                  Text('EVOLUTION METRICS', style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2))
                      .animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: 6),
                  Text('PROGRESS', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 44, fontWeight: FontWeight.w900, height: 1))
                      .animate().fadeIn(duration: 500.ms),

                  const SizedBox(height: 16),

                  // Streak badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border(left: BorderSide(color: AppTheme.neonGreen, width: 3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.trending_up, color: AppTheme.neonGreen, size: 16),
                        const SizedBox(width: 8),
                        Text('CURRENT STREAK', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1.5)),
                        const SizedBox(width: 8),
                        Text('14 DAYS ELITE', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                  const SizedBox(height: 20),

                  // PR Cards
                  _PrCard(
                    tag: 'PR: BENCH',
                    badge: 'GLOBAL RANK #23',
                    value: '145',
                    unit: 'KG',
                    subtitle: '+5KG THIS MONTH',
                    subtitleColor: AppTheme.neonGreen,
                    chartColor: AppTheme.neonBlue,
                    data: [60, 80, 100, 115, 130, 140, 145],
                    delay: 0,
                  ),

                  const SizedBox(height: 12),

                  _PrCard(
                    tag: 'PR: DEADLIFT',
                    badge: 'TOP 3%',
                    value: '220',
                    unit: 'KG',
                    subtitle: 'PLATEAU BROKEN',
                    subtitleColor: AppTheme.neonGreen,
                    chartColor: AppTheme.neonGreen,
                    data: [100, 130, 160, 180, 200, 210, 220],
                    delay: 100,
                  ),

                  const SizedBox(height: 12),

                  _PrCard(
                    tag: 'PR: SQUAT',
                    badge: 'LEVEL 42',
                    value: '180',
                    unit: 'KG',
                    subtitle: 'HYPERTROPHY PHASE',
                    subtitleColor: AppTheme.neonPink,
                    chartColor: AppTheme.neonPink,
                    data: [80, 100, 120, 140, 155, 170, 180],
                    delay: 200,
                  ),

                  const SizedBox(height: 24),

                  // Weekly volume chart
                  _buildVolumeSection(),

                  const SizedBox(height: 16),

                  // Stats row
                  Row(
                    children: [
                      Expanded(child: _miniStatCard('❤️', '164 BPM', 'AVG PEAK')),
                      const SizedBox(width: 12),
                      Expanded(child: _miniStatCard('⏱️', '54 MIN', 'AVG SESSION')),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const RepForgeNavBar(currentIndex: 2),
    );
  }

  Widget _buildVolumeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WEEKLY VOLUME TRACKING', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text('Total weight moved per microcycle', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 12),
        Row(
          children: [
            _toggleChip('VOLUME', _showVolume, () => setState(() => _showVolume = true)),
            const SizedBox(width: 8),
            _toggleChip('INTENSITY', !_showVolume, () => setState(() => _showVolume = false)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, _) {
                      const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
                      final i = val.toInt();
                      if (i < 0 || i >= days.length) return const SizedBox();
                      return Text(days[i], style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 7));
                    },
                    reservedSize: 20,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _showVolume
                      ? [const FlSpot(0, 3.2), const FlSpot(1, 2.1), const FlSpot(2, 4.5), const FlSpot(3, 3.8), const FlSpot(4, 5.2), const FlSpot(5, 4.0), const FlSpot(6, 6.1)]
                      : [const FlSpot(0, 72), const FlSpot(1, 65), const FlSpot(2, 88), const FlSpot(3, 78), const FlSpot(4, 92), const FlSpot(5, 80), const FlSpot(6, 95)],
                  isCurved: true,
                  color: AppTheme.neonBlue,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.neonBlue.withOpacity(0.08),
                  ),
                ),
              ],
              minX: 0, maxX: 6,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WEEKLY WORK CAPACITY', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2)),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('42,850', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 28, fontWeight: FontWeight.w900)),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('TOTALKG MOVED', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: 0.78,
                  backgroundColor: AppTheme.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonGreen),
                  minHeight: 3,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _toggleChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.neonBlue : AppTheme.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? AppTheme.neonBlue : AppTheme.border),
        ),
        child: Text(label, style: GoogleFonts.spaceMono(
          color: active ? AppTheme.bg : AppTheme.textMuted,
          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
        )),
      ),
    );
  }

  Widget _miniStatCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class _PrCard extends StatelessWidget {
  final String tag, badge, value, unit, subtitle;
  final Color subtitleColor, chartColor;
  final List<double> data;
  final int delay;

  const _PrCard({
    required this.tag, required this.badge, required this.value,
    required this.unit, required this.subtitle, required this.subtitleColor,
    required this.chartColor, required this.data, required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(tag, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1)),
              ),
              const Spacer(),
              Text(badge, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1)),
              const SizedBox(width: 8),
              // Dumbbell icon
              const Icon(Icons.fitness_center, color: AppTheme.textDim, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 52, fontWeight: FontWeight.w900, height: 1)),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(unit, style: GoogleFonts.barlow(color: AppTheme.textMuted, fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          Text(subtitle, style: GoogleFonts.spaceMono(color: subtitleColor, fontSize: 9, letterSpacing: 1)),
          const SizedBox(height: 12),
          // Mini bar chart
          SizedBox(
            height: 36,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.asMap().entries.map((e) {
                final isLast = e.key == data.length - 1;
                final maxVal = data.reduce((a, b) => a > b ? a : b);
                final h = (e.value / maxVal) * 36;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: h,
                    decoration: BoxDecoration(
                      color: isLast ? chartColor : chartColor.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay + 200));
  }
}
