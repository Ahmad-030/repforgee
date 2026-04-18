import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _lottieCtrl = AnimationController(vsync: this)..repeat();
  }

  @override
  void dispose() {
    _lottieCtrl.dispose();
    super.dispose();
  }

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
            title: Row(children: [
              const Icon(Icons.menu, color: AppTheme.textMuted, size: 22),
              const SizedBox(width: 12),
              Text('REPFORGE', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 3)),
              const Spacer(),
              Container(width: 36, height: 36, decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
                child: const Icon(Icons.person, color: AppTheme.textMuted, size: 20)),
            ]),
          ),

          SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // Manifesto header
            Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('CORE MANIFESTO', style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 10, letterSpacing: 2)).animate().fadeIn(duration: 400.ms),
              const SizedBox(height: 10),
              Text('FORGED IN\nTHE VOID.', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 44, fontWeight: FontWeight.w900, height: 1.0)).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
              const SizedBox(height: 14),
              Text('REPFORGE IS NOT A TRACKER. IT IS A PRECISION INSTRUMENT FOR THOSE WHO FIND COMFORT IN THE GRIND AND POWER IN THE OBSIDIAN.',
                style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.6), textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ])),

            const SizedBox(height: 24),

            // Lottie animation banner
            Container(height: 200,
              decoration: BoxDecoration(color: AppTheme.card, border: Border.symmetric(horizontal: BorderSide(color: AppTheme.border))),
              child: Stack(alignment: Alignment.center, children: [
                Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [const Color(0xFF050510), AppTheme.bg, const Color(0xFF050F05)])))),
                Lottie.asset('assets/lottie/workout.json', controller: _lottieCtrl, width: 160, height: 160,
                  onLoaded: (comp) { _lottieCtrl.duration = comp.duration; _lottieCtrl.repeat(); },
                  errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppTheme.neonGreen, size: 72)),
                Positioned(bottom: 16, left: 0, right: 0, child: Column(children: [
                  Text('THE FOUNDRY', style: GoogleFonts.barlow(color: AppTheme.textDim, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 3)),
                  Text('GLOBAL HQ • UNDERGROUND', style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 8, letterSpacing: 2)),
                ])),
              ]),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 24),

            Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('THE KINETIC VISION', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1))
                .animate().fadeIn(duration: 400.ms, delay: 400.ms),
              const SizedBox(height: 12),
              Text("We believe data should be visceral. RepForge was engineered to remove the friction between athlete and insight. By utilizing the Kinetic Noir design language, we've created a focused high-performance dashboard that maximizes luminance where it matters most: your progress.",
                style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.65))
                .animate().fadeIn(duration: 400.ms, delay: 450.ms),
              const SizedBox(height: 16),

              Row(children: [
                _specChip('PRECISION', 'ZERO\nDELAY'),
                const SizedBox(width: 12),
                _specChip('ENERGY', 'HIGH\nCONTRAST'),
              ]).animate().fadeIn(duration: 400.ms, delay: 500.ms),

              const SizedBox(height: 20),

              // Architect card
              Container(
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.neonPink.withOpacity(0.5), width: 1.5)),
                padding: const EdgeInsets.all(18),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ARCHITECT', style: GoogleFonts.spaceMono(color: AppTheme.neonPink, fontSize: 9, letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text('GOHEERAPPS\nDEVELOPER001', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 28, fontWeight: FontWeight.w900, height: 1.0)),
                  const SizedBox(height: 8),
                  Text('Pushing the boundaries of mobile performance and technical aesthetics.',
                    style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.5)),
                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.border),
                  const SizedBox(height: 10),
                  _infoRow('VERSION', '4.2.0-ULTRA'),
                  const SizedBox(height: 8),
                  _infoRow('ENGINE', 'PULSE-CORE'),
                  const SizedBox(height: 8),
                  _infoRow('EMAIL', 'goheerahmad8@gmail.com'),
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(foregroundColor: AppTheme.neonBlue, side: const BorderSide(color: AppTheme.neonBlue),
                        padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () {},
                      child: Text('CONTACT DEVELOPER', style: GoogleFonts.spaceMono(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2, color: AppTheme.neonBlue)),
                    )),
                ]),
              ).animate().fadeIn(duration: 400.ms, delay: 550.ms),

              const SizedBox(height: 24),

              Text('THE TECH STACK', style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1))
                .animate().fadeIn(duration: 400.ms, delay: 600.ms),
              const SizedBox(height: 12),

              GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2, childAspectRatio: 2.0, crossAxisSpacing: 12, mainAxisSpacing: 12,
                children: const [
                  _TechCard(icon: '📈', title: 'NEURAL TRACKING', desc: 'Predictive rep analysis via ML'),
                  _TechCard(icon: '🔄', title: 'OBSIDIAN SYNC', desc: 'Zero-latency cloud state'),
                  _TechCard(icon: '🔒', title: 'KINETIC CRYPT', desc: 'End-to-end data hardening'),
                  _TechCard(icon: '🎨', title: 'GLASS ENGINE', desc: 'High FPS blur rendering'),
                ]).animate().fadeIn(duration: 400.ms, delay: 650.ms),

              const SizedBox(height: 24),
              Text('PRIVACY COMMITMENT', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 10, letterSpacing: 2))
                .animate().fadeIn(duration: 400.ms, delay: 700.ms),
              const SizedBox(height: 8),
              Text("Your performance data is sacred. GoheerAppsDeveloper001 guarantees that your metrics never leave your encrypted local vault unless explicitly synced to our private obsidian cluster. We sell sweat, not data.",
                style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 12, height: 1.7))
                .animate().fadeIn(duration: 400.ms, delay: 700.ms),

              const SizedBox(height: 24),
              const Divider(color: AppTheme.border),
              const SizedBox(height: 16),

              _buildFooterLinks(context),
              const SizedBox(height: 100),
            ])),
          ])),
        ],
      ),
    );
  }

  Widget _specChip(String label, String value) => Expanded(
    child: Container(padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 8, letterSpacing: 1.5)),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w900, height: 1.1)),
      ]),
    ),
  );

  Widget _infoRow(String label, String value) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1)),
    Flexible(child: Text(value, style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 9, fontWeight: FontWeight.w700), textAlign: TextAlign.right)),
  ]);

  Widget _buildFooterLinks(BuildContext context) {
    final links = [
      ('PRIVACY POLICY', () => Navigator.pushNamed(context, '/privacy'), true),
      ('INSTAGRAM', null, false),
      ('TERMS OF COMBAT', null, false),
      ('DISCORD', null, false),
      ('SECURITY AUDIT', null, false),
      ('X / PULSE', null, false),
    ];
    return Column(children: [
      for (int i = 0; i < links.length; i += 2)
        Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [
          Expanded(child: GestureDetector(onTap: links[i].$2,
            child: Text(links[i].$1, style: GoogleFonts.spaceMono(
              color: links[i].$3 ? AppTheme.neonGreen : AppTheme.textMuted, fontSize: 10, letterSpacing: 1,
              decoration: links[i].$3 ? TextDecoration.underline : null, decorationColor: AppTheme.neonGreen)))),
          if (i + 1 < links.length)
            Expanded(child: Text(links[i+1].$1, style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 10, letterSpacing: 1))),
        ])),
    ]).animate().fadeIn(duration: 400.ms, delay: 750.ms);
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
