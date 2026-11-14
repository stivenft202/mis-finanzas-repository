import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/utilidades/fechas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BaseDeDatos base;

  setUp(() {
    base = BaseDeDatos(NativeDatabase.memory());
  });

  tearDown(() async {
    await base.close();
  });

  Future<int> primeraCategoriaId() async {
    final categorias = await base.select(base.categorias).get();
    return categorias.first.id;
  }

  Future<int> agregarGasto(int monto, DateTime fecha, int categoriaId) {
    return base.crearGasto(
      GastosCompanion.insert(
        montoMenor: monto,
        montoBaseMenor: monto,
        fecha: fecha,
        categoriaId: categoriaId,
        creadoEn: DateTime.now(),
        actualizadoEn: DateTime.now(),
      ),
    );
  }

  test('al crear la base vienen las 8 categorías iniciales', () async {
    final categorias = await base.select(base.categorias).get();
    expect(categorias.length, 8);
    expect(
      categorias.map((c) => c.nombre),
      containsAll([
        'Mercado y comida',
        'Servicios públicos e internet/TV',
        'Transporte y combustible',
        'Salud y medicinas',
        'Educación e hijos',
        'Imprevistos y reparaciones',
        'Ocio y salidas',
        'Deudas y créditos',
      ]),
    );
  });

  test('el total del mes suma solo los gastos de ese mes', () async {
    final cat = await primeraCategoriaId();
    final noviembre = DateTime(2026, 11, 10);
    await agregarGasto(45000, noviembre, cat);
    await agregarGasto(12000, noviembre.add(const Duration(days: 2)), cat);
    await agregarGasto(99999, DateTime(2026, 10, 31), cat); // otro mes

    final total = await base.totalEntre(
      inicioDelMes(noviembre),
      finDelMes(noviembre),
    );
    expect(total, 57000);
  });

  test('eliminar un gasto baja el total', () async {
    final cat = await primeraCategoriaId();
    final fecha = DateTime(2026, 11, 5);
    final id = await agregarGasto(20000, fecha, cat);
    await base.eliminarGasto(id);
    final total = await base.totalEntre(inicioDelMes(fecha), finDelMes(fecha));
    expect(total, 0);
  });

  test('una categoría oculta no sale en la lista de visibles', () async {
    final visibles =
        await base.verCategorias(soloVisibles: true).first;
    expect(visibles.length, 8);
    final primera = visibles.first;
    await base.actualizarCategoria(primera.copyWith(oculta: true));
    final visibles2 =
        await base.verCategorias(soloVisibles: true).first;
    expect(visibles2.length, 7);
    final todas = await base.verCategorias().first;
    expect(todas.length, 8);
  });

  test('contar gastos de una categoría', () async {
    final cat = await primeraCategoriaId();
    await agregarGasto(1000, DateTime(2026, 11, 1), cat);
    await agregarGasto(2000, DateTime(2026, 11, 2), cat);
    expect(await base.contarGastosDeCategoria(cat), 2);
  });
}
