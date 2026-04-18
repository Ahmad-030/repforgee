import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color bg          = Color(0xFF0A0A0A);
  static const Color surface     = Color(0xFF111111);
  static const Color card        = Color(0xFF1A1A1A);
  static const Color card2       = Color(0xFF222222);
  static const Color neonGreen   = Color(0xFFCCFF00);
  static const Color neonBlue    = Color(0xFF00E5FF);
  static const Color neonPink    = Color(0xFFFF2D78);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color primary     = Color(0xFFFFFFFF); // ← alias used by screens
  static const Color textMuted   = Color(0xFF666666);
  static const Color textDim     = Color(0xFF444444);
  static const Color border      = Color(0xFF222222);
  static const Color borderBright= Color(0xFF333333);

  static void setSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: neonGreen,
      secondary: neonBlue,
      tertiary: neonPink,
      surface: surface,
    ),
    textTheme: _buildTextTheme(),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border, width: 1),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: primary),
      titleTextStyle: TextStyle(
        color: primary, fontSize: 16, fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0D0D0D),
      selectedItemColor: neonGreen,
      unselectedItemColor: textMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
      unselectedLabelStyle: TextStyle(fontSize: 9, letterSpacing: 1),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: neonGreen, width: 1.5),
      ),
      hintStyle: const TextStyle(color: textMuted, fontSize: 13),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1),
  );

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.barlow(
        color: primary, fontSize: 48,
        fontWeight: FontWeight.w900, letterSpacing: -1,
      ),
      displayMedium: GoogleFonts.barlow(
        color: primary, fontSize: 36,
        fontWeight: FontWeight.w900, letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.barlow(
        color: primary, fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineLarge: GoogleFonts.barlow(
        color: primary, fontSize: 24, fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.barlow(
        color: primary, fontSize: 20, fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.spaceMono(
        color: primary, fontSize: 14, fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
      titleMedium: GoogleFonts.spaceMono(
        color: neonGreen, fontSize: 11,
        fontWeight: FontWeight.w700, letterSpacing: 2,
      ),
      titleSmall: GoogleFonts.spaceMono(
        color: textMuted, fontSize: 10,
        fontWeight: FontWeight.w400, letterSpacing: 1.5,
      ),
      bodyLarge: GoogleFonts.dmSans(
        color: primary, fontSize: 16, fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.dmSans(
        color: textMuted, fontSize: 14, fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.dmSans(
        color: textMuted, fontSize: 12,
      ),
      labelLarge: GoogleFonts.spaceMono(
        color: primary, fontSize: 12,
        fontWeight: FontWeight.w700, letterSpacing: 1.5,
      ),
      labelMedium: GoogleFonts.spaceMono(
        color: textMuted, fontSize: 10, letterSpacing: 1.5,
      ),
    );
  }
}

// ── Reusable decorations ─────────────────────────────────────────────────────

BoxDecoration darkCardDecoration({
  Color? borderColor,
  double radius = 12,
  Color? color,
}) => BoxDecoration(
  color: color ?? AppTheme.card,
  borderRadius: BorderRadius.circular(radius),
  border: Border.all(color: borderColor ?? AppTheme.border, width: 1),
);

BoxDecoration glowCardDecoration(Color glowColor) => BoxDecoration(
  color: AppTheme.card,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(color: glowColor.withValues(alpha: 0.4), width: 1),
  boxShadow: [
    BoxShadow(
      color: glowColor.withValues(alpha: 0.08),
      blurRadius: 20, spreadRadius: 2,
    ),
  ],
);