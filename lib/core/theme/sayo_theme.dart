import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'sayo_colors.dart';

class SayoTheme {
  SayoTheme._();

  static ThemeData get light {
    final textTheme = GoogleFonts.urbanistTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: SayoColors.cream,
      textTheme: textTheme.apply(
        bodyColor: SayoColors.gris,
        displayColor: SayoColors.gris,
      ),
      colorScheme: const ColorScheme.light(
        primary: SayoColors.cafe,
        onPrimary: SayoColors.white,
        secondary: SayoColors.cafeLight,
        onSecondary: SayoColors.white,
        surface: SayoColors.white,
        onSurface: SayoColors.gris,
        error: SayoColors.red,
        outline: SayoColors.beige,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.urbanist(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: SayoColors.gris,
        ),
        iconTheme: const IconThemeData(color: SayoColors.gris),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: SayoColors.cafe,
          foregroundColor: SayoColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: SayoColors.cafe,
          side: const BorderSide(color: SayoColors.beige, width: 1.5),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.urbanist(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: SayoColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SayoColors.beige),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SayoColors.beige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SayoColors.cafe, width: 2),
        ),
        hintStyle: GoogleFonts.urbanist(
          color: SayoColors.grisLight,
          fontSize: 15,
        ),
      ),
      cardTheme: CardThemeData(
        color: SayoColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: SayoColors.beige, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: SayoColors.white,
        selectedItemColor: SayoColors.cafe,
        unselectedItemColor: SayoColors.grisLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: SayoColors.divider,
        thickness: 0.5,
      ),
    );
  }
}
