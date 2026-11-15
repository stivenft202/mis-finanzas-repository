import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'src/app/app.dart';
import 'src/core/base_de_datos/conexion.dart';
import 'src/core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La llave de cifrado se lee aquí, en el hilo principal, porque el
  // almacenamiento seguro del dispositivo no funciona en hilos secundarios.
  final clave = await obtenerClaveCifrado();
  // El tema guardado (claro/oscuro) también se lee al arrancar, para
  // que la app abra ya con el modo que la persona eligió.
  final temaGuardado =
      await const FlutterSecureStorage().read(key: 'tema_modo');
  final temaInicial = switch (temaGuardado) {
    'claro' => ThemeMode.light,
    'oscuro' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  runApp(
    ProviderScope(
      overrides: [
        claveCifradoProvider.overrideWithValue(clave),
        temaInicialProvider.overrideWithValue(temaInicial),
      ],
      child: const AppFinanzas(),
    ),
  );
}
