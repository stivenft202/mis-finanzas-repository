import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/features/gastos/resumen_mes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Atajo para crear gastos de prueba (solo importan fecha, monto base
/// y categoría).
Gasto gasto(DateTime fecha, int montoBase, {int categoriaId = 1}) {
  return Gasto(
    id: 0,
    montoMenor: montoBase,
    moneda: 'COP',
    tasaBase: 1.0,
    montoBaseMenor: montoBase,
    fecha: fecha,
    categoriaId: categoriaId,
    descripcion: '',
    hechoPor: 'Esteban',
    metodoPago: 'efectivo',
    creadoEn: fecha,
    actualizadoEn: fecha,
  );
}

void main() {
  final hoy = DateTime(2026, 11, 15);
  final noviembre = DateTime(2026, 11);

  group('resumen del mes (v0.7.2)', () {
    test('compara contra el mes pasado SOLO hasta el mismo día', () {
      final r = calcularResumenMes(
        gastosMes: [gasto(DateTime(2026, 11, 3), 30000)],
        gastosMesPrevio: [
          gasto(DateTime(2026, 10, 5), 10000),
          gasto(DateTime(2026, 10, 20), 50000), // después del 15: no cuenta
        ],
        mesReferencia: noviembre,
        hoy: hoy,
      );
      expect(r.totalMes, 30000);
      expect(r.totalPrevioComparable, 10000);
      expect(r.diferencia, 20000);
      expect(r.porcentajeDiferencia, 200);
      expect(r.hayPrevio, isTrue);
    });

    test('el promedio diario y la proyección de cierre salen del ritmo', () {
      // 45 000 al día 15 de un mes de 30 días: promedio 3 000 y, si el
      // ritmo sigue, el mes cierra en 90 000.
      final r = calcularResumenMes(
        gastosMes: [gasto(DateTime(2026, 11, 10), 45000)],
        gastosMesPrevio: const [],
        mesReferencia: noviembre,
        hoy: hoy,
      );
      expect(r.promedioDiario, 3000);
      expect(r.proyeccionCierre, 90000);
      expect(r.esMesActual, isTrue);
      expect(r.hayPrevio, isFalse);
      expect(r.porcentajeDiferencia, isNull);
    });

    test('la categoría que más pesa y su porcentaje', () {
      final r = calcularResumenMes(
        gastosMes: [
          gasto(DateTime(2026, 11, 2), 60000, categoriaId: 1),
          gasto(DateTime(2026, 11, 4), 40000, categoriaId: 2),
        ],
        gastosMesPrevio: const [],
        mesReferencia: noviembre,
        hoy: hoy,
      );
      expect(r.categoriaTopId, 1);
      expect(r.categoriaTopMonto, 60000);
      expect(r.categoriaTopPorcentaje, 60);
    });

    test('sin gastos: todo en cero y sin categoría mayor', () {
      final r = calcularResumenMes(
        gastosMes: const [],
        gastosMesPrevio: const [],
        mesReferencia: noviembre,
        hoy: hoy,
      );
      expect(r.totalMes, 0);
      expect(r.promedioDiario, 0);
      expect(r.proyeccionCierre, 0);
      expect(r.categoriaTopId, isNull);
      expect(r.categoriaTopPorcentaje, 0);
    });

    test('un mes ya cerrado compara el mes completo y no proyecta', () {
      final r = calcularResumenMes(
        gastosMes: [gasto(DateTime(2026, 10, 31), 31000)],
        gastosMesPrevio: [
          gasto(DateTime(2026, 9, 30), 30000),
          gasto(DateTime(2026, 9, 15), 10000),
        ],
        mesReferencia: DateTime(2026, 10),
        hoy: hoy,
      );
      expect(r.esMesActual, isFalse);
      expect(r.totalPrevioComparable, 40000); // septiembre completo
      expect(r.promedioDiario, 1000); // 31 000 / 31 días
      expect(r.proyeccionCierre, 31000); // ya cerró: es el total
    });

    test(
      'si el mes pasado fue más corto, entra completo en la comparación',
      () {
        // Marzo 31 contra febrero (28 días): febrero cuenta entero.
        final r = calcularResumenMes(
          gastosMes: [gasto(DateTime(2026, 3, 31), 62000)],
          gastosMesPrevio: [gasto(DateTime(2026, 2, 28), 31000)],
          mesReferencia: DateTime(2026, 3),
          hoy: DateTime(2026, 3, 31),
        );
        expect(r.totalPrevioComparable, 31000);
        expect(r.promedioDiario, 2000);
      },
    );
  });
}
