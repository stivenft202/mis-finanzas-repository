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

/// Personas del hogar que pueden entrar a la app (Fase 5, v0.6.0).
///
/// Aquí solo vive lo público: el nombre y el rol. Las contraseñas y los
/// PIN nunca se guardan en la base: van con hash al almacenamiento
/// seguro del equipo (ver `core/seguridad/autenticacion.dart`).
class Usuarios extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get nombre => text().withLength(min: 1, max: 60)();

  /// 'administrador', 'miembro' o 'lectura'.
  TextColumn get rol => text().withDefault(const Constant('miembro'))();

  DateTimeColumn get creadoEn => dateTime()();
}

@DriftDatabase(tables: [Categorias, Gastos, Fijos, Usuarios])
class BaseDeDatos extends _$BaseDeDatos {
  BaseDeDatos(super.executor);

  @override
  int get schemaVersion => 3;

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
          if (desde < 3) {
            // v0.6.0: nacen los usuarios del hogar (roles y acceso).
            await m.createTable(usuarios);
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

  // ---------------- Usuarios del hogar ----------------

  /// Todas las personas del hogar, en orden alfabético.
  Stream<List<Usuario>> verUsuarios() {
    return (select(usuarios)
          ..orderBy([(u) => OrderingTerm.asc(u.nombre)]))
        .watch();
  }

  Future<List<Usuario>> listaUsuarios() => (select(usuarios)
        ..orderBy([(u) => OrderingTerm.asc(u.nombre)]))
      .get();

  Future<Usuario?> usuarioPorId(int id) =>
      (select(usuarios)..where((u) => u.id.equals(id))).getSingleOrNull();

  /// Busca por nombre, sin distinguir mayúsculas (para el acceso).
  Future<Usuario?> usuarioPorNombre(String nombre) async {
    final buscado = nombre.trim().toLowerCase();
    final todos = await listaUsuarios();
    for (final u in todos) {
      if (u.nombre.trim().toLowerCase() == buscado) return u;
    }
    return null;
  }

  Future<int> crearUsuario(UsuariosCompanion datos) =>
      into(usuarios).insert(datos);

  Future<bool> actualizarUsuario(Usuario usuario) =>
      update(usuarios).replace(usuario);

  Future<int> eliminarUsuario(int id) =>
      (delete(usuarios)..where((u) => u.id.equals(id))).go();

  Future<int> contarAdministradores() async {
    final todos = await listaUsuarios();
    return todos.where((u) => u.rol == 'administrador').length;
  }

  // ---------------- Respaldo (exportar / importar) ----------------

  /// Todos los datos del hogar en un mapa listo para guardar como JSON
  /// en un solo archivo (módulo «Respaldo», v0.4.0). Con ese archivo la
  /// persona pasa su app de un equipo a otro sin reingresar nada.
  ///
  /// Ojo: las personas (usuarios) y sus claves NO viajan en el respaldo,
  /// por seguridad: son de cada equipo y se crean en cada uno.
  Future<Map<String, Object?>> exportarDatos() async {
    final listaCategorias = await select(categorias).get();
    final listaGastos = await select(gastos).get();
    final listaFijos = await select(fijos).get();
    return {
      'aplicacion': 'finanzas-hogar',
      'formato': 1,
      'categorias': [
        for (final c in listaCategorias)
          {
            'id': c.id,
            'nombre': c.nombre,
            'colorValor': c.colorValor,
            'icono': c.icono,
            'oculta': c.oculta,
            'tipoFactura': c.tipoFactura,
            'orden': c.orden,
          },
      ],
      'gastos': [
        for (final g in listaGastos)
          {
            'id': g.id,
            'montoMenor': g.montoMenor,
            'moneda': g.moneda,
            'tasaBase': g.tasaBase,
            'montoBaseMenor': g.montoBaseMenor,
            'fecha': g.fecha.toIso8601String(),
            'categoriaId': g.categoriaId,
            'descripcion': g.descripcion,
            'hechoPor': g.hechoPor,
            'metodoPago': g.metodoPago,
            'fotoRuta': g.fotoRuta,
            'creadoEn': g.creadoEn.toIso8601String(),
            'actualizadoEn': g.actualizadoEn.toIso8601String(),
          },
      ],
      'fijos': [
        for (final f in listaFijos)
          {
            'id': f.id,
            'tipo': f.tipo,
            'nombre': f.nombre,
            'descripcion': f.descripcion,
            'montoMenor': f.montoMenor,
            'moneda': f.moneda,
            'diaDelMes': f.diaDelMes,
            'creadoEn': f.creadoEn.toIso8601String(),
            'actualizadoEn': f.actualizadoEn.toIso8601String(),
          },
      ],
    };
  }

  /// Reemplaza TODOS los datos actuales por los del [datos] (un mapa
  /// como el de [exportarDatos]). Primero revisa el archivo completo:
  /// si algo no cuadra, lanza [FormatException] y no toca nada.
  Future<void> importarDatos(Map<String, Object?> datos) async {
    if (datos['aplicacion'] != 'finanzas-hogar' || datos['formato'] != 1) {
      throw const FormatException('No es un archivo de respaldo válido.');
    }
    final crudasCategorias = datos['categorias'];
    final crudosGastos = datos['gastos'];
    final crudosFijos = datos['fijos'];
    if (crudasCategorias is! List ||
        crudosGastos is! List ||
        crudosFijos is! List) {
      throw const FormatException('Al archivo le faltan datos.');
    }

    Map<String, Object?> fila(Object? valor) {
      if (valor is Map) {
        return valor.map((k, v) => MapEntry(k.toString(), v));
      }
      throw const FormatException('Una fila del archivo está dañada.');
    }

    int entero(Map<String, Object?> f, String clave) {
      final v = f[clave];
      if (v is num) return v.toInt();
      throw FormatException('Falta el número «$clave» en el archivo.');
    }

    String texto(Map<String, Object?> f, String clave) {
      final v = f[clave];
      if (v is String) return v;
      throw FormatException('Falta el texto «$clave» en el archivo.');
    }

    DateTime fecha(Map<String, Object?> f, String clave) =>
        DateTime.parse(texto(f, clave));

    final nuevasCategorias = <CategoriasCompanion>[
      for (final cruda in crudasCategorias)
        () {
          final f = fila(cruda);
          return CategoriasCompanion(
            id: Value(entero(f, 'id')),
            nombre: Value(texto(f, 'nombre')),
            colorValor: Value(entero(f, 'colorValor')),
            icono: Value(f['icono']?.toString() ?? 'otros'),
            oculta: Value(f['oculta'] == true),
            tipoFactura: Value(f['tipoFactura']?.toString()),
            orden: Value(f['orden'] is num ? (f['orden'] as num).toInt() : 0),
          );
        }(),
    ];
    final nuevosGastos = <GastosCompanion>[
      for (final crudo in crudosGastos)
        () {
          final f = fila(crudo);
          return GastosCompanion(
            id: Value(entero(f, 'id')),
            montoMenor: Value(entero(f, 'montoMenor')),
            moneda: Value(f['moneda']?.toString() ?? 'COP'),
            tasaBase:
                Value(f['tasaBase'] is num ? (f['tasaBase'] as num).toDouble() : 1.0),
            montoBaseMenor: Value(entero(f, 'montoBaseMenor')),
            fecha: Value(fecha(f, 'fecha')),
            categoriaId: Value(entero(f, 'categoriaId')),
            descripcion: Value(f['descripcion']?.toString() ?? ''),
            hechoPor: Value(f['hechoPor']?.toString() ?? 'Yo'),
            metodoPago: Value(f['metodoPago']?.toString() ?? 'efectivo'),
            fotoRuta: Value(f['fotoRuta']?.toString()),
            creadoEn: Value(fecha(f, 'creadoEn')),
            actualizadoEn: Value(fecha(f, 'actualizadoEn')),
          );
        }(),
    ];
    final nuevosFijos = <FijosCompanion>[
      for (final crudo in crudosFijos)
        () {
          final f = fila(crudo);
          return FijosCompanion(
            id: Value(entero(f, 'id')),
            tipo: Value(texto(f, 'tipo')),
            nombre: Value(texto(f, 'nombre')),
            descripcion: Value(f['descripcion']?.toString() ?? ''),
            montoMenor: Value(entero(f, 'montoMenor')),
            moneda: Value(f['moneda']?.toString() ?? 'COP'),
            diaDelMes: Value(entero(f, 'diaDelMes')),
            creadoEn: Value(fecha(f, 'creadoEn')),
            actualizadoEn: Value(fecha(f, 'actualizadoEn')),
          );
        }(),
    ];

    await transaction(() async {
      await delete(gastos).go();
      await delete(fijos).go();
      await delete(categorias).go();
      await batch((b) {
        b.insertAll(categorias, nuevasCategorias);
        b.insertAll(gastos, nuevosGastos);
        b.insertAll(fijos, nuevosFijos);
      });
    });
  }
}
