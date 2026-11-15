// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_de_datos.dart';

// ignore_for_file: type=lint
class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValorMeta = const VerificationMeta(
    'colorValor',
  );
  @override
  late final GeneratedColumn<int> colorValor = GeneratedColumn<int>(
    'color_valor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconoMeta = const VerificationMeta('icono');
  @override
  late final GeneratedColumn<String> icono = GeneratedColumn<String>(
    'icono',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('otros'),
  );
  static const VerificationMeta _ocultaMeta = const VerificationMeta('oculta');
  @override
  late final GeneratedColumn<bool> oculta = GeneratedColumn<bool>(
    'oculta',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("oculta" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tipoFacturaMeta = const VerificationMeta(
    'tipoFactura',
  );
  @override
  late final GeneratedColumn<String> tipoFactura = GeneratedColumn<String>(
    'tipo_factura',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordenMeta = const VerificationMeta('orden');
  @override
  late final GeneratedColumn<int> orden = GeneratedColumn<int>(
    'orden',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    colorValor,
    icono,
    oculta,
    tipoFactura,
    orden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('color_valor')) {
      context.handle(
        _colorValorMeta,
        colorValor.isAcceptableOrUnknown(data['color_valor']!, _colorValorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValorMeta);
    }
    if (data.containsKey('icono')) {
      context.handle(
        _iconoMeta,
        icono.isAcceptableOrUnknown(data['icono']!, _iconoMeta),
      );
    }
    if (data.containsKey('oculta')) {
      context.handle(
        _ocultaMeta,
        oculta.isAcceptableOrUnknown(data['oculta']!, _ocultaMeta),
      );
    }
    if (data.containsKey('tipo_factura')) {
      context.handle(
        _tipoFacturaMeta,
        tipoFactura.isAcceptableOrUnknown(
          data['tipo_factura']!,
          _tipoFacturaMeta,
        ),
      );
    }
    if (data.containsKey('orden')) {
      context.handle(
        _ordenMeta,
        orden.isAcceptableOrUnknown(data['orden']!, _ordenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      colorValor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_valor'],
      )!,
      icono: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icono'],
      )!,
      oculta: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}oculta'],
      )!,
      tipoFactura: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo_factura'],
      ),
      orden: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}orden'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nombre;

  /// Color en formato ARGB (el número que guarda Flutter en Color.value).
  final int colorValor;

  /// Clave del ícono, según `iconos_categoria.dart`.
  final String icono;

  /// Si está oculta, no aparece al registrar gastos pero conserva historial.
  final bool oculta;

  /// Tipo de factura asociado, si aplica (texto libre, opcional).
  final String? tipoFactura;

  /// Orden de aparición en las listas.
  final int orden;
  const Categoria({
    required this.id,
    required this.nombre,
    required this.colorValor,
    required this.icono,
    required this.oculta,
    this.tipoFactura,
    required this.orden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['color_valor'] = Variable<int>(colorValor);
    map['icono'] = Variable<String>(icono);
    map['oculta'] = Variable<bool>(oculta);
    if (!nullToAbsent || tipoFactura != null) {
      map['tipo_factura'] = Variable<String>(tipoFactura);
    }
    map['orden'] = Variable<int>(orden);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      colorValor: Value(colorValor),
      icono: Value(icono),
      oculta: Value(oculta),
      tipoFactura: tipoFactura == null && nullToAbsent
          ? const Value.absent()
          : Value(tipoFactura),
      orden: Value(orden),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      colorValor: serializer.fromJson<int>(json['colorValor']),
      icono: serializer.fromJson<String>(json['icono']),
      oculta: serializer.fromJson<bool>(json['oculta']),
      tipoFactura: serializer.fromJson<String?>(json['tipoFactura']),
      orden: serializer.fromJson<int>(json['orden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'colorValor': serializer.toJson<int>(colorValor),
      'icono': serializer.toJson<String>(icono),
      'oculta': serializer.toJson<bool>(oculta),
      'tipoFactura': serializer.toJson<String?>(tipoFactura),
      'orden': serializer.toJson<int>(orden),
    };
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    int? colorValor,
    String? icono,
    bool? oculta,
    Value<String?> tipoFactura = const Value.absent(),
    int? orden,
  }) => Categoria(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    colorValor: colorValor ?? this.colorValor,
    icono: icono ?? this.icono,
    oculta: oculta ?? this.oculta,
    tipoFactura: tipoFactura.present ? tipoFactura.value : this.tipoFactura,
    orden: orden ?? this.orden,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      colorValor: data.colorValor.present
          ? data.colorValor.value
          : this.colorValor,
      icono: data.icono.present ? data.icono.value : this.icono,
      oculta: data.oculta.present ? data.oculta.value : this.oculta,
      tipoFactura: data.tipoFactura.present
          ? data.tipoFactura.value
          : this.tipoFactura,
      orden: data.orden.present ? data.orden.value : this.orden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('colorValor: $colorValor, ')
          ..write('icono: $icono, ')
          ..write('oculta: $oculta, ')
          ..write('tipoFactura: $tipoFactura, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, colorValor, icono, oculta, tipoFactura, orden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.colorValor == this.colorValor &&
          other.icono == this.icono &&
          other.oculta == this.oculta &&
          other.tipoFactura == this.tipoFactura &&
          other.orden == this.orden);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<int> colorValor;
  final Value<String> icono;
  final Value<bool> oculta;
  final Value<String?> tipoFactura;
  final Value<int> orden;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.colorValor = const Value.absent(),
    this.icono = const Value.absent(),
    this.oculta = const Value.absent(),
    this.tipoFactura = const Value.absent(),
    this.orden = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    required int colorValor,
    this.icono = const Value.absent(),
    this.oculta = const Value.absent(),
    this.tipoFactura = const Value.absent(),
    this.orden = const Value.absent(),
  }) : nombre = Value(nombre),
       colorValor = Value(colorValor);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<int>? colorValor,
    Expression<String>? icono,
    Expression<bool>? oculta,
    Expression<String>? tipoFactura,
    Expression<int>? orden,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (colorValor != null) 'color_valor': colorValor,
      if (icono != null) 'icono': icono,
      if (oculta != null) 'oculta': oculta,
      if (tipoFactura != null) 'tipo_factura': tipoFactura,
      if (orden != null) 'orden': orden,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<int>? colorValor,
    Value<String>? icono,
    Value<bool>? oculta,
    Value<String?>? tipoFactura,
    Value<int>? orden,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      colorValor: colorValor ?? this.colorValor,
      icono: icono ?? this.icono,
      oculta: oculta ?? this.oculta,
      tipoFactura: tipoFactura ?? this.tipoFactura,
      orden: orden ?? this.orden,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (colorValor.present) {
      map['color_valor'] = Variable<int>(colorValor.value);
    }
    if (icono.present) {
      map['icono'] = Variable<String>(icono.value);
    }
    if (oculta.present) {
      map['oculta'] = Variable<bool>(oculta.value);
    }
    if (tipoFactura.present) {
      map['tipo_factura'] = Variable<String>(tipoFactura.value);
    }
    if (orden.present) {
      map['orden'] = Variable<int>(orden.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('colorValor: $colorValor, ')
          ..write('icono: $icono, ')
          ..write('oculta: $oculta, ')
          ..write('tipoFactura: $tipoFactura, ')
          ..write('orden: $orden')
          ..write(')'))
        .toString();
  }
}

class $GastosTable extends Gastos with TableInfo<$GastosTable, Gasto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GastosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _montoMenorMeta = const VerificationMeta(
    'montoMenor',
  );
  @override
  late final GeneratedColumn<int> montoMenor = GeneratedColumn<int>(
    'monto_menor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
    'moneda',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COP'),
  );
  static const VerificationMeta _tasaBaseMeta = const VerificationMeta(
    'tasaBase',
  );
  @override
  late final GeneratedColumn<double> tasaBase = GeneratedColumn<double>(
    'tasa_base',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _montoBaseMenorMeta = const VerificationMeta(
    'montoBaseMenor',
  );
  @override
  late final GeneratedColumn<int> montoBaseMenor = GeneratedColumn<int>(
    'monto_base_menor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categorias (id)',
    ),
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hechoPorMeta = const VerificationMeta(
    'hechoPor',
  );
  @override
  late final GeneratedColumn<String> hechoPor = GeneratedColumn<String>(
    'hecho_por',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Yo'),
  );
  static const VerificationMeta _metodoPagoMeta = const VerificationMeta(
    'metodoPago',
  );
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
    'metodo_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('efectivo'),
  );
  static const VerificationMeta _fotoRutaMeta = const VerificationMeta(
    'fotoRuta',
  );
  @override
  late final GeneratedColumn<String> fotoRuta = GeneratedColumn<String>(
    'foto_ruta',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    montoMenor,
    moneda,
    tasaBase,
    montoBaseMenor,
    fecha,
    categoriaId,
    descripcion,
    hechoPor,
    metodoPago,
    fotoRuta,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gastos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Gasto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('monto_menor')) {
      context.handle(
        _montoMenorMeta,
        montoMenor.isAcceptableOrUnknown(data['monto_menor']!, _montoMenorMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMenorMeta);
    }
    if (data.containsKey('moneda')) {
      context.handle(
        _monedaMeta,
        moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta),
      );
    }
    if (data.containsKey('tasa_base')) {
      context.handle(
        _tasaBaseMeta,
        tasaBase.isAcceptableOrUnknown(data['tasa_base']!, _tasaBaseMeta),
      );
    }
    if (data.containsKey('monto_base_menor')) {
      context.handle(
        _montoBaseMenorMeta,
        montoBaseMenor.isAcceptableOrUnknown(
          data['monto_base_menor']!,
          _montoBaseMenorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_montoBaseMenorMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoriaIdMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('hecho_por')) {
      context.handle(
        _hechoPorMeta,
        hechoPor.isAcceptableOrUnknown(data['hecho_por']!, _hechoPorMeta),
      );
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
        _metodoPagoMeta,
        metodoPago.isAcceptableOrUnknown(data['metodo_pago']!, _metodoPagoMeta),
      );
    }
    if (data.containsKey('foto_ruta')) {
      context.handle(
        _fotoRutaMeta,
        fotoRuta.isAcceptableOrUnknown(data['foto_ruta']!, _fotoRutaMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Gasto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Gasto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      montoMenor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_menor'],
      )!,
      moneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda'],
      )!,
      tasaBase: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tasa_base'],
      )!,
      montoBaseMenor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_base_menor'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      hechoPor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hecho_por'],
      )!,
      metodoPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metodo_pago'],
      )!,
      fotoRuta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_ruta'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $GastosTable createAlias(String alias) {
    return $GastosTable(attachedDatabase, alias);
  }
}

class Gasto extends DataClass implements Insertable<Gasto> {
  final int id;

  /// Monto en unidades menores de [moneda].
  final int montoMenor;

  /// Código de la moneda del gasto ('COP', 'USD', ...).
  final String moneda;

  /// Tasa usada para convertir a la moneda base (1.0 si es la misma).
  final double tasaBase;

  /// Equivalente en unidades menores de la moneda base del hogar.
  final int montoBaseMenor;
  final DateTime fecha;
  final int categoriaId;
  final String descripcion;

  /// Nombre de la persona que hizo el gasto (los usuarios con roles
  /// llegan en la Fase 2; por ahora es texto).
  final String hechoPor;

  /// 'efectivo', 'tarjeta', 'transferencia' u 'otro'.
  final String metodoPago;

  /// Ruta local de la foto de la factura, si la hay (Fase 6).
  final String? fotoRuta;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const Gasto({
    required this.id,
    required this.montoMenor,
    required this.moneda,
    required this.tasaBase,
    required this.montoBaseMenor,
    required this.fecha,
    required this.categoriaId,
    required this.descripcion,
    required this.hechoPor,
    required this.metodoPago,
    this.fotoRuta,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['monto_menor'] = Variable<int>(montoMenor);
    map['moneda'] = Variable<String>(moneda);
    map['tasa_base'] = Variable<double>(tasaBase);
    map['monto_base_menor'] = Variable<int>(montoBaseMenor);
    map['fecha'] = Variable<DateTime>(fecha);
    map['categoria_id'] = Variable<int>(categoriaId);
    map['descripcion'] = Variable<String>(descripcion);
    map['hecho_por'] = Variable<String>(hechoPor);
    map['metodo_pago'] = Variable<String>(metodoPago);
    if (!nullToAbsent || fotoRuta != null) {
      map['foto_ruta'] = Variable<String>(fotoRuta);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  GastosCompanion toCompanion(bool nullToAbsent) {
    return GastosCompanion(
      id: Value(id),
      montoMenor: Value(montoMenor),
      moneda: Value(moneda),
      tasaBase: Value(tasaBase),
      montoBaseMenor: Value(montoBaseMenor),
      fecha: Value(fecha),
      categoriaId: Value(categoriaId),
      descripcion: Value(descripcion),
      hechoPor: Value(hechoPor),
      metodoPago: Value(metodoPago),
      fotoRuta: fotoRuta == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoRuta),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory Gasto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Gasto(
      id: serializer.fromJson<int>(json['id']),
      montoMenor: serializer.fromJson<int>(json['montoMenor']),
      moneda: serializer.fromJson<String>(json['moneda']),
      tasaBase: serializer.fromJson<double>(json['tasaBase']),
      montoBaseMenor: serializer.fromJson<int>(json['montoBaseMenor']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      categoriaId: serializer.fromJson<int>(json['categoriaId']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      hechoPor: serializer.fromJson<String>(json['hechoPor']),
      metodoPago: serializer.fromJson<String>(json['metodoPago']),
      fotoRuta: serializer.fromJson<String?>(json['fotoRuta']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'montoMenor': serializer.toJson<int>(montoMenor),
      'moneda': serializer.toJson<String>(moneda),
      'tasaBase': serializer.toJson<double>(tasaBase),
      'montoBaseMenor': serializer.toJson<int>(montoBaseMenor),
      'fecha': serializer.toJson<DateTime>(fecha),
      'categoriaId': serializer.toJson<int>(categoriaId),
      'descripcion': serializer.toJson<String>(descripcion),
      'hechoPor': serializer.toJson<String>(hechoPor),
      'metodoPago': serializer.toJson<String>(metodoPago),
      'fotoRuta': serializer.toJson<String?>(fotoRuta),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  Gasto copyWith({
    int? id,
    int? montoMenor,
    String? moneda,
    double? tasaBase,
    int? montoBaseMenor,
    DateTime? fecha,
    int? categoriaId,
    String? descripcion,
    String? hechoPor,
    String? metodoPago,
    Value<String?> fotoRuta = const Value.absent(),
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => Gasto(
    id: id ?? this.id,
    montoMenor: montoMenor ?? this.montoMenor,
    moneda: moneda ?? this.moneda,
    tasaBase: tasaBase ?? this.tasaBase,
    montoBaseMenor: montoBaseMenor ?? this.montoBaseMenor,
    fecha: fecha ?? this.fecha,
    categoriaId: categoriaId ?? this.categoriaId,
    descripcion: descripcion ?? this.descripcion,
    hechoPor: hechoPor ?? this.hechoPor,
    metodoPago: metodoPago ?? this.metodoPago,
    fotoRuta: fotoRuta.present ? fotoRuta.value : this.fotoRuta,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  Gasto copyWithCompanion(GastosCompanion data) {
    return Gasto(
      id: data.id.present ? data.id.value : this.id,
      montoMenor: data.montoMenor.present
          ? data.montoMenor.value
          : this.montoMenor,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
      tasaBase: data.tasaBase.present ? data.tasaBase.value : this.tasaBase,
      montoBaseMenor: data.montoBaseMenor.present
          ? data.montoBaseMenor.value
          : this.montoBaseMenor,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      hechoPor: data.hechoPor.present ? data.hechoPor.value : this.hechoPor,
      metodoPago: data.metodoPago.present
          ? data.metodoPago.value
          : this.metodoPago,
      fotoRuta: data.fotoRuta.present ? data.fotoRuta.value : this.fotoRuta,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Gasto(')
          ..write('id: $id, ')
          ..write('montoMenor: $montoMenor, ')
          ..write('moneda: $moneda, ')
          ..write('tasaBase: $tasaBase, ')
          ..write('montoBaseMenor: $montoBaseMenor, ')
          ..write('fecha: $fecha, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('descripcion: $descripcion, ')
          ..write('hechoPor: $hechoPor, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('fotoRuta: $fotoRuta, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    montoMenor,
    moneda,
    tasaBase,
    montoBaseMenor,
    fecha,
    categoriaId,
    descripcion,
    hechoPor,
    metodoPago,
    fotoRuta,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Gasto &&
          other.id == this.id &&
          other.montoMenor == this.montoMenor &&
          other.moneda == this.moneda &&
          other.tasaBase == this.tasaBase &&
          other.montoBaseMenor == this.montoBaseMenor &&
          other.fecha == this.fecha &&
          other.categoriaId == this.categoriaId &&
          other.descripcion == this.descripcion &&
          other.hechoPor == this.hechoPor &&
          other.metodoPago == this.metodoPago &&
          other.fotoRuta == this.fotoRuta &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class GastosCompanion extends UpdateCompanion<Gasto> {
  final Value<int> id;
  final Value<int> montoMenor;
  final Value<String> moneda;
  final Value<double> tasaBase;
  final Value<int> montoBaseMenor;
  final Value<DateTime> fecha;
  final Value<int> categoriaId;
  final Value<String> descripcion;
  final Value<String> hechoPor;
  final Value<String> metodoPago;
  final Value<String?> fotoRuta;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  const GastosCompanion({
    this.id = const Value.absent(),
    this.montoMenor = const Value.absent(),
    this.moneda = const Value.absent(),
    this.tasaBase = const Value.absent(),
    this.montoBaseMenor = const Value.absent(),
    this.fecha = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.hechoPor = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.fotoRuta = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  GastosCompanion.insert({
    this.id = const Value.absent(),
    required int montoMenor,
    this.moneda = const Value.absent(),
    this.tasaBase = const Value.absent(),
    required int montoBaseMenor,
    required DateTime fecha,
    required int categoriaId,
    this.descripcion = const Value.absent(),
    this.hechoPor = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.fotoRuta = const Value.absent(),
    required DateTime creadoEn,
    required DateTime actualizadoEn,
  }) : montoMenor = Value(montoMenor),
       montoBaseMenor = Value(montoBaseMenor),
       fecha = Value(fecha),
       categoriaId = Value(categoriaId),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<Gasto> custom({
    Expression<int>? id,
    Expression<int>? montoMenor,
    Expression<String>? moneda,
    Expression<double>? tasaBase,
    Expression<int>? montoBaseMenor,
    Expression<DateTime>? fecha,
    Expression<int>? categoriaId,
    Expression<String>? descripcion,
    Expression<String>? hechoPor,
    Expression<String>? metodoPago,
    Expression<String>? fotoRuta,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (montoMenor != null) 'monto_menor': montoMenor,
      if (moneda != null) 'moneda': moneda,
      if (tasaBase != null) 'tasa_base': tasaBase,
      if (montoBaseMenor != null) 'monto_base_menor': montoBaseMenor,
      if (fecha != null) 'fecha': fecha,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (descripcion != null) 'descripcion': descripcion,
      if (hechoPor != null) 'hecho_por': hechoPor,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (fotoRuta != null) 'foto_ruta': fotoRuta,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  GastosCompanion copyWith({
    Value<int>? id,
    Value<int>? montoMenor,
    Value<String>? moneda,
    Value<double>? tasaBase,
    Value<int>? montoBaseMenor,
    Value<DateTime>? fecha,
    Value<int>? categoriaId,
    Value<String>? descripcion,
    Value<String>? hechoPor,
    Value<String>? metodoPago,
    Value<String?>? fotoRuta,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
  }) {
    return GastosCompanion(
      id: id ?? this.id,
      montoMenor: montoMenor ?? this.montoMenor,
      moneda: moneda ?? this.moneda,
      tasaBase: tasaBase ?? this.tasaBase,
      montoBaseMenor: montoBaseMenor ?? this.montoBaseMenor,
      fecha: fecha ?? this.fecha,
      categoriaId: categoriaId ?? this.categoriaId,
      descripcion: descripcion ?? this.descripcion,
      hechoPor: hechoPor ?? this.hechoPor,
      metodoPago: metodoPago ?? this.metodoPago,
      fotoRuta: fotoRuta ?? this.fotoRuta,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (montoMenor.present) {
      map['monto_menor'] = Variable<int>(montoMenor.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
    }
    if (tasaBase.present) {
      map['tasa_base'] = Variable<double>(tasaBase.value);
    }
    if (montoBaseMenor.present) {
      map['monto_base_menor'] = Variable<int>(montoBaseMenor.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (hechoPor.present) {
      map['hecho_por'] = Variable<String>(hechoPor.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (fotoRuta.present) {
      map['foto_ruta'] = Variable<String>(fotoRuta.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GastosCompanion(')
          ..write('id: $id, ')
          ..write('montoMenor: $montoMenor, ')
          ..write('moneda: $moneda, ')
          ..write('tasaBase: $tasaBase, ')
          ..write('montoBaseMenor: $montoBaseMenor, ')
          ..write('fecha: $fecha, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('descripcion: $descripcion, ')
          ..write('hechoPor: $hechoPor, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('fotoRuta: $fotoRuta, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

class $FijosTable extends Fijos with TableInfo<$FijosTable, Fijo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FijosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _montoMenorMeta = const VerificationMeta(
    'montoMenor',
  );
  @override
  late final GeneratedColumn<int> montoMenor = GeneratedColumn<int>(
    'monto_menor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monedaMeta = const VerificationMeta('moneda');
  @override
  late final GeneratedColumn<String> moneda = GeneratedColumn<String>(
    'moneda',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('COP'),
  );
  static const VerificationMeta _diaDelMesMeta = const VerificationMeta(
    'diaDelMes',
  );
  @override
  late final GeneratedColumn<int> diaDelMes = GeneratedColumn<int>(
    'dia_del_mes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tipo,
    nombre,
    descripcion,
    montoMenor,
    moneda,
    diaDelMes,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fijos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Fijo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('monto_menor')) {
      context.handle(
        _montoMenorMeta,
        montoMenor.isAcceptableOrUnknown(data['monto_menor']!, _montoMenorMeta),
      );
    } else if (isInserting) {
      context.missing(_montoMenorMeta);
    }
    if (data.containsKey('moneda')) {
      context.handle(
        _monedaMeta,
        moneda.isAcceptableOrUnknown(data['moneda']!, _monedaMeta),
      );
    }
    if (data.containsKey('dia_del_mes')) {
      context.handle(
        _diaDelMesMeta,
        diaDelMes.isAcceptableOrUnknown(data['dia_del_mes']!, _diaDelMesMeta),
      );
    } else if (isInserting) {
      context.missing(_diaDelMesMeta);
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualizadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Fijo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Fijo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      )!,
      montoMenor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monto_menor'],
      )!,
      moneda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moneda'],
      )!,
      diaDelMes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dia_del_mes'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $FijosTable createAlias(String alias) {
    return $FijosTable(attachedDatabase, alias);
  }
}

class Fijo extends DataClass implements Insertable<Fijo> {
  final int id;

  /// 'gasto' o 'ingreso'.
  final String tipo;
  final String nombre;
  final String descripcion;

  /// Monto en unidades menores de [moneda].
  final int montoMenor;

  /// Código de la moneda ('COP', 'USD', ...).
  final String moneda;

  /// Día del mes en que se repite (1 a 31).
  final int diaDelMes;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const Fijo({
    required this.id,
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.montoMenor,
    required this.moneda,
    required this.diaDelMes,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tipo'] = Variable<String>(tipo);
    map['nombre'] = Variable<String>(nombre);
    map['descripcion'] = Variable<String>(descripcion);
    map['monto_menor'] = Variable<int>(montoMenor);
    map['moneda'] = Variable<String>(moneda);
    map['dia_del_mes'] = Variable<int>(diaDelMes);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  FijosCompanion toCompanion(bool nullToAbsent) {
    return FijosCompanion(
      id: Value(id),
      tipo: Value(tipo),
      nombre: Value(nombre),
      descripcion: Value(descripcion),
      montoMenor: Value(montoMenor),
      moneda: Value(moneda),
      diaDelMes: Value(diaDelMes),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory Fijo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Fijo(
      id: serializer.fromJson<int>(json['id']),
      tipo: serializer.fromJson<String>(json['tipo']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String>(json['descripcion']),
      montoMenor: serializer.fromJson<int>(json['montoMenor']),
      moneda: serializer.fromJson<String>(json['moneda']),
      diaDelMes: serializer.fromJson<int>(json['diaDelMes']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tipo': serializer.toJson<String>(tipo),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String>(descripcion),
      'montoMenor': serializer.toJson<int>(montoMenor),
      'moneda': serializer.toJson<String>(moneda),
      'diaDelMes': serializer.toJson<int>(diaDelMes),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  Fijo copyWith({
    int? id,
    String? tipo,
    String? nombre,
    String? descripcion,
    int? montoMenor,
    String? moneda,
    int? diaDelMes,
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => Fijo(
    id: id ?? this.id,
    tipo: tipo ?? this.tipo,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    montoMenor: montoMenor ?? this.montoMenor,
    moneda: moneda ?? this.moneda,
    diaDelMes: diaDelMes ?? this.diaDelMes,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  Fijo copyWithCompanion(FijosCompanion data) {
    return Fijo(
      id: data.id.present ? data.id.value : this.id,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      montoMenor: data.montoMenor.present
          ? data.montoMenor.value
          : this.montoMenor,
      moneda: data.moneda.present ? data.moneda.value : this.moneda,
      diaDelMes: data.diaDelMes.present ? data.diaDelMes.value : this.diaDelMes,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Fijo(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('montoMenor: $montoMenor, ')
          ..write('moneda: $moneda, ')
          ..write('diaDelMes: $diaDelMes, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tipo,
    nombre,
    descripcion,
    montoMenor,
    moneda,
    diaDelMes,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Fijo &&
          other.id == this.id &&
          other.tipo == this.tipo &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.montoMenor == this.montoMenor &&
          other.moneda == this.moneda &&
          other.diaDelMes == this.diaDelMes &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class FijosCompanion extends UpdateCompanion<Fijo> {
  final Value<int> id;
  final Value<String> tipo;
  final Value<String> nombre;
  final Value<String> descripcion;
  final Value<int> montoMenor;
  final Value<String> moneda;
  final Value<int> diaDelMes;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  const FijosCompanion({
    this.id = const Value.absent(),
    this.tipo = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.montoMenor = const Value.absent(),
    this.moneda = const Value.absent(),
    this.diaDelMes = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
  });
  FijosCompanion.insert({
    this.id = const Value.absent(),
    required String tipo,
    required String nombre,
    this.descripcion = const Value.absent(),
    required int montoMenor,
    this.moneda = const Value.absent(),
    required int diaDelMes,
    required DateTime creadoEn,
    required DateTime actualizadoEn,
  }) : tipo = Value(tipo),
       nombre = Value(nombre),
       montoMenor = Value(montoMenor),
       diaDelMes = Value(diaDelMes),
       creadoEn = Value(creadoEn),
       actualizadoEn = Value(actualizadoEn);
  static Insertable<Fijo> custom({
    Expression<int>? id,
    Expression<String>? tipo,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<int>? montoMenor,
    Expression<String>? moneda,
    Expression<int>? diaDelMes,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tipo != null) 'tipo': tipo,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (montoMenor != null) 'monto_menor': montoMenor,
      if (moneda != null) 'moneda': moneda,
      if (diaDelMes != null) 'dia_del_mes': diaDelMes,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
    });
  }

  FijosCompanion copyWith({
    Value<int>? id,
    Value<String>? tipo,
    Value<String>? nombre,
    Value<String>? descripcion,
    Value<int>? montoMenor,
    Value<String>? moneda,
    Value<int>? diaDelMes,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
  }) {
    return FijosCompanion(
      id: id ?? this.id,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      montoMenor: montoMenor ?? this.montoMenor,
      moneda: moneda ?? this.moneda,
      diaDelMes: diaDelMes ?? this.diaDelMes,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (montoMenor.present) {
      map['monto_menor'] = Variable<int>(montoMenor.value);
    }
    if (moneda.present) {
      map['moneda'] = Variable<String>(moneda.value);
    }
    if (diaDelMes.present) {
      map['dia_del_mes'] = Variable<int>(diaDelMes.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FijosCompanion(')
          ..write('id: $id, ')
          ..write('tipo: $tipo, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('montoMenor: $montoMenor, ')
          ..write('moneda: $moneda, ')
          ..write('diaDelMes: $diaDelMes, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }
}

class $UsuariosTable extends Usuarios with TableInfo<$UsuariosTable, Usuario> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsuariosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
    'rol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('miembro'),
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nombre, rol, creadoEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usuarios';
  @override
  VerificationContext validateIntegrity(
    Insertable<Usuario> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('rol')) {
      context.handle(
        _rolMeta,
        rol.isAcceptableOrUnknown(data['rol']!, _rolMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_creadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Usuario map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Usuario(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      rol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol'],
      )!,
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $UsuariosTable createAlias(String alias) {
    return $UsuariosTable(attachedDatabase, alias);
  }
}

class Usuario extends DataClass implements Insertable<Usuario> {
  final int id;
  final String nombre;

  /// 'administrador', 'miembro' o 'lectura'.
  final String rol;
  final DateTime creadoEn;
  const Usuario({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    map['rol'] = Variable<String>(rol);
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  UsuariosCompanion toCompanion(bool nullToAbsent) {
    return UsuariosCompanion(
      id: Value(id),
      nombre: Value(nombre),
      rol: Value(rol),
      creadoEn: Value(creadoEn),
    );
  }

  factory Usuario.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Usuario(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      rol: serializer.fromJson<String>(json['rol']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'rol': serializer.toJson<String>(rol),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Usuario copyWith({
    int? id,
    String? nombre,
    String? rol,
    DateTime? creadoEn,
  }) => Usuario(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    rol: rol ?? this.rol,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Usuario copyWithCompanion(UsuariosCompanion data) {
    return Usuario(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      rol: data.rol.present ? data.rol.value : this.rol,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Usuario(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('rol: $rol, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, nombre, rol, creadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Usuario &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.rol == this.rol &&
          other.creadoEn == this.creadoEn);
}

class UsuariosCompanion extends UpdateCompanion<Usuario> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String> rol;
  final Value<DateTime> creadoEn;
  const UsuariosCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.rol = const Value.absent(),
    this.creadoEn = const Value.absent(),
  });
  UsuariosCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.rol = const Value.absent(),
    required DateTime creadoEn,
  }) : nombre = Value(nombre),
       creadoEn = Value(creadoEn);
  static Insertable<Usuario> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? rol,
    Expression<DateTime>? creadoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (rol != null) 'rol': rol,
      if (creadoEn != null) 'creado_en': creadoEn,
    });
  }

  UsuariosCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String>? rol,
    Value<DateTime>? creadoEn,
  }) {
    return UsuariosCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rol: rol ?? this.rol,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsuariosCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('rol: $rol, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDeDatos extends GeneratedDatabase {
  _$BaseDeDatos(QueryExecutor e) : super(e);
  $BaseDeDatosManager get managers => $BaseDeDatosManager(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $GastosTable gastos = $GastosTable(this);
  late final $FijosTable fijos = $FijosTable(this);
  late final $UsuariosTable usuarios = $UsuariosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categorias,
    gastos,
    fijos,
    usuarios,
  ];
}

typedef $$CategoriasTableCreateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  required String nombre,
  required int colorValor,
  Value<String> icono,
  Value<bool> oculta,
  Value<String?> tipoFactura,
  Value<int> orden,
});
typedef $$CategoriasTableUpdateCompanionBuilder = CategoriasCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<int> colorValor,
  Value<String> icono,
  Value<bool> oculta,
  Value<String?> tipoFactura,
  Value<int> orden,
});

final class $$CategoriasTableReferences
    extends BaseReferences<_$BaseDeDatos, $CategoriasTable, Categoria> {
  $$CategoriasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$GastosTable, List<Gasto>> _gastosRefsTable(
    _$BaseDeDatos db,
  ) => MultiTypedResultKey.fromTable(
    db.gastos,
    aliasName: 'categorias__id__gastos__categoria_id',
  );

  $$GastosTableProcessedTableManager get gastosRefs {
    final manager = $$GastosTableTableManager(
      $_db,
      $_db.gastos,
    ).filter((f) => f.categoriaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_gastosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriasTableFilterComposer
    extends Composer<_$BaseDeDatos, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValor => $composableBuilder(
    column: $table.colorValor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icono => $composableBuilder(
    column: $table.icono,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get oculta => $composableBuilder(
    column: $table.oculta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipoFactura => $composableBuilder(
    column: $table.tipoFactura,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> gastosRefs(
    Expression<bool> Function($$GastosTableFilterComposer f) f,
  ) {
    final $$GastosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableFilterComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$BaseDeDatos, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValor => $composableBuilder(
    column: $table.colorValor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icono => $composableBuilder(
    column: $table.icono,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get oculta => $composableBuilder(
    column: $table.oculta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipoFactura => $composableBuilder(
    column: $table.tipoFactura,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orden => $composableBuilder(
    column: $table.orden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<int> get colorValor => $composableBuilder(
    column: $table.colorValor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icono =>
      $composableBuilder(column: $table.icono, builder: (column) => column);

  GeneratedColumn<bool> get oculta =>
      $composableBuilder(column: $table.oculta, builder: (column) => column);

  GeneratedColumn<String> get tipoFactura => $composableBuilder(
    column: $table.tipoFactura,
    builder: (column) => column,
  );

  GeneratedColumn<int> get orden =>
      $composableBuilder(column: $table.orden, builder: (column) => column);

  Expression<T> gastosRefs<T extends Object>(
    Expression<T> Function($$GastosTableAnnotationComposer a) f,
  ) {
    final $$GastosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.gastos,
      getReferencedColumn: (t) => t.categoriaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GastosTableAnnotationComposer(
            $db: $db,
            $table: $db.gastos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (Categoria, $$CategoriasTableReferences),
          Categoria,
          PrefetchHooks Function({bool gastosRefs})
        > {
  $$CategoriasTableTableManager(_$BaseDeDatos db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> colorValor = const Value.absent(),
                Value<String> icono = const Value.absent(),
                Value<bool> oculta = const Value.absent(),
                Value<String?> tipoFactura = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nombre: nombre,
                colorValor: colorValor,
                icono: icono,
                oculta: oculta,
                tipoFactura: tipoFactura,
                orden: orden,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                required int colorValor,
                Value<String> icono = const Value.absent(),
                Value<bool> oculta = const Value.absent(),
                Value<String?> tipoFactura = const Value.absent(),
                Value<int> orden = const Value.absent(),
              }) => CategoriasCompanion.insert(
                id: id,
                nombre: nombre,
                colorValor: colorValor,
                icono: icono,
                oculta: oculta,
                tipoFactura: tipoFactura,
                orden: orden,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriasTable, Categoria>(table),
                  $$CategoriasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({gastosRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (gastosRefs) db.gastos],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (gastosRefs)
                    await $_getPrefetchedDataByColumns<
                      Categoria,
                      $CategoriasTable,
                      Gasto,
                      $GastosTable
                    >(
                      currentTable: table,
                      referencedTable: $$CategoriasTableReferences
                          ._gastosRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CategoriasTableReferences(db, table, p0).gastosRefs,
                      currentColumn: 'id',
                      referencedColumn: 'categoria_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, $$CategoriasTableReferences),
      Categoria,
      PrefetchHooks Function({bool gastosRefs})
    >;
typedef $$GastosTableCreateCompanionBuilder = GastosCompanion Function({
  Value<int> id,
  required int montoMenor,
  Value<String> moneda,
  Value<double> tasaBase,
  required int montoBaseMenor,
  required DateTime fecha,
  required int categoriaId,
  Value<String> descripcion,
  Value<String> hechoPor,
  Value<String> metodoPago,
  Value<String?> fotoRuta,
  required DateTime creadoEn,
  required DateTime actualizadoEn,
});
typedef $$GastosTableUpdateCompanionBuilder = GastosCompanion Function({
  Value<int> id,
  Value<int> montoMenor,
  Value<String> moneda,
  Value<double> tasaBase,
  Value<int> montoBaseMenor,
  Value<DateTime> fecha,
  Value<int> categoriaId,
  Value<String> descripcion,
  Value<String> hechoPor,
  Value<String> metodoPago,
  Value<String?> fotoRuta,
  Value<DateTime> creadoEn,
  Value<DateTime> actualizadoEn,
});

final class $$GastosTableReferences
    extends BaseReferences<_$BaseDeDatos, $GastosTable, Gasto> {
  $$GastosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriasTable _categoriaIdTable(_$BaseDeDatos db) =>
      db.categorias.createAlias('gastos__categoria_id__categorias__id');

  $$CategoriasTableProcessedTableManager get categoriaId {
    final $_column = $_itemColumn<int>('categoria_id')!;

    final manager = $$CategoriasTableTableManager(
      $_db,
      $_db.categorias,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoriaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GastosTableFilterComposer
    extends Composer<_$BaseDeDatos, $GastosTable> {
  $$GastosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoMenor => $composableBuilder(
    column: $table.montoMenor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tasaBase => $composableBuilder(
    column: $table.tasaBase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoBaseMenor => $composableBuilder(
    column: $table.montoBaseMenor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hechoPor => $composableBuilder(
    column: $table.hechoPor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoRuta => $composableBuilder(
    column: $table.fotoRuta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriasTableFilterComposer get categoriaId {
    final $$CategoriasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableFilterComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $GastosTable> {
  $$GastosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoMenor => $composableBuilder(
    column: $table.montoMenor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tasaBase => $composableBuilder(
    column: $table.tasaBase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoBaseMenor => $composableBuilder(
    column: $table.montoBaseMenor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hechoPor => $composableBuilder(
    column: $table.hechoPor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoRuta => $composableBuilder(
    column: $table.fotoRuta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriasTableOrderingComposer get categoriaId {
    final $$CategoriasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableOrderingComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $GastosTable> {
  $$GastosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get montoMenor => $composableBuilder(
    column: $table.montoMenor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moneda =>
      $composableBuilder(column: $table.moneda, builder: (column) => column);

  GeneratedColumn<double> get tasaBase =>
      $composableBuilder(column: $table.tasaBase, builder: (column) => column);

  GeneratedColumn<int> get montoBaseMenor => $composableBuilder(
    column: $table.montoBaseMenor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hechoPor =>
      $composableBuilder(column: $table.hechoPor, builder: (column) => column);

  GeneratedColumn<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoRuta =>
      $composableBuilder(column: $table.fotoRuta, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );

  $$CategoriasTableAnnotationComposer get categoriaId {
    final $$CategoriasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoriaId,
      referencedTable: $db.categorias,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriasTableAnnotationComposer(
            $db: $db,
            $table: $db.categorias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GastosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $GastosTable,
          Gasto,
          $$GastosTableFilterComposer,
          $$GastosTableOrderingComposer,
          $$GastosTableAnnotationComposer,
          $$GastosTableCreateCompanionBuilder,
          $$GastosTableUpdateCompanionBuilder,
          (Gasto, $$GastosTableReferences),
          Gasto,
          PrefetchHooks Function({bool categoriaId})
        > {
  $$GastosTableTableManager(_$BaseDeDatos db, $GastosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GastosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GastosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GastosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> montoMenor = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<double> tasaBase = const Value.absent(),
                Value<int> montoBaseMenor = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<int> categoriaId = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<String> hechoPor = const Value.absent(),
                Value<String> metodoPago = const Value.absent(),
                Value<String?> fotoRuta = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => GastosCompanion(
                id: id,
                montoMenor: montoMenor,
                moneda: moneda,
                tasaBase: tasaBase,
                montoBaseMenor: montoBaseMenor,
                fecha: fecha,
                categoriaId: categoriaId,
                descripcion: descripcion,
                hechoPor: hechoPor,
                metodoPago: metodoPago,
                fotoRuta: fotoRuta,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int montoMenor,
                Value<String> moneda = const Value.absent(),
                Value<double> tasaBase = const Value.absent(),
                required int montoBaseMenor,
                required DateTime fecha,
                required int categoriaId,
                Value<String> descripcion = const Value.absent(),
                Value<String> hechoPor = const Value.absent(),
                Value<String> metodoPago = const Value.absent(),
                Value<String?> fotoRuta = const Value.absent(),
                required DateTime creadoEn,
                required DateTime actualizadoEn,
              }) => GastosCompanion.insert(
                id: id,
                montoMenor: montoMenor,
                moneda: moneda,
                tasaBase: tasaBase,
                montoBaseMenor: montoBaseMenor,
                fecha: fecha,
                categoriaId: categoriaId,
                descripcion: descripcion,
                hechoPor: hechoPor,
                metodoPago: metodoPago,
                fotoRuta: fotoRuta,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GastosTable, Gasto>(table),
                  $$GastosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoriaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoriaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoriaId,
                        referencedTable: $$GastosTableReferences
                            ._categoriaIdTable(db),
                        referencedColumn: $$GastosTableReferences
                            ._categoriaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GastosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $GastosTable,
      Gasto,
      $$GastosTableFilterComposer,
      $$GastosTableOrderingComposer,
      $$GastosTableAnnotationComposer,
      $$GastosTableCreateCompanionBuilder,
      $$GastosTableUpdateCompanionBuilder,
      (Gasto, $$GastosTableReferences),
      Gasto,
      PrefetchHooks Function({bool categoriaId})
    >;
typedef $$FijosTableCreateCompanionBuilder = FijosCompanion Function({
  Value<int> id,
  required String tipo,
  required String nombre,
  Value<String> descripcion,
  required int montoMenor,
  Value<String> moneda,
  required int diaDelMes,
  required DateTime creadoEn,
  required DateTime actualizadoEn,
});
typedef $$FijosTableUpdateCompanionBuilder = FijosCompanion Function({
  Value<int> id,
  Value<String> tipo,
  Value<String> nombre,
  Value<String> descripcion,
  Value<int> montoMenor,
  Value<String> moneda,
  Value<int> diaDelMes,
  Value<DateTime> creadoEn,
  Value<DateTime> actualizadoEn,
});

class $$FijosTableFilterComposer extends Composer<_$BaseDeDatos, $FijosTable> {
  $$FijosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get montoMenor => $composableBuilder(
    column: $table.montoMenor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diaDelMes => $composableBuilder(
    column: $table.diaDelMes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FijosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $FijosTable> {
  $$FijosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get montoMenor => $composableBuilder(
    column: $table.montoMenor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get moneda => $composableBuilder(
    column: $table.moneda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diaDelMes => $composableBuilder(
    column: $table.diaDelMes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FijosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $FijosTable> {
  $$FijosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get montoMenor => $composableBuilder(
    column: $table.montoMenor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get moneda =>
      $composableBuilder(column: $table.moneda, builder: (column) => column);

  GeneratedColumn<int> get diaDelMes =>
      $composableBuilder(column: $table.diaDelMes, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);

  GeneratedColumn<DateTime> get actualizadoEn => $composableBuilder(
    column: $table.actualizadoEn,
    builder: (column) => column,
  );
}

class $$FijosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $FijosTable,
          Fijo,
          $$FijosTableFilterComposer,
          $$FijosTableOrderingComposer,
          $$FijosTableAnnotationComposer,
          $$FijosTableCreateCompanionBuilder,
          $$FijosTableUpdateCompanionBuilder,
          (Fijo, BaseReferences<_$BaseDeDatos, $FijosTable, Fijo>),
          Fijo,
          PrefetchHooks Function()
        > {
  $$FijosTableTableManager(_$BaseDeDatos db, $FijosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FijosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FijosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FijosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> descripcion = const Value.absent(),
                Value<int> montoMenor = const Value.absent(),
                Value<String> moneda = const Value.absent(),
                Value<int> diaDelMes = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
                Value<DateTime> actualizadoEn = const Value.absent(),
              }) => FijosCompanion(
                id: id,
                tipo: tipo,
                nombre: nombre,
                descripcion: descripcion,
                montoMenor: montoMenor,
                moneda: moneda,
                diaDelMes: diaDelMes,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tipo,
                required String nombre,
                Value<String> descripcion = const Value.absent(),
                required int montoMenor,
                Value<String> moneda = const Value.absent(),
                required int diaDelMes,
                required DateTime creadoEn,
                required DateTime actualizadoEn,
              }) => FijosCompanion.insert(
                id: id,
                tipo: tipo,
                nombre: nombre,
                descripcion: descripcion,
                montoMenor: montoMenor,
                moneda: moneda,
                diaDelMes: diaDelMes,
                creadoEn: creadoEn,
                actualizadoEn: actualizadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FijosTable, Fijo>(table),
                  BaseReferences<_$BaseDeDatos, $FijosTable, Fijo>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FijosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $FijosTable,
      Fijo,
      $$FijosTableFilterComposer,
      $$FijosTableOrderingComposer,
      $$FijosTableAnnotationComposer,
      $$FijosTableCreateCompanionBuilder,
      $$FijosTableUpdateCompanionBuilder,
      (Fijo, BaseReferences<_$BaseDeDatos, $FijosTable, Fijo>),
      Fijo,
      PrefetchHooks Function()
    >;
typedef $$UsuariosTableCreateCompanionBuilder = UsuariosCompanion Function({
  Value<int> id,
  required String nombre,
  Value<String> rol,
  required DateTime creadoEn,
});
typedef $$UsuariosTableUpdateCompanionBuilder = UsuariosCompanion Function({
  Value<int> id,
  Value<String> nombre,
  Value<String> rol,
  Value<DateTime> creadoEn,
});

class $$UsuariosTableFilterComposer
    extends Composer<_$BaseDeDatos, $UsuariosTable> {
  $$UsuariosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsuariosTableOrderingComposer
    extends Composer<_$BaseDeDatos, $UsuariosTable> {
  $$UsuariosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rol => $composableBuilder(
    column: $table.rol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creadoEn => $composableBuilder(
    column: $table.creadoEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsuariosTableAnnotationComposer
    extends Composer<_$BaseDeDatos, $UsuariosTable> {
  $$UsuariosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get rol =>
      $composableBuilder(column: $table.rol, builder: (column) => column);

  GeneratedColumn<DateTime> get creadoEn =>
      $composableBuilder(column: $table.creadoEn, builder: (column) => column);
}

class $$UsuariosTableTableManager
    extends
        RootTableManager<
          _$BaseDeDatos,
          $UsuariosTable,
          Usuario,
          $$UsuariosTableFilterComposer,
          $$UsuariosTableOrderingComposer,
          $$UsuariosTableAnnotationComposer,
          $$UsuariosTableCreateCompanionBuilder,
          $$UsuariosTableUpdateCompanionBuilder,
          (Usuario, BaseReferences<_$BaseDeDatos, $UsuariosTable, Usuario>),
          Usuario,
          PrefetchHooks Function()
        > {
  $$UsuariosTableTableManager(_$BaseDeDatos db, $UsuariosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsuariosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsuariosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsuariosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> rol = const Value.absent(),
                Value<DateTime> creadoEn = const Value.absent(),
              }) => UsuariosCompanion(
                id: id,
                nombre: nombre,
                rol: rol,
                creadoEn: creadoEn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String> rol = const Value.absent(),
                required DateTime creadoEn,
              }) => UsuariosCompanion.insert(
                id: id,
                nombre: nombre,
                rol: rol,
                creadoEn: creadoEn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UsuariosTable, Usuario>(table),
                  BaseReferences<_$BaseDeDatos, $UsuariosTable, Usuario>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsuariosTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDatos,
      $UsuariosTable,
      Usuario,
      $$UsuariosTableFilterComposer,
      $$UsuariosTableOrderingComposer,
      $$UsuariosTableAnnotationComposer,
      $$UsuariosTableCreateCompanionBuilder,
      $$UsuariosTableUpdateCompanionBuilder,
      (Usuario, BaseReferences<_$BaseDeDatos, $UsuariosTable, Usuario>),
      Usuario,
      PrefetchHooks Function()
    >;

class $BaseDeDatosManager {
  final _$BaseDeDatos _db;
  $BaseDeDatosManager(this._db);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$GastosTableTableManager get gastos =>
      $$GastosTableTableManager(_db, _db.gastos);
  $$FijosTableTableManager get fijos =>
      $$FijosTableTableManager(_db, _db.fijos);
  $$UsuariosTableTableManager get usuarios =>
      $$UsuariosTableTableManager(_db, _db.usuarios);
}
