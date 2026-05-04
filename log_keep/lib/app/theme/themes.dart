import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemeData {
  static const _lightFillColor = Colors.black87;
  static const _darkFillColor = Color(0xE6DCDCDC);

  static final Color _lightFocusColor = Colors.black.withValues(alpha: 0.12);
  static final Color _darkFocusColor = Colors.white.withValues(alpha: 0.12);

  static ThemeData lightThemeData =
      themeData(lightColorScheme, _lightFocusColor);
  static ThemeData darkThemeData = themeData(darkColorScheme, _darkFocusColor);

  static ThemeData themeData(ColorScheme colorScheme, Color focusColor) {
    return ThemeData(
      useMaterial3: false,
      colorScheme: colorScheme,
      textTheme: _textTheme.apply(
          bodyColor: colorScheme.onPrimary, displayColor: colorScheme.onPrimary),
      primaryColor: const Color(0xFF030303),
      appBarTheme: AppBarTheme(
        titleTextStyle: _textTheme.titleLarge
            ?.apply(color: colorScheme.onPrimary),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      iconTheme: IconThemeData(color: colorScheme.onPrimary),
      canvasColor: colorScheme.surface,
      scaffoldBackgroundColor: colorScheme.surface,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: focusColor,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color.alphaBlend(
          _lightFillColor.withValues(alpha: 0.80),
          _darkFillColor,
        ),
        contentTextStyle:
            _textTheme.titleMedium?.apply(color: _darkFillColor),
      ),
    );
  }

  static final ColorScheme lightColorScheme = ColorScheme.light(
    primary: const Color(0xFF000000),
    primaryContainer: const Color(0xFF117378),
    secondary: const Color(0xFFEFF3F3),
    secondaryContainer: const Color(0xFFFAFBFB),
    surface: const Color(0xFFFAFBFB),
    onPrimary: _lightFillColor,
    onSecondary: const Color(0xFF322942),
    onSurface: const Color(0xFF241E30),
    error: _lightFillColor,
    onError: _lightFillColor,
  ).copyWith(
    surface: const Color(0xFFE6EBEB),
    onPrimary: _lightFillColor,
  );

  static final ColorScheme darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFF18FAE2),
    primaryContainer: const Color(0xFF1CDEC9),
    secondary: const Color(0xFF1F797C),
    secondaryContainer: const Color(0xFF1B526F),
    surface: const Color(0xFF1F1929),
    onPrimary: _darkFillColor,
    onSecondary: _darkFillColor,
    onSurface: _darkFillColor,
    error: _darkFillColor,
    onError: _darkFillColor,
  ).copyWith(
    surface: const Color(0xFF1E302F),
  );

  static const _regular = FontWeight.w400;
  static const _medium = FontWeight.w500;
  static const _semiBold = FontWeight.w600;
  static const _bold = FontWeight.w700;

  static final TextTheme _textTheme = TextTheme(
    headlineMedium:
        GoogleFonts.montserrat(fontWeight: _bold, fontSize: 20.0),
    bodySmall: GoogleFonts.oswald(fontWeight: _semiBold, fontSize: 16.0),
    headlineSmall: GoogleFonts.oswald(fontWeight: _medium, fontSize: 16.0),
    titleMedium: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 16.0),
    labelSmall: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 12.0),
    bodyLarge: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 14.0),
    titleSmall: GoogleFonts.montserrat(fontWeight: _medium, fontSize: 14.0),
    bodyMedium: GoogleFonts.montserrat(fontWeight: _regular, fontSize: 16.0),
    titleLarge: GoogleFonts.montserrat(fontWeight: _bold, fontSize: 16.0),
    labelLarge:
        GoogleFonts.montserrat(fontWeight: _semiBold, fontSize: 14.0),
  );
}

BoxShadow heavyBoxShadow() {
  return const BoxShadow(
      color: Color(0xB3000000), offset: Offset(0, 4), blurRadius: 10.0);
}

BoxShadow commonBoxShadow() {
  return const BoxShadow(
      color: Colors.black26, offset: Offset(0, 2), blurRadius: 10.0);
}

BoxShadow slightBoxShadow() {
  return const BoxShadow(
      color: Colors.black26, offset: Offset(0, 1), blurRadius: 5.0);
}

BoxShadow minorBoxShadow() {
  return const BoxShadow(
      color: Colors.black12, offset: Offset(1, 1), blurRadius: 1.0);
}

/// Kept for SelectableText until migrated to contextMenuBuilder.
ToolbarOptions commonToolbarOptions() {
  return const ToolbarOptions(
      copy: true, selectAll: true, cut: false, paste: false);
}
