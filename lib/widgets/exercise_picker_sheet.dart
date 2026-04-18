import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

/// Full-screen exercise picker bottom sheet.
/// Shows categorized exercise list with search.
class ExercisePickerSheet extends StatefulWidget {
  final void Function(String name, String category) onSelected;
  const ExercisePickerSheet({super.key, required this.onSelected});

  @override
  State<ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<ExercisePickerSheet> {
  String _query = '';
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Map<String, List<String>> get _filtered {
    final result = <String, List<String>>{};
    for (final entry in ExerciseLibrary.all.entries) {
      if (_selectedCategory != null && entry.key != _selectedCategory) continue;
      final matches = entry.value.where(
        (e) => e.toLowerCase().contains(_query.toLowerCase()),
      ).toList();
      if (matches.isNotEmpty) result[entry.key] = matches;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36, height: 3,
              decoration: BoxDecoration(
                color: AppTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                Text('ADD EXERCISE', style: GoogleFonts.barlow(
                  color: AppTheme.neonGreen, fontSize: 22,
                  fontWeight: FontWeight.w900, letterSpacing: 2,
                )),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: AppTheme.textMuted, size: 22),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Search exercise or muscle group...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 18),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                        child: const Icon(Icons.clear, color: AppTheme.textMuted, size: 16),
                      )
                    : null,
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          const SizedBox(height: 12),

          // Category filter chips
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _categoryChip(null, 'ALL'),
                ...ExerciseLibrary.all.keys.map((cat) => _categoryChip(cat, cat)),
              ],
            ),
          ),

          const SizedBox(height: 8),
          const Divider(height: 1, color: AppTheme.border),

          // Exercise list
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off, color: AppTheme.textDim, size: 36),
                        const SizedBox(height: 8),
                        Text('No exercises found', style: GoogleFonts.dmSans(color: AppTheme.textMuted, fontSize: 14)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    itemCount: _filtered.length,
                    itemBuilder: (_, catIndex) {
                      final entry = _filtered.entries.elementAt(catIndex);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category header
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                            child: Text(entry.key, style: GoogleFonts.spaceMono(
                              color: AppTheme.neonGreen, fontSize: 9,
                              letterSpacing: 2, fontWeight: FontWeight.w700,
                            )),
                          ),
                          // Exercises
                          ...entry.value.asMap().entries.map((e) => _ExerciseTile(
                            name: e.value,
                            category: entry.key,
                            delay: e.key * 40,
                            onTap: () {
                              Navigator.pop(context);
                              widget.onSelected(e.value, entry.key);
                            },
                          )),
                        ],
                      );
                    },
                  ),
          ),

          // Custom exercise button
          Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).padding.bottom + 12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.neonBlue,
                side: const BorderSide(color: AppTheme.neonBlue, width: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16),
              label: Text('ADD CUSTOM EXERCISE', style: GoogleFonts.spaceMono(
                fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5,
              )),
              onPressed: () => _showCustomExerciseDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String? cat, String label) {
    final selected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = cat),
      child: AnimatedContainer(
        duration: 200.ms,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.neonGreen : AppTheme.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: selected ? AppTheme.neonGreen : AppTheme.border),
        ),
        child: Text(label, style: GoogleFonts.spaceMono(
          color: selected ? AppTheme.bg : AppTheme.textMuted,
          fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
        )),
      ),
    );
  }

  void _showCustomExerciseDialog(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppTheme.border)),
        title: Text('CUSTOM EXERCISE', style: GoogleFonts.barlow(color: AppTheme.neonGreen, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: GoogleFonts.dmSans(color: AppTheme.primary, fontSize: 14),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Exercise name...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: GoogleFonts.spaceMono(color: AppTheme.textMuted, fontSize: 10)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonGreen, foregroundColor: AppTheme.bg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                Navigator.pop(context);
                Navigator.pop(context);
                widget.onSelected(ctrl.text.trim().toUpperCase(), 'CUSTOM');
              }
            },
            child: Text('ADD', style: GoogleFonts.barlow(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
        ],
      ),
    );
  }
}

class _ExerciseTile extends StatelessWidget {
  final String name, category;
  final int delay;
  final VoidCallback onTap;
  const _ExerciseTile({required this.name, required this.category, required this.delay, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: AppTheme.neonGreen.withOpacity(0.05),
        highlightColor: AppTheme.neonGreen.withOpacity(0.03),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.fitness_center, color: AppTheme.textDim, size: 16),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(name, style: GoogleFonts.barlow(
                  color: AppTheme.primary, fontSize: 16, fontWeight: FontWeight.w700,
                )),
              ),
              const Icon(Icons.add, color: AppTheme.textMuted, size: 18),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms, delay: Duration(milliseconds: delay));
  }
}
