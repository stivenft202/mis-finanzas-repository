/// Proveedores de Riverpod: el puente entre las pantallas y los datos.
///
/// Las pantallas nunca tocan la base de datos directamente: miran estos
/// proveedores, y cuando los datos cambian, la pantalla se actualiza sola.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'base_de_datos/base_de_datos.dart';
import 'base_de_datos/conexion.dart';
import 'utilidades/fechas.dart';

/// Llave de cifrado de la base. Se lee en `main()` antes de abrir la app
/// y se inyecta aquí (el almacenamiento seguro no funciona en hilos
/// secundarios, por eso no se lee dentro de la conexión).
final claveCifradoProvider = Provider<String>(
  (ref) => throw UnimplementedError(
    'claveCifradoProvider debe sobreescribirse en main()',
  ),
);

/// La base de datos de la app (una sola para toda la sesión).
final baseDeDatosProvider = Provider<BaseDeDatos>((ref) {
  final clave = ref.watch(claveCifradoProvider);
  final base = BaseDeDatos(conexionCifrada(clave));
  ref.onDispose(base.close);
  return base;
});

/// Mes que se está mirando en las pantallas (por defecto, el actual).
class MesSeleccionado extends Notifier<DateTime> {
  @override
  DateTime build() => inicioDelMes(DateTime.now());

  void cambiar(DateTime mes) => state = inicioDelMes(mes);
}

final mesSeleccionadoProvider =
    NotifierProvider<MesSeleccionado, DateTime>(MesSeleccionado.new);

/// Todas las categorías, incluidas las ocultas.
final categoriasTodasProvider = StreamProvider<List<Categoria>>((ref) {
  return ref.watch(baseDeDatosProvider).verCategorias();
});

/// Solo las categorías visibles (para registrar gastos).
final categoriasVisiblesProvider = StreamProvider<List<Categoria>>((ref) {
  return ref.watch(baseDeDatosProvider).verCategorias(soloVisibles: true);
});

/// Gastos del mes seleccionado, del más reciente al más antiguo.
final gastosDelMesProvider = StreamProvider<List<Gasto>>((ref) {
  final mes = ref.watch(mesSeleccionadoProvider);
  return ref
      .watch(baseDeDatosProvider)
      .verGastosEntre(inicioDelMes(mes), finDelMes(mes));
});

/// Total del mes en la moneda base del hogar.
final totalDelMesProvider = StreamProvider<int>((ref) {
  final mes = ref.watch(mesSeleccionadoProvider);
  return ref
      .watch(baseDeDatosProvider)
      .verGastosEntre(inicioDelMes(mes), finDelMes(mes))
      .map((gastos) =>
          gastos.fold<int>(0, (suma, g) => suma + g.montoBaseMenor));
});

/// Busca una categoría por su id dentro de la lista ya cargada.
Categoria? categoriaPorId(List<Categoria> categorias, int id) {
  for (final c in categorias) {
    if (c.id == id) return c;
  }
  return null;
}
