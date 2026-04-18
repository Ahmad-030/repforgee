import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/workout_screen.dart';
import 'screens/history_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/awards_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'widgets/common_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D0D),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const RepForgeApp());
}

class RepForgeApp extends StatelessWidget {
  const RepForgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RepForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/splash',
      routes: {
        '/splash':   (_) => const SplashScreen(),
        '/home':     (_) => const HomeScreen(),
        '/workout':  (_) => const DoubleBackToExit(child: WorkoutScreen()),
        '/history':  (_) => const DoubleBackToExit(child: HistoryScreen()),
        '/progress': (_) => const DoubleBackToExit(child: ProgressScreen()),
        '/goals':    (_) => const DoubleBackToExit(child: GoalsScreen()),
        '/awards':   (_) => const DoubleBackToExit(child: AwardsScreen()),
        '/about':    (_) => const AboutScreen(),
        '/privacy':  (_) => const PrivacyPolicyScreen(),
      },
    );
  }
}
