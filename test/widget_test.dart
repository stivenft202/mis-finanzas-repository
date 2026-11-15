import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finanzas_hogar/l10n/app_localizations.dart';
import 'package:finanzas_hogar/src/app/app.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/providers.dart';
import 'package:finanzas_hogar/src/core/seguridad/autenticacion.dart';
import 'package:finanzas_hogar/src/core/monedas/monedas.dart';
import 'package:finanzas_hogar/src/core/ui/titulo_appbar.dart';
import 'package:finanzas_hogar/src/features/acceso/pantalla_usuarios.dart';
import 'package:finanzas_hogar/src/features/gastos/pantalla_inicio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Almacén de secretos en memoria, para las pruebas de pantalla.
class AlmacenMemoriaPrueba implements AlmacenClaves {
  final Map<String, String> datos = {};

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> guardar(String clave, String valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> eliminar(String clave) async {
    datos.remove(clave);
  }
}

void main() {
  testWidgets('la pantalla de inicio muestra el total y el botón de agregar',
      (tester) async {
    final base = BaseDeDatos(NativeDatabase.memory());
    // Desde la Fase 5 la app pide acceso: la prueba entra ya con la
    // sesión de un administrador abierta.
    final admin = Usuario(
      id: 1,
      nombre: 'Esteban',
      rol: 'administrador',
      creadoEn: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          claveCifradoProvider.overrideWithValue('clave-de-prueba'),
          baseDeDatosProvider.overrideWithValue(base),
          usuariosProvider.overrideWith((ref) => Stream.value([admin])),
          accesoInicialProvider
              .overrideWithValue(const EstadoAcceso(usuarioId: 1)),
        ],
        child: const AppFinanzas(),
      ),
    );
    // La base de datos trabaja con asincronía real (otro hilo), así que
    // hay que dejarla trabajar fuera de la zona de tiempo simulado.
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 3));
    });
    await tester.pump();

    expect(find.text('Finanzas del Hogar'), findsWidgets);
    expect(find.text('Agregar gasto'), findsOneWidget);
    expect(find.textContaining('Gastos de este mes'), findsOneWidget);

    await tester.runAsync(() async {
      await base.close();
    });
  });

  testWidgets(
      'en un celular angosto, el título «Bloqueo automático» no se aprieta',
      (tester) async {
    // El celular de Esteban: 720x1600 a doble densidad = 360 de ancho.
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final base = BaseDeDatos(NativeDatabase.memory());
    final admin = Usuario(
      id: 1,
      nombre: 'Esteban',
      rol: 'administrador',
      creadoEn: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          claveCifradoProvider.overrideWithValue('clave-de-prueba'),
          baseDeDatosProvider.overrideWithValue(base),
          usuariosProvider.overrideWith((ref) => Stream.value([admin])),
          accesoInicialProvider
              .overrideWithValue(const EstadoAcceso(usuarioId: 1)),
          almacenClavesProvider.overrideWithValue(AlmacenMemoriaPrueba()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale('es'),
          home: PantallaUsuarios(),
        ),
      ),
    );
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await tester.pump();

    expect(find.text('Bloqueo automático'), findsOneWidget);
    // En la v0.6.0 el selector lateral dejaba el título en una columna
    // de una letra por línea: su ancho era de unos pocos píxeles.
    expect(
      tester.getSize(find.text('Bloqueo automático')).width,
      greaterThan(150),
    );
    expect(find.text('Tras 5 minutos sin usar'), findsOneWidget);

    await tester.runAsync(() async {
      await base.close();
    });
  });

  testWidgets(
      'la fila de un gasto con nombre largo no se aprieta en el celular',
      (tester) async {
    // El celular de Esteban: 720x1600 a doble densidad = 360 de ancho.
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    final base = BaseDeDatos(NativeDatabase.memory());
    late Gasto gasto;
    late Categoria categoria;
    await tester.runAsync(() async {
      final categoriaId = await base.into(base.categorias).insert(
            CategoriasCompanion.insert(
              nombre: 'Imprevistos y reparaciones',
              colorValor: 0xFF455A64,
              icono: const Value('imprevistos'),
            ),
          );
      categoria = await (base.select(base.categorias)
            ..where((c) => c.id.equals(categoriaId)))
          .getSingle();
      final ahora = DateTime(2026, 11, 14);
      final gastoId = await base.into(base.gastos).insert(
            GastosCompanion.insert(
              montoMenor: 10000,
              montoBaseMenor: 10000,
              fecha: ahora,
              categoriaId: categoriaId,
              descripcion: const Value('Imprevistos y reparaciones'),
              creadoEn: ahora,
              actualizadoEn: ahora,
            ),
          );
      gasto = await (base.select(base.gastos)
            ..where((g) => g.id.equals(gastoId)))
          .getSingle();
    });

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          body: TileGasto(gasto: gasto, categorias: [categoria]),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Imprevistos y reparaciones'), findsOneWidget);
    // Con el ListTile viejo el título quedaba en ~110 de ancho y la
    // palabra «reparaciones» se partía en dos; ahora debe pasar de 150.
    expect(
      tester.getSize(find.text('Imprevistos y reparaciones')).width,
      greaterThan(150),
    );
    // El formato real lo da formatoMoneda (con su espacio especial
    // entre el número y el $): se compara contra la función misma.
    expect(find.text(formatoMoneda(10000, 'COP')), findsOneWidget);

    await tester.runAsync(() async {
      await base.close();
    });
  });

  testWidgets('el título largo de una barra superior no se corta',
      (tester) async {
    // El celular de Esteban: 720x1600 a doble densidad = 360 de ancho.
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('es'),
        home: Scaffold(
          appBar: AppBar(
            leading: const BackButton(),
            title: const TituloAppBar('Ver gastos · noviembre 2026'),
          ),
          body: const SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // El texto completo está, sin el «…» que salía en la v0.6.2.
    expect(find.text('Ver gastos · noviembre 2026'), findsOneWidget);
    expect(find.textContaining('…'), findsNothing);
  });
}
