import 'package:flutter/material.dart';

class ThemeSafeRoute {
  // Palette de couleurs premium néon-obscur
  static const Color bleuPrimaire = Color(0xFF00C8FF); // Cyan/Bleu électrique néon
  static const Color bleuAccent = Color(0xFF007AFF); // Bleu royal doux
  static const Color vertSecurite = Color(0xFF00E676); // Émeraude éclatant (Sûr)
  static const Color orangeDanger = Color(0xFFFF9100); // Orange néon (Dangers modérés)
  static const Color rougeDanger = Color(0xFFFF2A54); // Rouge cramoisi néon (SOS / Urgence)
  static const Color fondSombre = Color(0xFF0B0E14); // Obsidian profond
  static const Color couleurSurface = Color(0xFF161B22); // Gris mat sombre
  static const Color couleurSurfaceClaire = Color(0xFF21262D); // Gris de surbrillance
  static const Color textePrimaire = Color(0xFFF0F6FC); // Blanc cassé lumineux
  static const Color texteSecondaire = Color(0xFF8B949E); // Gris de soutien

  // Palette de couleurs Light Mode
  static const Color fondClair = Color(0xFFF4F6F9); 
  static const Color couleurSurfaceL = Color(0xFFFFFFFF);
  static const Color couleurSurfaceClaireL = Color(0xFFE9ECEF);
  static const Color textePrimaireL = Color(0xFF1A1D20);
  static const Color texteSecondaireL = Color(0xFF5A626A);

  static ThemeData themeSombre = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: bleuPrimaire,
    scaffoldBackgroundColor: fondSombre,
    fontFamily: 'sans-serif',
    
    colorScheme: const ColorScheme.dark(
      primary: bleuPrimaire,
      secondary: vertSecurite,
      error: rougeDanger,
      surface: couleurSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onError: Colors.white,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textePrimaire, letterSpacing: 0.5),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textePrimaire),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textePrimaire),
      bodyLarge: TextStyle(fontSize: 15, color: textePrimaire, height: 1.4),
      bodyMedium: TextStyle(fontSize: 13, color: texteSecondaire, height: 1.3),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: texteSecondaire, letterSpacing: 1.0),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: fondSombre,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textePrimaire,
        letterSpacing: 0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: couleurSurface,
      elevation: 8,
      shadowColor: Colors.black38,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: couleurSurface.withValues(alpha: 0.8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: bleuPrimaire, width: 1.5),
      ),
      hintStyle: const TextStyle(color: texteSecondaire, fontSize: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bleuAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shadowColor: bleuAccent.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: couleurSurface,
      foregroundColor: bleuPrimaire,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
    ),
  );

  static ThemeData themeClair = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: bleuAccent,
    scaffoldBackgroundColor: fondClair,
    fontFamily: 'sans-serif',
    
    colorScheme: const ColorScheme.light(
      primary: bleuAccent,
      secondary: vertSecurite,
      error: rougeDanger,
      surface: couleurSurfaceL,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onError: Colors.white,
    ),

    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textePrimaireL, letterSpacing: 0.5),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textePrimaireL),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textePrimaireL),
      bodyLarge: TextStyle(fontSize: 15, color: textePrimaireL, height: 1.4),
      bodyMedium: TextStyle(fontSize: 13, color: texteSecondaireL, height: 1.3),
      labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: texteSecondaireL, letterSpacing: 1.0),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: fondClair,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textePrimaireL,
        letterSpacing: 0.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: couleurSurfaceL,
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06), width: 1),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: couleurSurfaceL,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: bleuAccent, width: 1.5),
      ),
      hintStyle: const TextStyle(color: texteSecondaireL, fontSize: 14),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bleuAccent,
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shadowColor: bleuAccent.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: couleurSurfaceL,
      foregroundColor: bleuAccent,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.08), width: 1),
      ),
    ),
  );
}
