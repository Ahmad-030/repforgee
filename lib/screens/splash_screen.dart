import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late AnimationController _lottieCtrl;

  @override
  void initState() {
    super.initState();

    // Progress bar animates over 3 seconds
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..forward();

    // Lottie controller — NO duration set here, NO repeat() called here.
    // Duration is set inside onLoaded once the JSON is parsed.
    _lottieCtrl = AnimationController(vsync: this);

    // Navigate after splash completes
    Future.delayed(const Duration(milliseconds: 3400), () {
      if (mounted) Navigator.of(context).pushReplacementNamed('/workout');
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _lottieCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Vignette overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.4,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.5),
                  ],
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Lottie animation
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Lottie.asset(
                    'assets/lottie/workout.json',
                    controller: _lottieCtrl,
                    onLoaded: (composition) {
                      // Set duration FIRST, then repeat — fixes the assertion
                      _lottieCtrl.duration = composition.duration;
                      _lottieCtrl.repeat();
                    },
                    errorBuilder: (_, __, ___) => _fallbackIcon(),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(begin: const Offset(0.7, 0.7)),

                const SizedBox(height: 28),

                // REPFORGE wordmark
                Text(
                  'REPFORGE',
                  style: GoogleFonts.barlow(
                    color: AppTheme.primary,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 8,
                  ),
                )
                    .animate(delay: 300.ms)
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: 0.2),

                const SizedBox(height: 6),

                Text(
                  'FORGE YOUR LIMIT.',
                  style: GoogleFonts.spaceMono(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                    letterSpacing: 4,
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 600.ms),

                const Spacer(flex: 2),

                // Progress bar section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'INITIALIZING SYSTEMS',
                            style: GoogleFonts.spaceMono(
                              color: AppTheme.textMuted,
                              fontSize: 9,
                              letterSpacing: 2,
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _progressCtrl,
                            builder: (_, __) => Text(
                              '${(_progressCtrl.value * 100).toInt()}%',
                              style: GoogleFonts.spaceMono(
                                color: AppTheme.neonGreen,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: AnimatedBuilder(
                          animation: _progressCtrl,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _progressCtrl.value,
                            backgroundColor: AppTheme.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.neonGreen,
                            ),
                            minHeight: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _statusDot('FORGE', 0),
                          const SizedBox(width: 32),
                          _statusDot('KINETICS', 1),
                          const SizedBox(width: 32),
                          _statusDot('NEURONS', 2),
                        ],
                      ),
                    ],
                  ),
                ).animate(delay: 700.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 40),

                Text(
                  'POWERED BY KINETIC PULSE TECHNOLOGY',
                  style: GoogleFonts.spaceMono(
                    color: AppTheme.textDim,
                    fontSize: 8,
                    letterSpacing: 2,
                  ),
                ).animate(delay: 900.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: ['G', 'T', '⚡']
                      .map(
                        (s) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: AppTheme.textDim,
                          fontSize: 8,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ).animate(delay: 1000.ms).fadeIn(duration: 600.ms),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusDot(String label, int index) {
    return AnimatedBuilder(
      animation: _progressCtrl,
      builder: (_, __) {
        final active = _progressCtrl.value > (index + 1) / 4;
        return Column(
          children: [
            Text(
              label,
              style: GoogleFonts.spaceMono(
                color: active ? AppTheme.textMuted : AppTheme.textDim,
                fontSize: 7,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? AppTheme.neonGreen : AppTheme.textDim,
                boxShadow: active
                    ? [
                  BoxShadow(
                    color: AppTheme.neonGreen.withValues(alpha: 0.6),
                    blurRadius: 8,
                  ),
                ]
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  // Shown if the Lottie JSON fails to load
  Widget _fallbackIcon() {
    return AnimatedBuilder(
      animation: _progressCtrl,
      builder: (_, __) => Transform.rotate(
        angle: _progressCtrl.value * 6.28,
        child: const Icon(
          Icons.fitness_center,
          color: AppTheme.neonGreen,
          size: 64,
        ),
      ),
    );
  }
}