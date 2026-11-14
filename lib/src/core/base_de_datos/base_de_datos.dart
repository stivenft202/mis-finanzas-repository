/// Base de datos local de la app (SQLite con Drift).
///
/// Es la fuente principal de verdad: todo se guarda primero aquí, en el
/// dispositivo, y la sincronización con la nube (Fase 8) trabajará encima.
///
/// Convenciones:
/// - Los montos se guardan en *unidades menores* enteras (en COP, pesos;
///   en USD, centavos), nunca en decimales, para que las sumas sean exactas.
/// - Cada gasto guarda también su equivalente en la moneda base del hogar
///   y la tasa usada, para que el historial no se descuadre (Fase 4).
/// - `actualizadoEn` permite la resolución de conflictos de la Fase 8:
///   gana el cambio más reciente.
library;

import 'package:drift/drift.dart';

part 'base_de_datos.g.dart';

/// Categorías de gasto del hogar.
class Categorias extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 60)();

  /// Color en formato ARGB (el número que guarda Flutter en Color.value).
  IntColumn get colorValor => integer()();

  /// Clave del ícono, según `iconos_categoria.dart`.
  TextColumn get icono => text().withDefault(const Constant('otros'))();

  /// Si está oculta, no aparece al registrar gastos pero conserva historial.
  BoolColumn get oculta => boolean().withDefault(const Constant(false))();

  /// Tipo de factura asociado, si aplica (texto libre, opcional).
  TextColumn get tipoFactura => text().nullable()();

  /// Orden de aparición en las listas.
  IntColumn get orden => integer().withDefault(const Constant(0))();
}

/// Gastos registrados por las personas del hogar.
class Gastos extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Monto en unidades menores de [moneda].
  IntColumn get montoMenor => integer()();

  /// Código de la moneda del gasto ('COP', 'USD', ...).
  TextColumn get moneda => text().withDefault(const Constant('COP'))();

  /// Tasa usada para convertir a la moneda base (1.0 si es la misma).
  RealColumn get tasaBase => real().withDefault(const Constant(1.0))();

  /// Equivalente en unidades menores de la moneda base del hogar.
  IntColumn get montoBaseMenor => integer()();

  DateTimeColumn get fecha => dateTime()();
  IntColumn get categoriaId => integer().references(Categorias, #id)();
  TextColumn get descripcion => text().withDefault(const Constant(''))();

  /// Nombre de la persona que hizo el gasto (los usuarios con roles
  /// llegan en la Fase 2; por ahora es texto).
  TextColumn get hechoPor => text().withDefault(const Constant('Yo'))();

  /// 'efectivo', 'tarjeta', 'transferencia' u 'otro'.
  TextColumn get metodoPago => text().withDefault(const Constant('efectivo'))();

  /// Ruta local de la foto de la factura, si la hay (Fase 6).
  TextColumn get fotoRuta => text().nullable()();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
}

/// Gastos e ingresos FIJOS de cada mes (módulo «Fijos del mes», v0.3.0).
///
/// Son las plantillas del presupuesto mensual: el arriendo, el salario,
/// etc. No se descuentan solos de los gastos del mes; los recordatorios
/// y el «marcar como pagado» llegan con la fase de recurrentes.
class Fijos extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// 'gasto' o 'ingreso'.
  TextColumn get tipo => text()();

  TextColumn get nombre => text().withLength(min: 1, max: 60)();
  TextColumn get descripcion => text().withDefault(const Constant(''))();

  /// Monto en unidades menores de [moneda].
  IntColumn get montoMenor => integer()();

  /// Código de la moneda ('COP', 'USD', ...).
  TextColumn get moneda => text().withDefault(const Constant('COP'))();

  /// Día del mes en que se repite (1 a 31).
  IntColumn get diaDelMes => integer()();

  DateTimeColumn get creadoEn => dateTime()();
  DateTimeColumn get actualizadoEn => dateTime()();
}

@DriftDatabase(tables: [Categorias, Gastos, Fijos])
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _sembrarCategorias();
        },
        onUpgrade: (m, desde, hasta) async {
          if (desde < 2) {
            // v0.3.0: nace la tabla de gastos e ingresos fijos.
            await m.createTable(fijos);
          }
        },
      );

  /// Las 8 categorías iniciales que pidió Esteban (Fase 0/1).
  Future<void> _sembrarCategorias() async {
    const iniciales = <(String, int, String, String?)>[
      ('Mercado y comida', 0xFF2E7D32, 'mercado', 'mercado'),
      ('Servicios públicos e internet/TV', 0xFF1565C0, 'servicios', 'servicios'),
      ('Transporte y combustible', 0xFFEF6C00, 'transporte', null),
      ('Salud y medicinas', 0xFFC62828, 'salud', null),
      ('Educación e hijos', 0xFF6A1B9A, 'educacion', null),
      ('Imprevistos y reparaciones', 0xFF455A64, 'imprevistos', null),
      ('Ocio y salidas', 0xFFAD1457, 'ocio', null),
      ('Deudas y créditos', 0xFF4E342E, 'deudas', 'creditos'),
    ];
    await batch((b) {
      for (var i = 0; i < iniciales.length; i++) {
        final (nombre, color, icono, tipo) = iniciales[i];
        b.insert(
          categorias,
          CategoriasCompanion.insert(
            nombre: nombre,
            colorValor: color,
            icono: Value(icono),
            tipoFactura: Value(tipo),
            orden: Value(i),
          ),
        );
      }
    });
  }

  // ---------------- Categorías ----------------

  /// Categorías en orden; por defecto solo las visibles.
  Stream<List<Categoria>> verCategorias({bool soloVisibles = false}) {
    final consulta = select(categorias)
      ..orderBy([(c) => OrderingTerm.asc(c.orden), (c) => OrderingTerm.asc(c.nombre)]);
    if (soloVisibles) {
      consulta.where((c) => c.oculta.equals(false));
    }
    return consulta.watch();
  }

  Future<int> crearCategoria(CategoriasCompanion datos) =>
      into(categorias).insert(datos);

  Future<bool> actualizarCategoria(Categoria categoria) =>
      update(categorias).replace(categoria);

  Future<int> eliminarCategoria(int id) =>
      (delete(categorias)..where((c) => c.id.equals(id))).go();

  Future<int> contarGastosDeCategoria(int categoriaId) async {
    final conteo = gastos.id.count();
    final fila = await (selectOnly(gastos)
          ..addColumns([conteo])
          ..where(gastos.categoriaId.equals(categoriaId)))
        .getSingle();
    return fila.read(conteo) ?? 0;
  }

  // ---------------- Gastos ----------------

  /// Gastos de un rango de fechas, del más reciente al más antiguo.
  Stream<List<Gasto>> verGastosEntre(DateTime desde, DateTime hastaExclusivo) {
    return (select(gastos)
          ..where((g) =>
              g.fecha.isBiggerOrEqualValue(desde) &
              g.fecha.isSmallerThanValue(hastaExclusivo))
          ..orderBy([(g) => OrderingTerm.desc(g.fecha), (g) => OrderingTerm.desc(g.id)]))
        .watch();
  }

  /// Total (en la moneda base) de los gastos de un rango.
  Future<int> totalEntre(DateTime desde, DateTime hastaExclusivo) async {
    final filas = await (select(gastos)
          ..where((g) =>
              g.fecha.isBiggerOrEqualValue(desde) &
              g.fecha.isSmallerThanValue(hastaExclusivo)))
        .get();
    return filas.fold<int>(0, (suma, g) => suma + g.montoBaseMenor);
  }

  Future<int> crearGasto(GastosCompanion datos) => into(gastos).insert(datos);

  Future<bool> actualizarGasto(Gasto gasto) => update(gastos).replace(gasto);

  Future<int> eliminarGasto(int id) =>
      (delete(gastos)..where((g) => g.id.equals(id))).go();

  // ---------------- Fijos (gastos e ingresos de cada mes) ----------------

  /// Fijos de un tipo ('gasto' o 'ingreso'), ordenados por día del mes.
  Stream<List<Fijo>> verFijos(String tipo) {
    return (select(fijos)
          ..where((f) => f.tipo.equals(tipo))
          ..orderBy([
            (f) => OrderingTerm.asc(f.diaDelMes),
            (f) => OrderingTerm.asc(f.nombre),
          ]))
        .watch();
  }

  /// Suma de los montos de un tipo de fijo.
  Future<int> totalFijos(String tipo) async {
    final filas =
        await (select(fijos)..where((f) => f.tipo.equals(tipo))).get();
    return filas.fold<int>(0, (suma, f) => suma + f.montoMenor);
  }

  Future<int> crearFijo(FijosCompanion datos) => into(fijos).insert(datos);

  Future<bool> actualizarFijo(Fijo fijo) => update(fijos).replace(fijo);

  Future<int> eliminarFijo(int id) =>
      (delete(fijos)..where((f) => f.id.equals(id))).go();
}
