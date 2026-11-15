/// Cálculo de la tarjeta «Así va tu mes» del inicio (v0.7.2):
/// comparación con el mes pasado a la misma fecha, ritmo diario,
/// proyección de cierre y la categoría que más pesa. Todo sale de los
/// gastos ya registrados, en la moneda base del hogar.
library;

import '../../core/base_de_datos/base_de_datos.dart';

class ResumenMes {
  const ResumenMes({
    required this.totalMes,
    required this.totalPrevioComparable,
    required this.promedioDiario,
    required this.proyeccionCierre,
    required this.esMesActual,
    required this.categoriaTopId,
    required this.categoriaTopMonto,
    required this.categoriaTopPorcentaje,
  });

  /// Total del mes de referencia (moneda base).
  final int totalMes;

  /// Total del mes anterior contando solo hasta el mismo día (si el
  /// mes de referencia ya cerró, el mes anterior completo).
  final int totalPrevioComparable;

  /// Gasto promedio por día hasta el día de corte.
  final int promedioDiario;

  /// Si el ritmo se mantiene, en cuánto cierra el mes. En un mes ya
  /// cerrado es el total mismo.
  final int proyeccionCierre;

  /// True si el mes de referencia es el mes en curso.
  final bool esMesActual;

  /// Categoría con más gasto del mes (null si no hay gastos).
  final int? categoriaTopId;
  final int categoriaTopMonto;

  /// Qué parte del total del mes es la categoría mayor (0 a 100).
  final int categoriaTopPorcentaje;

  /// Diferencia contra el mes pasado comparable (+ = se gasta más).
  int get diferencia => totalMes - totalPrevioComparable;

  /// Hay mes pasado con qué comparar.
  bool get hayPrevio => totalPrevioComparable > 0;

  /// Diferencia en porcentaje (null si no hay con qué comparar).
  double? get porcentajeDiferencia =>
      hayPrevio ? diferencia / totalPrevioComparable * 100 : null;
}

/// [gastosMes] son los del mes de [mesReferencia] y [gastosMesPrevio]
/// los del mes anterior; [hoy] decide el día de corte cuando el mes
/// de referencia es el actual.
ResumenMes calcularResumenMes({
  required List<Gasto> gastosMes,
  required List<Gasto> gastosMesPrevio,
  required DateTime mesReferencia,
  required DateTime hoy,
}) {
  final diasEnElMes = DateTime(
    mesReferencia.year,
    mesReferencia.month + 1,
    0,
  ).day;
  final esMesActual =
      mesReferencia.year == hoy.year && mesReferencia.month == hoy.month;
  final diaCorte = esMesActual ? hoy.day : diasEnElMes;

  final totalMes = gastosMes.fold<int>(0, (suma, g) => suma + g.montoBaseMenor);

  // Del mes anterior solo cuenta lo gastado hasta el mismo día (si
  // ese mes fue más corto, entra completo).
  final previo = DateTime(mesReferencia.year, mesReferencia.month - 1);
  final diasMesPrevio = DateTime(previo.year, previo.month + 1, 0).day;
  final diaLimitePrevio = diaCorte < diasMesPrevio ? diaCorte : diasMesPrevio;
  final totalPrevio = gastosMesPrevio
      .where((g) => g.fecha.day <= diaLimitePrevio)
      .fold<int>(0, (suma, g) => suma + g.montoBaseMenor);

  final promedio = diaCorte > 0 ? (totalMes / diaCorte).round() : 0;
  final proyeccion = esMesActual
      ? (totalMes / diaCorte * diasEnElMes).round()
      : totalMes;

  // La categoría que más pesa.
  int? topId;
  var topMonto = 0;
  if (totalMes > 0) {
    final porCategoria = <int, int>{};
    for (final g in gastosMes) {
      porCategoria[g.categoriaId] =
          (porCategoria[g.categoriaId] ?? 0) + g.montoBaseMenor;
    }
    for (final entrada in porCategoria.entries) {
      if (entrada.value > topMonto) {
        topMonto = entrada.value;
        topId = entrada.key;
      }
    }
  }
  final topPorcentaje = totalMes > 0 ? (topMonto / totalMes * 100).round() : 0;

  return ResumenMes(
    totalMes: totalMes,
    totalPrevioComparable: totalPrevio,
    promedioDiario: promedio,
    proyeccionCierre: proyeccion,
    esMesActual: esMesActual,
    categoriaTopId: topId,
    categoriaTopMonto: topMonto,
    categoriaTopPorcentaje: topPorcentaje,
  );
}
