import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Home redirects to Workout as the main screen (matching screenshots)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/workout');
    });
    return const Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(child: CircularProgressIndicator(color: AppTheme.neonGreen, strokeWidth: 2)),
    );
  }
}
