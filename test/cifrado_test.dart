import 'dart:io';

import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/conexion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  test('la base cifrada se abre con su llave y no sin ella', () async {
    final carpeta = await Directory.systemTemp.createTemp('finanzas_test_');
    addTearDown(() async {
      if (await carpeta.exists()) {
        await carpeta.delete(recursive: true);
      }
    });
    final archivo = File(p.join(carpeta.path, 'finanzas.db'));
    const claveBuena =
        '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef';
    const claveMala =
        'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';

    // 1) Crear la base cifrada y guardar un dato reconocible.
    var base = BaseDeDatos(
      NativeDatabase(archivo, setup: (db) => aplicarCifrado(db, claveBuena)),
    );
    final categorias = await base.select(base.categorias).get();
    expect(categorias.length, 8);
    await base.close();

    // 2) El archivo en disco no debe mostrar los textos en claro.
    final bytes = await archivo.readAsBytes();
    expect(String.fromCharCodes(bytes), isNot(contains('Mercado y comida')));

    // 3) Con la misma llave, los datos se leen.
    base = BaseDeDatos(
      NativeDatabase(archivo, setup: (db) => aplicarCifrado(db, claveBuena)),
    );
    expect((await base.select(base.categorias).get()).length, 8);
    await base.close();

    // 4) Con otra llave, la lectura debe fallar.
    base = BaseDeDatos(
      NativeDatabase(archivo, setup: (db) => aplicarCifrado(db, claveMala)),
    );
    await expectLater(
      base.select(base.categorias).get(),
      throwsA(anything),
    );
    await base.close();
  });
}
