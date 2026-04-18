import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  StorageService? _storage;
  List<WorkoutSession> _sessions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _storage = await StorageService.getInstance();
    setState(() {
      _sessions = _storage!.getWorkouts();
      _loading  = false;
    });
  }

  Future<void> _delete(String id) async {
    await _storage?.deleteWorkout(id);
    setState(() => _sessions = _storage!.getWorkouts());
  }

  @override
  Widget build(BuildContext context) {
    final totalVol  = _storage?.getTotalVolumeLifted() ?? 0;
    final monthCount= _storage?.getTotalWorkoutsThisMonth() ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      drawer: const RepForgeDrawer(),
      body: CustomScrollView(
        slivers: [
          repForgeAppBar(context),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOG_ARCHIVE', style: GoogleFonts.spaceMono(
                    color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2,
                  )).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 6),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('WORKOUT', style: GoogleFonts.barlow(
                      color: AppTheme.primary, fontSize: 44, fontWeight: FontWeight.w900, height: 1,
                    )),
                    Text('HISTORY', style: GoogleFonts.barlow(
                      color: AppTheme.textDim, fontSize: 44, fontWeight: FontWeight.w900, height: 1,
                    )),
                  ]).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Real stats
                  _StatCard(
                    label: 'TOTAL VOLUME',
                    value: totalVol >= 1000
                        ? '${(totalVol / 1000).toStringAsFixed(1)}'
                        : totalVol.toStringAsFixed(0),
                    unit: totalVol >= 1000 ? 'TONS' : 'KG',
                  ),
                  const SizedBox(height: 10),
                  _StatCard(
                    label: 'TOTAL SESSIONS',
                    value: '${_sessions.length}',
                    unit: 'ALL TIME',
                  ),
                  const SizedBox(height: 10),
                  _StatCard(
                    label: 'THIS MONTH',
                    value: '$monthCount',
                    unit: 'SESSIONS',
                    unitColor: AppTheme.neonBlue,
                  ),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),

          if (_loading)
            const SliverToBoxAdapter(
              child: Center(child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppTheme.neonGreen, strokeWidth: 2),
              )),
            )
          else if (_sessions.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(children: [
                  Icon(Icons.history, color: AppTheme.textDim, size: 56),
                  const SizedBox(height: 16),
                  Text('NO SESSIONS YET', style: GoogleFonts.barlow(
                    color: AppTheme.textDim, fontSize: 18, fontWeight: FontWeight.w800,
                  )),
                  const SizedBox(height: 8),
                  Text('Finish a workout to see it here',
                    style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.neonGreen,
                      side: const BorderSide(color: AppTheme.neonGreen),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add),
                    label: Text('START WORKOUT', style: GoogleFonts.spaceMono(
                      fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2,
                    )),
                    onPressed: () => Navigator.pushReplacementNamed(context, '/workout'),
                  ),
                ]),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _SessionTile(
                  session: _sessions[index],
                  isFirst: index == 0,
                  delay: index * 80,
                  onDelete: () => _delete(_sessions[index].id),
                ),
                childCount: _sessions.length,
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
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 2)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 36, fontWeight: FontWeight.w900, height: 1)),
            const SizedBox(width: 8),
            Text(unit, style: GoogleFonts.barlow(color: unitColor ?? AppTheme.textMuted, fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ]),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05);
  }
}

class _SessionTile extends StatelessWidget {
  final WorkoutSession session;
  final bool isFirst;
  final int  delay;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.isFirst,
    required this.delay,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final durMin = session.durationSeconds ~/ 60;
    final vol    = session.totalVolume;
    final volStr = vol >= 1000
        ? '${(vol / 1000).toStringAsFixed(1)}t'
        : '${vol.toInt()}kg';

    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.neonPink.withOpacity(0.15),
        child: const Icon(Icons.delete_outline, color: AppTheme.neonPink, size: 24),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppTheme.border)),
            title: Text('DELETE SESSION?', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w900)),
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
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // Timeline
          SizedBox(
            width: 36,
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isFirst ? AppTheme.neonGreen : AppTheme.textDim,
                    boxShadow: isFirst ? [BoxShadow(color: AppTheme.neonGreen.withOpacity(0.5), blurRadius: 8)] : null,
                  ),
                ),
              ),
              Expanded(child: Container(width: 1, margin: const EdgeInsets.only(left: 24), color: AppTheme.border)),
            ]),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(session.autoSubtitle, style: GoogleFonts.spaceMono(
                  color: isFirst ? AppTheme.neonGreen : AppTheme.textMuted,
                  fontSize: 9, letterSpacing: 2,
                )),
                const SizedBox(height: 6),
                Text(session.title, style: GoogleFonts.barlow(
                  color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w900, height: 1.1,
                )),
                const SizedBox(height: 12),

                Row(children: [
                  _metaCell('DURATION', durMin > 0 ? '${durMin}m' : '<1m'),
                  const SizedBox(width: 24),
                  _metaCell('VOLUME', volStr),
                  const SizedBox(width: 24),
                  _metaCell('SETS', '${session.totalSets}'),
                  const Spacer(),
                  const Icon(Icons.swipe_left, color: AppTheme.textDim, size: 14),
                ]),

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
                    child: Text(e.name, style: GoogleFonts.spaceMono(
                      color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1,
                    )),
                  )).toList(),
                ),
              ]),
            ),
          ),
        ]),
      ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: delay)),
    );
  }

  Widget _metaCell(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 8, letterSpacing: 1)),
      const SizedBox(height: 2),
      Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w800)),
    ],
  );
}
