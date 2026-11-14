import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/app.dart';
import 'src/core/base_de_datos/conexion.dart';
import 'src/core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // La llave de cifrado se lee aquí, en el hilo principal, porque el
  // almacenamiento seguro del dispositivo no funciona en hilos secundarios.
  final clave = await obtenerClaveCifrado();
  runApp(
    ProviderScope(
      overrides: [claveCifradoProvider.overrideWithValue(clave)],
      child: const AppFinanzas(),
    ),
  );
}
