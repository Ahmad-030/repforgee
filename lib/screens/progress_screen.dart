import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _showVolume = true;
  StorageService? _storage;
  bool _loading = true;

  List<double> _weeklyVolume = List.filled(7, 0);
  List<MapEntry<String, double>> _topPRs = [];
  int  _streak  = 0;
  int  _monthly = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _storage = await StorageService.getInstance();
    setState(() {
      _weeklyVolume = _storage!.getWeeklyVolumeData();
      _topPRs       = _storage!.getTopPRs(limit: 3);
      _streak       = _storage!.getStreak();
      _monthly      = _storage!.getTotalWorkoutsThisMonth();
      _loading      = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      drawer: const RepForgeDrawer(),
      body: CustomScrollView(
        slivers: [
          repForgeAppBar(context),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _loading
                  ? const Center(child: Padding(
                      padding: EdgeInsets.all(60),
                      child: CircularProgressIndicator(color: AppTheme.neonGreen, strokeWidth: 2),
                    ))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('EVOLUTION METRICS', style: GoogleFonts.spaceMono(
                          color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2,
                        )).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 6),
                        Text('PROGRESS', style: GoogleFonts.barlow(
                          color: AppTheme.primary, fontSize: 44, fontWeight: FontWeight.w900, height: 1,
                        )).animate().fadeIn(duration: 500.ms),

                        const SizedBox(height: 16),

                        // Streak
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(8),
                            border: Border(left: BorderSide(color: AppTheme.neonGreen, width: 3)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.local_fire_department, color: AppTheme.neonGreen, size: 16),
                            const SizedBox(width: 8),
                            Text('CURRENT STREAK', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1.5)),
                            const SizedBox(width: 8),
                            Text('$_streak DAY${_streak == 1 ? '' : 'S'}', style: GoogleFonts.barlow(
                              color: _streak > 0 ? AppTheme.neonGreen : AppTheme.textDim,
                              fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1,
                            )),
                          ]),
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                        const SizedBox(height: 20),

                        // PR Cards (real data)
                        if (_topPRs.isEmpty)
                          _emptyPRCard()
                        else
                          ..._topPRs.asMap().entries.map((e) {
                            final colors = [AppTheme.neonBlue, AppTheme.neonGreen, AppTheme.neonPink];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _PrCard(
                                tag:          'PR: ${e.value.key.toUpperCase()}',
                                value:        e.value.value.truncateToDouble() == e.value.value
                                    ? e.value.value.toInt().toString()
                                    : e.value.value.toStringAsFixed(1),
                                unit:         'KG',
                                chartColor:   colors[e.key % colors.length],
                                delay:        e.key * 100,
                              ),
                            );
                          }),

                        const SizedBox(height: 24),

                        _buildVolumeSection(),

                        const SizedBox(height: 16),

                        // Mini stat cards
                        Row(children: [
                          Expanded(child: _miniStatCard('📅', '$_monthly', 'SESSIONS\nTHIS MONTH')),
                          const SizedBox(width: 12),
                          Expanded(child: _miniStatCard('🔥', '$_streak', 'DAY\nSTREAK')),
                        ]).animate().fadeIn(duration: 400.ms, delay: 400.ms),

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

  Widget _emptyPRCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Icon(Icons.fitness_center, color: AppTheme.textDim, size: 36),
        const SizedBox(height: 12),
        Text('NO PERSONAL RECORDS YET', style: GoogleFonts.barlow(
          color: AppTheme.textDim, fontSize: 16, fontWeight: FontWeight.w800,
        )),
        const SizedBox(height: 4),
        Text('Log sets with weights to track PRs here', style: GoogleFonts.spaceMono(
          color: AppTheme.textDim, fontSize: 9, letterSpacing: 0.5,
        ), textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildVolumeSection() {
    final maxVol = _weeklyVolume.reduce((a, b) => a > b ? a : b);
    final hasData = maxVol > 0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('WEEKLY VOLUME TRACKING', style: GoogleFonts.barlow(
        color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w800,
      )),
      const SizedBox(height: 4),
      Text('Total weight moved this week (tons)', style: GoogleFonts.dmSans(
        color: AppTheme.textMuted, fontSize: 12,
      )),
      const SizedBox(height: 16),

      if (!hasData)
        Container(
          width: double.infinity, height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.card, borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: Text('COMPLETE WORKOUTS TO SEE CHART',
            style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 9, letterSpacing: 1)),
        )
      else
        SizedBox(
          height: 150,
          child: LineChart(LineChartData(
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles:   const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles:  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                spots: _weeklyVolume.asMap().entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList(),
                isCurved: true,
                color: AppTheme.neonBlue,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(show: true, color: AppTheme.neonBlue.withOpacity(0.08)),
              ),
            ],
            minX: 0, maxX: 6,
            minY: 0,
          )),
        ),

      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('THIS WEEK TOTAL', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2)),
          const SizedBox(height: 6),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(
              _weeklyVolume.fold(0.0, (a, b) => a + b).toStringAsFixed(1),
              style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 28, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('TONS MOVED', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9)),
            ),
          ]),
        ]),
      ),
    ]).animate().fadeIn(duration: 400.ms, delay: 300.ms);
  }

  Widget _miniStatCard(String icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 8),
        Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _PrCard extends StatelessWidget {
  final String tag, value, unit;
  final Color chartColor;
  final int delay;

  const _PrCard({required this.tag, required this.value, required this.unit, required this.chartColor, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.border)),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.bg, borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.border),
            ),
            child: Text(tag, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1)),
          ),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 44, fontWeight: FontWeight.w900, height: 1)),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(unit, style: GoogleFonts.barlow(color: AppTheme.textMuted, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ]),
          Text('PERSONAL RECORD', style: GoogleFonts.spaceMono(color: chartColor, fontSize: 9, letterSpacing: 1)),
        ]),
        const Spacer(),
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: chartColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: chartColor.withOpacity(0.4)),
          ),
          alignment: Alignment.center,
          child: Icon(Icons.emoji_events, color: chartColor, size: 22),
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay + 200));
  }
}
