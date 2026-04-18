import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── Bottom Navigation Bar ─────────────────────────────────────────────────────

class RepForgeNavBar extends StatelessWidget {
  final int currentIndex;
  const RepForgeNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    const items = [
      (icon: Icons.fitness_center_rounded, label: 'WORKOUT', route: '/workout'),
      (icon: Icons.history_rounded, label: 'HISTORY', route: '/history'),
      (icon: Icons.show_chart_rounded, label: 'PROGRESS', route: '/progress'),
      (icon: Icons.track_changes_rounded, label: 'GOALS', route: '/goals'),
      (icon: Icons.emoji_events_rounded, label: 'AWARDS', route: '/awards'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D0D0D),
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final selected = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!selected) {
                      HapticFeedback.selectionClick();
                      Navigator.pushReplacementNamed(context, item.route);
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: selected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            item.icon,
                            color: selected ? AppTheme.neonGreen : AppTheme.textMuted,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: GoogleFonts.spaceMono(
                            color: selected ? AppTheme.neonGreen : AppTheme.textMuted,
                            fontSize: 7,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ── Double Back To Exit Wrapper ───────────────────────────────────────────────

class DoubleBackToExit extends StatefulWidget {
  final Widget child;
  const DoubleBackToExit({super.key, required this.child});

  @override
  State<DoubleBackToExit> createState() => _DoubleBackToExitState();
}

class _DoubleBackToExitState extends State<DoubleBackToExit> {
  bool _backPressedOnce = false;

  Future<bool> _onWillPop() async {
    if (_backPressedOnce) return true;

    setState(() => _backPressedOnce = true);
    _showExitDialog();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _backPressedOnce = false);
    });

    return false;
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.border),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.neonPink.withOpacity(0.4)),
              ),
              alignment: Alignment.center,
              child: const Text('⚡', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 16),
            Text(
              'EXIT REPFORGE?',
              style: GoogleFonts.barlow(
                color: AppTheme.primary, fontSize: 22,
                fontWeight: FontWeight.w900, letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Press back again to close the app.\nYour data is saved automatically.',
              style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 13, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textMuted,
                      side: const BorderSide(color: AppTheme.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _backPressedOnce = false);
                    },
                    child: Text('STAY', style: GoogleFonts.spaceMono(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonPink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      SystemNavigator.pop();
                    },
                    child: Text('EXIT', style: GoogleFonts.spaceMono(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _onWillPop();
      },
      child: widget.child,
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class SectionLabel extends StatelessWidget {
  final String text;
  final Color? color;
  const SectionLabel(this.text, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.spaceMono(
        color: color ?? AppTheme.textMuted,
        fontSize: 10,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ── Neon Button ───────────────────────────────────────────────────────────────

class NeonButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double? width;

  const NeonButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.neonGreen;
    return SizedBox(
      width: width ?? double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: c,
          foregroundColor: AppTheme.bg,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          HapticFeedback.mediumImpact();
          onTap();
        },
        child: Text(
          label,
          style: GoogleFonts.barlow(
            fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 3, color: AppTheme.bg,
          ),
        ),
      ),
    );
  }
}
