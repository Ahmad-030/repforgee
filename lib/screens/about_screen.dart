import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  late AnimationController _lottieCtrl;
  static const _devEmail = 'goheerahmad8@gmail.com';

  @override
  void initState() {
    super.initState();
    _lottieCtrl = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    super.dispose();
  }

  // ── FIX 1: copy email + show snackbar ──────────────────────────────────────
  void _copyEmail() {
    Clipboard.setData(const ClipboardData(text: _devEmail));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Email copied: $_devEmail',
          style: GoogleFonts.spaceMono(fontSize: 11, color: AppTheme.bg),
        ),
        backgroundColor: AppTheme.neonGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ── FIX 2: back → home ─────────────────────────────────────────────────────
  void _goHome() => Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);

  @override
  Widget build(BuildContext context) {
    // Wrap with PopScope so the Android system-back button also goes to /home
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _goHome();
      },
      child: Scaffold(
        backgroundColor: AppTheme.bg,
        appBar: AppBar(
          backgroundColor: AppTheme.bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.neonGreen, size: 18),
            onPressed: _goHome, // ← uses _goHome instead of Navigator.pop
          ),
          title: Text('REPFORGE', style: GoogleFonts.barlow(
            color: AppTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3,
          )),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppTheme.border),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Header
              Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CORE MANIFESTO', style: GoogleFonts.spaceMono(
                  color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2,
                )).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 10),
                Text('FORGED IN\nTHE VOID.', style: GoogleFonts.barlow(
                  color: AppTheme.primary, fontSize: 44, fontWeight: FontWeight.w900, height: 1.0,
                )).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 14),
                Text(
                  'REPFORGE IS NOT JUST A TRACKER. IT IS A PRECISION INSTRUMENT FOR THOSE WHO FIND POWER IN DATA AND COMFORT IN THE GRIND.',
                  style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.6),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
              ]),
              ),

              const SizedBox(height: 24),

              // Lottie banner
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  border: Border.symmetric(horizontal: BorderSide(color: AppTheme.border)),
                ),
                child: Stack(alignment: Alignment.center, children: [
                  Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [const Color(0xFF050510), AppTheme.bg, const Color(0xFF050F05)],
                    ),
                  ))),
                  Center(
                    child: Lottie.asset('assets/lottie/workout.json', controller: _lottieCtrl, width: 160, height: 160,
                        onLoaded: (comp) { _lottieCtrl.duration = comp.duration; _lottieCtrl.repeat(); },
                        errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppTheme.neonGreen, size: 72)),
                  ),
                  Positioned(bottom: 16, left: 0, right: 0, child: Column(children: [
                    Text('THE FOUNDRY', style: GoogleFonts.barlow(color: AppTheme.textDim, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3)),
                    Text('PRECISION WORKOUT ENGINE', style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 8, letterSpacing: 2)),
                  ])),
                ]),
              ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

              const SizedBox(height: 24),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // App features
                Text('WHAT REPFORGE DOES', style: GoogleFonts.barlow(
                  color: AppTheme.neonGreen, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1,
                )).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                const SizedBox(height: 12),

                ...[
                  ('💪', 'WORKOUT LOGGING', 'Log exercises, sets, reps and weight with real-time volume tracking.'),
                  ('📊', 'PROGRESS TRACKING', 'View personal records and weekly volume trends from your real data.'),
                  ('🎯', 'GOAL SETTING', 'Deploy and track custom fitness goals with progress bars.'),
                  ('🏆', 'ACHIEVEMENTS', 'Unlock real badges as you hit milestones — no fake pre-earned awards.'),
                  ('📅', 'WORKOUT HISTORY', 'Browse every session you\'ve completed with full stats.'),
                  ('🔒', '100% OFFLINE', 'All data is stored locally on your device. No account needed.'),
                ].asMap().entries.map((entry) {
                  final i = entry.key;
                  final item = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.$1, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.$2, style: GoogleFonts.barlow(
                            color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5,
                          )),
                          const SizedBox(height: 3),
                          Text(item.$3, style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12, height: 1.4)),
                        ])),
                      ]),
                    ).animate().fadeIn(duration: 400.ms, delay: Duration(milliseconds: 450 + i * 60)),
                  );
                }),

                const SizedBox(height: 24),

                // Developer card
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.neonPink.withOpacity(0.5), width: 1.5),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('DEVELOPER', style: GoogleFonts.spaceMono(color: AppTheme.neonPink, fontSize: 9, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text('GOHEERA APPS', style: GoogleFonts.barlow(
                      color: AppTheme.primary, fontSize: 28, fontWeight: FontWeight.w900, height: 1.0,
                    )),
                    const SizedBox(height: 8),
                    Text('Building high-performance mobile tools for athletes and fitness enthusiasts.',
                        style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
                    const SizedBox(height: 14),
                    const Divider(color: AppTheme.border),
                    const SizedBox(height: 10),
                    _infoRow('CONTACT', _devEmail),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.neonBlue,
                          side: const BorderSide(color: AppTheme.neonBlue),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _copyEmail, // ← calls _copyEmail
                        child: Text('CONTACT DEVELOPER', style: GoogleFonts.spaceMono(
                          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppTheme.neonBlue,
                        )),
                      ),
                    ),
                  ]),
                ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

                const SizedBox(height: 24),

                // Privacy note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.card, borderRadius: BorderRadius.circular(10),
                    border: Border(left: BorderSide(color: AppTheme.neonGreen, width: 3)),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('PRIVACY FIRST', style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(
                      'RepForge stores all data locally on your device. We collect no personal information, have no accounts, and make no network requests. Your workout data is yours alone.',
                      style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12, height: 1.7),
                    ),
                  ]),
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                const SizedBox(height: 24),
                const Divider(color: AppTheme.border),
                const SizedBox(height: 16),

                // Footer links
                _buildFooterLinks(context),
                const SizedBox(height: 100),
              ]),
              ),
            ])),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1)),
      Flexible(child: Text(value, style: GoogleFonts.spaceMono(
        color: AppTheme.neonGreen, fontSize: 9, fontWeight: FontWeight.w700,
      ), textAlign: TextAlign.right)),
    ],
  );

  Widget _buildFooterLinks(BuildContext context) {
    return Column(children: [
      _footerBtn(context, 'PRIVACY POLICY', Icons.shield_outlined, () => Navigator.pushNamed(context, '/privacy')),
      const SizedBox(height: 10),
      _footerBtn(context, 'CONTACT DEVELOPER', Icons.email_outlined, _copyEmail), // ← same _copyEmail
    ]).animate().fadeIn(duration: 400.ms, delay: 750.ms);
  }

  Widget _footerBtn(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          Icon(icon, color: AppTheme.textMuted, size: 18),
          const SizedBox(width: 12),
          Text(label, style: GoogleFonts.spaceMono(color: AppTheme.primary, fontSize: 10, letterSpacing: 1.5)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppTheme.textDim, size: 18),
        ]),
      ),
    );
  }
}

class _TechCard extends StatelessWidget {
  final String icon, title, desc;
  const _TechCard({required this.icon, required this.title, required this.desc});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 5),
      Text(title, style: GoogleFonts.spaceMono(color: AppTheme.primary, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      const SizedBox(height: 2),
      Text(desc, style: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 9), maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );
}