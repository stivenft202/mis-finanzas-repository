/// Proveedores de Riverpod: el puente entre las pantallas y los datos.
///
/// Las pantallas nunca tocan la base de datos directamente: miran estos
/// proveedores, y cuando los datos cambian, la pantalla se actualiza sola.
library;

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/nube/cliente_nube.dart';
import '../features/nube/servicio_nube.dart';
import 'base_de_datos/base_de_datos.dart';
import 'base_de_datos/conexion.dart';
import 'seguridad/autenticacion.dart';
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

final mesSeleccionadoProvider = NotifierProvider<MesSeleccionado, DateTime>(
  MesSeleccionado.new,
);

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

/// Gastos del mes anterior al seleccionado, para la comparación
/// «a esta fecha» de la tarjeta «Así va tu mes» (v0.7.2).
final gastosMesAnteriorProvider = StreamProvider<List<Gasto>>((ref) {
  final mes = ref.watch(mesSeleccionadoProvider);
  final anterior = DateTime(mes.year, mes.month - 1);
  return ref
      .watch(baseDeDatosProvider)
      .verGastosEntre(inicioDelMes(anterior), finDelMes(anterior));
});

/// Total del mes en la moneda base del hogar.
final totalDelMesProvider = StreamProvider<int>((ref) {
  final mes = ref.watch(mesSeleccionadoProvider);
  return ref
      .watch(baseDeDatosProvider)
      .verGastosEntre(inicioDelMes(mes), finDelMes(mes))
      .map(
        (gastos) => gastos.fold<int>(0, (suma, g) => suma + g.montoBaseMenor),
      );
});

/// Gastos fijos del mes (plantillas), ordenados por día del mes.
final gastosFijosProvider = StreamProvider<List<Fijo>>((ref) {
  return ref.watch(baseDeDatosProvider).verFijos('gasto');
});

/// Ingresos fijos del mes (plantillas), ordenados por día del mes.
final ingresosFijosProvider = StreamProvider<List<Fijo>>((ref) {
  return ref.watch(baseDeDatosProvider).verFijos('ingreso');
});

/// Busca una categoría por su id dentro de la lista ya cargada.
Categoria? categoriaPorId(List<Categoria> categorias, int id) {
  for (final c in categorias) {
    if (c.id == id) return c;
  }
  return null;
}

// ---------------- Seguridad y acceso (Fase 5, v0.6.0) ----------------

/// Donde viven las huellas de las claves (almacenamiento seguro).
final almacenClavesProvider = Provider<AlmacenClaves>(
  (ref) => AlmacenClavesSeguro(),
);

/// El servicio que comprueba contraseñas y PIN.
final servicioAutenticacionProvider = Provider<ServicioAutenticacion>(
  (ref) => ServicioAutenticacion(
    ref.watch(baseDeDatosProvider),
    ref.watch(almacenClavesProvider),
  ),
);

// ---------------- Nube del hogar (v0.8.0) ----------------

/// El servicio de sincronización con la nube. Alguien tiene que
/// mirarlo para que exista: el inicio lo mira y así arranca la
/// sincronización automática.
final servicioNubeProvider = Provider<ServicioNube>((ref) {
  final servicio = ServicioNube(
    ref.watch(baseDeDatosProvider),
    ref.watch(almacenClavesProvider),
    ref.watch(servicioAutenticacionProvider),
    ClienteNubeFirebase(),
  );
  ref.onDispose(servicio.detenerAutoSync);
  servicio.iniciarAutoSync();
  return servicio;
});

/// Todas las personas del hogar.
final usuariosProvider = StreamProvider<List<Usuario>>((ref) {
  return ref.watch(baseDeDatosProvider).verUsuarios();
});

/// Estado del acceso: quién entró (por id) y si la app está bloqueada
/// por inactividad. Sin id = nadie ha entrado todavía.
class EstadoAcceso {
  const EstadoAcceso({this.usuarioId, this.bloqueada = false});

  final int? usuarioId;
  final bool bloqueada;

  bool get haySesion => usuarioId != null;
}

/// Estado inicial del acceso. Lo sobreescriben `main()` (nadie dentro)
/// y las pruebas (una sesión ya abierta).
final accesoInicialProvider = Provider<EstadoAcceso>(
  (ref) => const EstadoAcceso(),
);

class ControlAcceso extends Notifier<EstadoAcceso> {
  @override
  EstadoAcceso build() => ref.watch(accesoInicialProvider);

  void entrar(int usuarioId) => state = EstadoAcceso(usuarioId: usuarioId);

  /// Bloqueo por inactividad: la sesión sigue, pero pide el PIN.
  void bloquear() {
    final id = state.usuarioId;
    if (id != null) state = EstadoAcceso(usuarioId: id, bloqueada: true);
  }

  void desbloquear() {
    final id = state.usuarioId;
    if (id != null) state = EstadoAcceso(usuarioId: id);
  }

  void salir() => state = const EstadoAcceso();
}

final controlAccesoProvider = NotifierProvider<ControlAcceso, EstadoAcceso>(
  ControlAcceso.new,
);

/// La persona que tiene la sesión abierta (dato fresco de la base).
final usuarioActualProvider = Provider<Usuario?>((ref) {
  final id = ref.watch(controlAccesoProvider).usuarioId;
  if (id == null) return null;
  final usuarios = ref.watch(usuariosProvider).value ?? const <Usuario>[];
  for (final u in usuarios) {
    if (u.id == id) return u;
  }
  return null;
});

/// ¿La sesión actual puede crear y editar datos?
final puedeEditarProvider = Provider<bool>((ref) {
  final usuario = ref.watch(usuarioActualProvider);
  return usuario != null && puedeEditar(usuario.rol);
});

/// ¿La sesión actual es de un administrador?
final puedeAdministrarProvider = Provider<bool>((ref) {
  final usuario = ref.watch(usuarioActualProvider);
  return usuario != null && puedeAdministrar(usuario.rol);
});

/// Minutos sin usar la app antes del bloqueo automático (0 = nunca).
/// Se guarda en el almacenamiento seguro; por defecto, 5.
final autoBloqueoMinutosProvider = FutureProvider<int>((ref) async {
  final texto = await ref.watch(almacenClavesProvider).leer('autobloqueo_min');
  return int.tryParse(texto ?? '') ?? 5;
});

// ---------------- Tema claro / oscuro ----------------

/// Tema con el que arranca la app, leído en `main()` del guardado.
final temaInicialProvider = Provider<ThemeMode>((ref) => ThemeMode.system);

/// El modo de tema elegido (claro, oscuro o el del sistema), con
/// memoria: lo que la persona elija queda guardado para la próxima vez.
class ModoTema extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(temaInicialProvider);

  Future<void> cambiar(ThemeMode modo) async {
    state = modo;
    final valor = switch (modo) {
      ThemeMode.light => 'claro',
      ThemeMode.dark => 'oscuro',
      ThemeMode.system => 'sistema',
    };
    await ref.read(almacenClavesProvider).guardar('tema_modo', valor);
  }
}

final modoTemaProvider = NotifierProvider<ModoTema, ThemeMode>(ModoTema.new);
