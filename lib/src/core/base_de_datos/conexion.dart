/// Conexión cifrada a la base de datos local.
///
/// La base se cifra con SQLite3MultipleCiphers (el sucesor recomendado
/// por Drift del clásico SQLCipher): cifrado AES-256 de todo el archivo.
/// La llave se genera una sola vez, se guarda en el almacenamiento seguro
/// del dispositivo (flutter_secure_storage) y nunca sale de ahí.
///
/// Nota de diseño: la llave se lee en el hilo principal y se entrega a la
/// conexión, porque el almacenamiento seguro no está disponible en los
/// hilos secundarios donde Drift abre el archivo.
library;

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

const String _nombreClave = 'clave_cifrado_bd_v1';

/// Obtiene la llave de cifrado; si no existe, la crea y la guarda.
Future<String> obtenerClaveCifrado() async {
  const almacenamiento = FlutterSecureStorage();
  final existente = await almacenamiento.read(key: _nombreClave);
  if (existente != null && existente.isNotEmpty) return existente;
  final aleatorio = Random.secure();
  final bytes = List<int>.generate(32, (_) => aleatorio.nextInt(256));
  final clave = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  await almacenamiento.write(key: _nombreClave, value: clave);
  return clave;
}

/// Aplica el cifrado a una conexión SQLite recién abierta.
///
/// Se usa tanto en la app como en las pruebas automáticas.
void aplicarCifrado(Database base, String clave) {
  base.execute("PRAGMA cipher = 'sqlcipher';");
  // La llave es hexadecimal (sin comillas en su contenido): seguro de
  // interpolar porque la generamos nosotros en [obtenerClaveCifrado].
  base.execute("PRAGMA key = '$clave';");
  // Fuerza una lectura para comprobar que la llave abre la base.
  base.execute('SELECT count(*) FROM sqlite_master;');
}

/// Conexión perezosa a la base cifrada del dispositivo.
LazyDatabase conexionCifrada(String clave) {
  return LazyDatabase(() async {
    final carpeta = await getApplicationDocumentsDirectory();
    final archivo = File(p.join(carpeta.path, 'finanzas.db'));
    return NativeDatabase.createInBackground(
      archivo,
      setup: (base) => aplicarCifrado(base, clave),
    );
  });
}
