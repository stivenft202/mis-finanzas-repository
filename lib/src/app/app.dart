/// La aplicación: une tema, idioma y pantalla de inicio.
library;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../features/gastos/pantalla_inicio.dart';
import 'tema.dart';

class AppFinanzas extends StatelessWidget {
  const AppFinanzas({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finanzas del Hogar',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      theme: temaClaro(),
      darkTheme: temaOscuro(),
      themeMode: ThemeMode.system,
      home: const PantallaInicio(),
    );
  }
}

/// Acceso corto a los textos traducidos desde cualquier pantalla.
extension TextosEnContexto on BuildContext {
  AppLocalizations get textos => AppLocalizations.of(this);
}
