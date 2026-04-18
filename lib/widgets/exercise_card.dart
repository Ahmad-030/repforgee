import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Expandable exercise card shown in workout screen.
/// Shows exercise name, previous best, and set logging rows.
class ExerciseCard extends StatefulWidget {
  final ExerciseLog exercise;
  final void Function(WorkoutSet set) onSetLogged;
  final VoidCallback onRemove;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.onSetLogged,
    required this.onRemove,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final _weightCtrl = TextEditingController();
  final _repsCtrl   = TextEditingController();
  int _selectedRpe  = 8;
  bool _expanded    = true;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.neonGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppTheme.neonGreen.withOpacity(0.3)),
                    ),
                    child: Text(widget.exercise.category, style: GoogleFonts.spaceMono(
                      color: AppTheme.neonGreen, fontSize: 7, letterSpacing: 1,
                    )),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(widget.exercise.name, style: GoogleFonts.barlow(
                      color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w800,
                    )),
                  ),
                  if (widget.exercise.previousBest != null) ...[
                    Text('PR: ${widget.exercise.previousBest}', style: GoogleFonts.spaceMono(
                      color: AppTheme.neonBlue, fontSize: 8, letterSpacing: 0.5,
                    )),
                    const SizedBox(width: 8),
                  ],
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textMuted, size: 18),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onRemove,
                    child: const Icon(Icons.close, color: AppTheme.textDim, size: 18),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              children: [
                const Divider(height: 1, color: AppTheme.border),

                // Column headers
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    children: [
                      SizedBox(width: 30, child: Text('SET', style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 8, letterSpacing: 1))),
                      const SizedBox(width: 8),
                      Expanded(child: Text('KG', style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 8, letterSpacing: 1), textAlign: TextAlign.center)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('REPS', style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 8, letterSpacing: 1), textAlign: TextAlign.center)),
                      const SizedBox(width: 8),
                      Expanded(child: Text('RPE', style: GoogleFonts.spaceMono(color: AppTheme.textDim, fontSize: 8, letterSpacing: 1), textAlign: TextAlign.center)),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),

                // Logged sets
                ...widget.exercise.sets.asMap().entries.map((entry) =>
                  _SetRow(
                    setNum: entry.key + 1,
                    set: entry.value,
                  ).animate().fadeIn(duration: 250.ms),
                ),

                // Input row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${widget.exercise.sets.length + 1}',
                          style: GoogleFonts.spaceMono(color: AppTheme.neonGreen, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(_weightCtrl, 'e.g. 100')),
                      const SizedBox(width: 8),
                      Expanded(child: _numberField(_repsCtrl, 'e.g. 8')),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.border),
                          ),
                          alignment: Alignment.center,
                          child: Text('$_selectedRpe', style: GoogleFonts.barlow(
                            color: AppTheme.neonPink, fontSize: 16, fontWeight: FontWeight.w700,
                          )),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Log button
                      GestureDetector(
                        onTap: _logSet,
                        child: Container(
                          width: 36, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.neonGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.check, color: Colors.black, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                // RPE selector row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [6, 7, 8, 9, 10].map((rpe) {
                      final sel = rpe == _selectedRpe;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedRpe = rpe),
                        child: AnimatedContainer(
                          duration: 150.ms,
                          width: 40, height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.neonPink.withOpacity(0.15) : AppTheme.bg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: sel ? AppTheme.neonPink : AppTheme.border),
                          ),
                          child: Text('$rpe', style: GoogleFonts.barlow(
                            color: sel ? AppTheme.neonPink : AppTheme.textMuted,
                            fontSize: 14, fontWeight: FontWeight.w700,
                          )),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05);
  }

  Widget _numberField(TextEditingController ctrl, String hint) {
    return SizedBox(
      height: 40,
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        textAlign: TextAlign.center,
        style: GoogleFonts.barlow(color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.dmSans(color: AppTheme.textDim, fontSize: 11),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppTheme.neonGreen)),
          filled: true,
          fillColor: AppTheme.bg,
        ),
      ),
    );
  }

  void _logSet() {
    final weight = double.tryParse(_weightCtrl.text);
    final reps   = int.tryParse(_repsCtrl.text);

    if (weight == null || reps == null || weight <= 0 || reps <= 0) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enter weight and reps first', style: GoogleFonts.spaceMono(color: AppTheme.bg, fontSize: 11)),
          backgroundColor: AppTheme.neonPink,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    widget.onSetLogged(WorkoutSet(weight: weight, reps: reps, rpe: _selectedRpe));
    setState(() {
      _weightCtrl.clear();
      _repsCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ SET ${widget.exercise.sets.length} — ${weight.toInt()}KG × $reps REPS  RPE $_selectedRpe',
          style: GoogleFonts.spaceMono(color: AppTheme.bg, fontSize: 10, letterSpacing: 0.5)),
        backgroundColor: AppTheme.neonGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _SetRow extends StatelessWidget {
  final int setNum;
  final WorkoutSet set;
  const _SetRow({required this.setNum, required this.set});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$setNum', style: GoogleFonts.spaceMono(
              color: AppTheme.neonGreen, fontSize: 11, fontWeight: FontWeight.w700,
            )),
          ),
          const SizedBox(width: 8),
          Expanded(child: _cell('${set.weight.toInt()}')),
          const SizedBox(width: 8),
          Expanded(child: _cell('${set.reps}')),
          const SizedBox(width: 8),
          Expanded(child: _cell('${set.rpe}', color: AppTheme.neonPink)),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _cell(String val, {Color? color}) {
    return Container(
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Text(val, style: GoogleFonts.barlow(
        color: color ?? AppTheme.primary, fontSize: 15, fontWeight: FontWeight.w700,
      )),
    );
  }
}
