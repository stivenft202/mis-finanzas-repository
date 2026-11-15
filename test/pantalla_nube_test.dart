import 'package:drift/native.dart';
import 'package:finanzas_hogar/l10n/app_localizations.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/providers.dart';
import 'package:finanzas_hogar/src/core/seguridad/autenticacion.dart';
import 'package:finanzas_hogar/src/features/nube/cliente_nube.dart';
import 'package:finanzas_hogar/src/features/nube/pantalla_nube.dart';
import 'package:finanzas_hogar/src/features/nube/servicio_nube.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'autenticacion_test.dart' show AlmacenMemoria;

/// Un cliente de nube que no se usa: la pantalla de prueba nunca
/// llega a hablar con él.
class _ClienteInerte implements ClienteNube {
  @override
  Future<SesionNube> crearCuenta(String correo, String clave) =>
      throw UnimplementedError();
  @override
  Future<SesionNube> entrar(String correo, String clave) =>
      throw UnimplementedError();
  @override
  Future<SesionNube> refrescar(SesionNube sesion) =>
      throw UnimplementedError();
  @override
  Future<DocNube?> leerDocumento(SesionNube sesion) async => null;
  @override
  Future<void> escribirDocumento(
    SesionNube sesion, {
    required String contenido,
    required DateTime generadoEn,
    required String origen,
  }) async {}
}

/// La pantalla de la nube (v0.8.0) se construye y, sin cuenta en
/// este equipo, ofrece crear la cuenta del hogar o entrar con ella.
void main() {
  testWidgets('sin cuenta, la pantalla ofrece crearla o entrar',
      (tester) async {
    final base = BaseDeDatos(NativeDatabase.memory());
    final almacen = AlmacenMemoria();
    final auth = ServicioAutenticacion(base, almacen);
    final servicio = ServicioNube(base, almacen, auth, _ClienteInerte());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          baseDeDatosProvider.overrideWithValue(base),
          almacenClavesProvider.overrideWithValue(almacen),
          servicioNubeProvider.overrideWithValue(servicio),
        ],
        child: const MaterialApp(
          locale: Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PantallaNube(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Nube del hogar'), findsOneWidget);
    expect(find.text('Correo de la cuenta del hogar'), findsOneWidget);
    expect(find.text('Crear cuenta del hogar'), findsOneWidget);
    expect(find.text('Ya tengo cuenta: entrar'), findsOneWidget);

    await base.close();
  });
}
