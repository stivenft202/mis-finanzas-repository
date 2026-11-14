/// Tema visual de la app: letra grande, botones grandes y colores claros.
///
/// Pensado para que cualquier persona del hogar lo use sin esfuerzo:
/// textos desde 18 puntos y botones de al menos 56 de alto.
library;

import 'package:flutter/material.dart';

const Color colorSemilla = Color(0xFF2E7D32); // verde

TextTheme _textos(TextTheme base) {
  return base.copyWith(
    headlineLarge: base.headlineLarge?.copyWith(
      fontSize: 34,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: base.titleLarge?.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: base.titleMedium?.copyWith(fontSize: 19),
    bodyLarge: base.bodyLarge?.copyWith(fontSize: 18),
    bodyMedium: base.bodyMedium?.copyWith(fontSize: 16),
    labelLarge: base.labelLarge?.copyWith(fontSize: 18),
  );
}

ThemeData _tema(Brightness brillo) {
  final esquema = ColorScheme.fromSeed(
    seedColor: colorSemilla,
    brightness: brillo,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: esquema);
  return base.copyWith(
    textTheme: _textos(base.textTheme),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 56),
        textStyle: const TextStyle(fontSize: 18),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 56),
        textStyle: const TextStyle(fontSize: 18),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      extendedTextStyle: TextStyle(fontSize: 18),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

ThemeData temaClaro() => _tema(Brightness.light);
ThemeData temaOscuro() => _tema(Brightness.dark);
