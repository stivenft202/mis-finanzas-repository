import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pruebas del módulo «Respaldo» (v0.4.0): exportar todos los datos a
/// un solo archivo e importarlos en otro equipo sin perder nada.
void main() {
  final noviembre = (DateTime(2026, 11, 1), DateTime(2026, 12, 1));

  /// Una base con datos propios: las 8 categorías de fábrica más una
  /// personalizada, un gasto y dos fijos (un gasto y un ingreso).
  Future<BaseDeDatos> baseConDatos() async {
    final base = BaseDeDatos(NativeDatabase.memory());
    final categoriaId = await base.crearCategoria(
      CategoriasCompanion.insert(
        nombre: 'Mascotas',
        colorValor: 0xFF123456,
        icono: const Value('otros'),
      ),
    );
    await base.crearGasto(
      GastosCompanion.insert(
        montoMenor: 45000,
        montoBaseMenor: 45000,
        fecha: DateTime(2026, 11, 3),
        categoriaId: categoriaId,
        descripcion: const Value('Comida del perro'),
        creadoEn: DateTime(2026, 11, 3),
        actualizadoEn: DateTime(2026, 11, 3),
      ),
    );
    await base.crearFijo(
      FijosCompanion.insert(
        tipo: 'gasto',
        nombre: 'Arriendo',
        montoMenor: 800000,
        diaDelMes: 5,
        creadoEn: DateTime(2026, 11, 1),
        actualizadoEn: DateTime(2026, 11, 1),
      ),
    );
    await base.crearFijo(
      FijosCompanion.insert(
        tipo: 'ingreso',
        nombre: 'Salario',
        montoMenor: 2500000,
        diaDelMes: 30,
        creadoEn: DateTime(2026, 11, 1),
        actualizadoEn: DateTime(2026, 11, 1),
      ),
    );
    return base;
  }

  test('el respaldo viaja completo de una base a otra por JSON', () async {
    final origen = await baseConDatos();
    final datos = await origen.exportarDatos();
    // El viaje real del archivo: se guarda como texto y se vuelve a leer.
    final texto = jsonEncode(datos);
    final recuperado = (jsonDecode(texto) as Map)
        .map((k, v) => MapEntry(k.toString(), v));

    final destino = BaseDeDatos(NativeDatabase.memory());
    await destino.importarDatos(recuperado);

    // Categorías: las 8 de fábrica más la personalizada, con su nombre.
    final categorias = await destino.verCategorias().first;
    expect(categorias, hasLength(9));
    expect(categorias.map((c) => c.nombre), contains('Mascotas'));

    // El gasto llegó con su monto y su descripción.
    expect(await destino.totalEntre(noviembre.$1, noviembre.$2), 45000);
    final gastos =
        await destino.verGastosEntre(noviembre.$1, noviembre.$2).first;
    expect(gastos, hasLength(1));
    expect(gastos.single.descripcion, 'Comida del perro');
    // Y sigue apuntando a la categoría correcta.
    final duenio = categorias.firstWhere((c) => c.id == gastos.single.categoriaId);
    expect(duenio.nombre, 'Mascotas');

    // Los fijos llegaron con sus totales.
    expect(await destino.totalFijos('gasto'), 800000);
    expect(await destino.totalFijos('ingreso'), 2500000);

    await origen.close();
    await destino.close();
  });

  test('importar reemplaza lo que había en el equipo destino', () async {
    final origen = await baseConDatos();
    final datos = await origen.exportarDatos();

    final destino = await baseConDatos();
    // El destino registra un gasto más, que no está en el archivo.
    final algunaCategoria = (await destino.verCategorias().first).first;
    await destino.crearGasto(
      GastosCompanion.insert(
        montoMenor: 999000,
        montoBaseMenor: 999000,
        fecha: DateTime(2026, 11, 10),
        categoriaId: algunaCategoria.id,
        descripcion: const Value('Gasto solo del destino'),
        creadoEn: DateTime(2026, 11, 10),
        actualizadoEn: DateTime(2026, 11, 10),
      ),
    );
    expect(await destino.totalEntre(noviembre.$1, noviembre.$2), 45000 + 999000);

    await destino.importarDatos(datos);

    // Tras importar, solo queda lo del archivo.
    expect(await destino.totalEntre(noviembre.$1, noviembre.$2), 45000);
    final gastos =
        await destino.verGastosEntre(noviembre.$1, noviembre.$2).first;
    expect(gastos.map((g) => g.descripcion), ['Comida del perro']);

    await origen.close();
    await destino.close();
  });

  test('un archivo que no es respaldo se rechaza y no borra nada', () async {
    final base = await baseConDatos();

    await expectLater(
      base.importarDatos({'aplicacion': 'otra-app', 'formato': 1}),
      throwsFormatException,
    );
    await expectLater(
      base.importarDatos({
        'aplicacion': 'finanzas-hogar',
        'formato': 1,
        'categorias': [],
        'gastos': [
          {'id': 1}, // Le faltan los datos obligatorios del gasto.
        ],
        'fijos': [],
      }),
      throwsFormatException,
    );

    // Nada se tocó: el gasto y los fijos siguen ahí.
    expect(await base.totalEntre(noviembre.$1, noviembre.$2), 45000);
    expect(await base.totalFijos('ingreso'), 2500000);

    await base.close();
  });
}
