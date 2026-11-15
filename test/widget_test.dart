import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/app/app.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
