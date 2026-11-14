import 'dart:io';

import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/providers.dart';
import 'package:finanzas_hogar/l10n/app_localizations.dart';
import 'package:finanzas_hogar/src/features/fijos/pantalla_fijos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late BaseDeDatos base;

  setUp(() {
    base = BaseDeDatos(NativeDatabase.memory());
  });

  tearDown(() async {
    await base.close();
  });

  Future<int> agregarFijo(
    String tipo,
    String nombre,
    int monto,
    int dia,
  ) {
    return base.crearFijo(
      FijosCompanion.insert(
        tipo: tipo,
        nombre: nombre,
        montoMenor: monto,
        diaDelMes: dia,
        creadoEn: DateTime.now(),
        actualizadoEn: DateTime.now(),
      ),
    );
  }

  test('los totales suman por tipo y la utilidad es ingresos menos gastos',
      () async {
    await agregarFijo('gasto', 'Arriendo', 800000, 5);
    await agregarFijo('gasto', 'Servicios', 200000, 10);
    await agregarFijo('ingreso', 'Salario', 2500000, 30);

    expect(await base.totalFijos('gasto'), 1000000);
    expect(await base.totalFijos('ingreso'), 2500000);
    final utilidad =
        (await base.totalFijos('ingreso')) - (await base.totalFijos('gasto'));
    expect(utilidad, 1500000);
  });

  test('los fijos se ordenan por día del mes', () async {
    await agregarFijo('gasto', 'Tarde', 100, 28);
    await agregarFijo('gasto', 'Temprano', 100, 3);
    final lista = await base.verFijos('gasto').first;
    expect(lista.map((f) => f.nombre), ['Temprano', 'Tarde']);
  });

  test('editar y eliminar un fijo actualiza el total', () async {
    final id = await agregarFijo('gasto', 'Internet', 90000, 15);
    final fijo = (await base.verFijos('gasto').first).single;
    await base.actualizarFijo(fijo.copyWith(montoMenor: 120000));
    expect(await base.totalFijos('gasto'), 120000);
    await base.eliminarFijo(id);
    expect(await base.totalFijos('gasto'), 0);
  });

  test('una base de la versión 1 se actualiza a la 2 sin perder datos',
      () async {
    final dir = await Directory.systemTemp.createTemp('finanzas_v1');
    final archivo = File('${dir.path}/finanzas.db');
    final cruda = sqlite3.open(archivo.path);
    cruda.execute('PRAGMA user_version = 1');
    cruda.execute('''
      CREATE TABLE categorias (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        color_valor INTEGER NOT NULL,
        icono TEXT NOT NULL DEFAULT 'otros',
        oculta INTEGER NOT NULL DEFAULT 0,
        tipo_factura TEXT NULL,
        orden INTEGER NOT NULL DEFAULT 0
      )''');
    cruda.execute('''
      CREATE TABLE gastos (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        monto_menor INTEGER NOT NULL,
        moneda TEXT NOT NULL DEFAULT 'COP',
        tasa_base REAL NOT NULL DEFAULT 1.0,
        monto_base_menor INTEGER NOT NULL,
        fecha INTEGER NOT NULL,
        categoria_id INTEGER NOT NULL,
        descripcion TEXT NOT NULL DEFAULT '',
        hecho_por TEXT NOT NULL DEFAULT 'Yo',
        metodo_pago TEXT NOT NULL DEFAULT 'efectivo',
        foto_ruta TEXT NULL,
        creado_en INTEGER NOT NULL,
        actualizado_en INTEGER NOT NULL
      )''');
    cruda.execute(
      "INSERT INTO categorias (id, nombre, color_valor) "
      "VALUES (1, 'Mercado y comida', 123)",
    );
    cruda.execute(
      'INSERT INTO gastos (id, monto_menor, monto_base_menor, fecha, '
      'categoria_id, creado_en, actualizado_en) '
      'VALUES (1, 32000, 32000, 1794000000, 1, 1794000000, 1794000000)',
    );
    cruda.dispose();

    final migrada = BaseDeDatos(NativeDatabase(archivo));
    final categorias = await migrada.select(migrada.categorias).get();
    expect(categorias.single.nombre, 'Mercado y comida');
    final gastos = await migrada.select(migrada.gastos).get();
    expect(gastos.single.montoMenor, 32000);
    // La tabla nueva existe y se puede usar.
    expect(await migrada.totalFijos('gasto'), 0);
    await migrada.crearFijo(
      FijosCompanion.insert(
        tipo: 'gasto',
        nombre: 'Arriendo',
        montoMenor: 800000,
        diaDelMes: 5,
        creadoEn: DateTime.now(),
        actualizadoEn: DateTime.now(),
      ),
    );
    expect(await migrada.totalFijos('gasto'), 800000);
    await migrada.close();
    await dir.delete(recursive: true);
  });

  /// Abre la pantalla de fijos directamente (sin tocar botones), con una
  /// ventana alta para que toda la lista quepa sin desplazar, y espera
  /// dentro de runAsync a que lleguen los datos reales de la base.
  Future<void> abrirPantallaFijos(
    WidgetTester tester,
    BaseDeDatos base,
  ) async {
    tester.view.physicalSize = const Size(800, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.runAsync(() async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            baseDeDatosProvider.overrideWithValue(base),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: Locale('es'),
            home: PantallaFijos(),
          ),
        ),
      );
      await tester.pump();
      await Future<void>.delayed(const Duration(seconds: 2));
      await tester.pump();
    });
  }

  testWidgets('con más ingresos que gastos, el resultado sale en verde',
      (tester) async {
    final baseWidget = BaseDeDatos(NativeDatabase.memory());
    await tester.runAsync(() async {
      await baseWidget.crearFijo(
        FijosCompanion.insert(
          tipo: 'gasto',
          nombre: 'Arriendo',
          montoMenor: 800000,
          diaDelMes: 5,
          creadoEn: DateTime.now(),
          actualizadoEn: DateTime.now(),
        ),
      );
      await baseWidget.crearFijo(
        FijosCompanion.insert(
          tipo: 'ingreso',
          nombre: 'Salario',
          montoMenor: 2500000,
          diaDelMes: 30,
          creadoEn: DateTime.now(),
          actualizadoEn: DateTime.now(),
        ),
      );
    });

    await abrirPantallaFijos(tester, baseWidget);

    expect(find.text('TOTAL GASTOS'), findsOneWidget);
    expect(find.text('TOTAL INGRESOS'), findsOneWidget);
    expect(find.text('UTILIDAD / DEUDA'), findsOneWidget);
    expect(find.text('Te sobra'), findsOneWidget);
    expect(find.textContaining('1.700.000'), findsOneWidget);
    final tarjeta = tester.widget<Card>(
      find
          .ancestor(
            of: find.text('UTILIDAD / DEUDA'),
            matching: find.byType(Card),
          )
          .first,
    );
    expect(tarjeta.color, const Color(0xFF2E7D32));

    await tester.runAsync(() async {
      await baseWidget.close();
    });
  });

  testWidgets('con más gastos que ingresos, el resultado sale en rojo',
      (tester) async {
    final baseWidget = BaseDeDatos(NativeDatabase.memory());
    await tester.runAsync(() async {
      await baseWidget.crearFijo(
        FijosCompanion.insert(
          tipo: 'gasto',
          nombre: 'Arriendo',
          montoMenor: 900000,
          diaDelMes: 5,
          creadoEn: DateTime.now(),
          actualizadoEn: DateTime.now(),
        ),
      );
      await baseWidget.crearFijo(
        FijosCompanion.insert(
          tipo: 'ingreso',
          nombre: 'Salario',
          montoMenor: 500000,
          diaDelMes: 30,
          creadoEn: DateTime.now(),
          actualizadoEn: DateTime.now(),
        ),
      );
    });

    await abrirPantallaFijos(tester, baseWidget);

    expect(find.text('UTILIDAD / DEUDA'), findsOneWidget);
    expect(find.text('Te falta'), findsOneWidget);
    expect(find.textContaining('400.000'), findsOneWidget);
    final tarjeta = tester.widget<Card>(
      find
          .ancestor(
            of: find.text('UTILIDAD / DEUDA'),
            matching: find.byType(Card),
          )
          .first,
    );
    expect(tarjeta.color, const Color(0xFFC62828));

    await tester.runAsync(() async {
      await baseWidget.close();
    });
  });
}
