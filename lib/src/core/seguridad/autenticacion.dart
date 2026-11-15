/// Seguridad del acceso: contraseñas, PIN, intentos y roles.
///
/// Cómo funciona, en sencillo:
/// - La base de datos solo guarda el nombre y el rol de cada persona.
/// - La contraseña y el PIN se guardan como *huella* (hash con sal,
///   calculado muchas veces seguidas) en el almacenamiento seguro del
///   equipo. La clave en sí nunca se escribe en ninguna parte: al
///   entrar, se calcula la huella de lo escrito y se comparan huellas.
/// - Tras 5 intentos fallidos seguidos, el acceso de esa persona se
///   bloquea por 1 minuto.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../base_de_datos/base_de_datos.dart';

// ---------------- Roles ----------------

/// Roles del hogar (se guardan como texto en la base).
abstract final class Roles {
  static const String administrador = 'administrador';
  static const String miembro = 'miembro';
  static const String lectura = 'lectura';
  static const List<String> todos = [administrador, miembro, lectura];
}

/// ¿Este rol puede crear y editar datos (gastos, fijos, categorías)?
bool puedeEditar(String rol) => rol != Roles.lectura;

/// ¿Este rol puede administrar personas y hacer cambios delicados?
bool puedeAdministrar(String rol) => rol == Roles.administrador;

// ---------------- Almacén de secretos ----------------

/// Donde viven las huellas de las claves y los contadores de intentos.
/// En la app es el almacenamiento seguro del equipo; en las pruebas,
/// una memoria sencilla.
abstract interface class AlmacenClaves {
  Future<String?> leer(String clave);
  Future<void> guardar(String clave, String valor);
  Future<void> eliminar(String clave);
}

/// Almacén real: el almacenamiento seguro del dispositivo.
class AlmacenClavesSeguro implements AlmacenClaves {
  AlmacenClavesSeguro([FlutterSecureStorage? almacenamiento])
    : _almacenamiento = almacenamiento ?? const FlutterSecureStorage();

  final FlutterSecureStorage _almacenamiento;

  @override
  Future<String?> leer(String clave) => _almacenamiento.read(key: clave);

  @override
  Future<void> guardar(String clave, String valor) =>
      _almacenamiento.write(key: clave, value: valor);

  @override
  Future<void> eliminar(String clave) => _almacenamiento.delete(key: clave);
}

// ---------------- Huellas (hash) ----------------

const int _iteraciones = 10000;

/// Una sal aleatoria nueva (texto hexadecimal).
String generarSal() {
  final aleatorio = Random.secure();
  final bytes = List<int>.generate(16, (_) => aleatorio.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

/// La huella de un secreto con su sal: SHA-256 aplicado muchas veces,
/// para que adivinar por fuerza bruta sea lento.
String huellaDe(String secreto, String sal) {
  var datos = utf8.encode('$sal:$secreto');
  for (var i = 0; i < _iteraciones; i++) {
    datos = Uint8List.fromList(sha256.convert(datos).bytes);
  }
  return datos.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

// ---------------- Servicio de autenticación ----------------

/// Resultado de un intento de acceso.
enum ResultadoAcceso { correcto, incorrecto, bloqueado, sinCredenciales }

class ServicioAutenticacion {
  ServicioAutenticacion(this._base, this._almacen);

  final BaseDeDatos _base;
  final AlmacenClaves _almacen;

  static const int maxIntentos = 5;
  static const Duration duracionBloqueo = Duration(minutes: 1);

  String _claveHuella(int usuarioId, String tipo) => 'cred_${usuarioId}_$tipo';
  String _claveIntentos(int usuarioId) => 'intentos_$usuarioId';
  String _claveBloqueo(int usuarioId) => 'bloqueo_$usuarioId';

  // ----- Credenciales -----

  Future<void> _fijarSecreto(int usuarioId, String tipo, String secreto) {
    final sal = generarSal();
    return _almacen.guardar(
      _claveHuella(usuarioId, tipo),
      '$sal:${huellaDe(secreto, sal)}',
    );
  }

  Future<bool> _secretoCoincide(
    int usuarioId,
    String tipo,
    String secreto,
  ) async {
    final guardado = await _almacen.leer(_claveHuella(usuarioId, tipo));
    if (guardado == null) return false;
    final partes = guardado.split(':');
    if (partes.length != 2) return false;
    return huellaDe(secreto, partes[0]) == partes[1];
  }

  /// ¿La persona ya tiene contraseña y PIN en este equipo?
  Future<bool> tieneCredenciales(int usuarioId) async {
    final clave = await _almacen.leer(_claveHuella(usuarioId, 'clave'));
    final pin = await _almacen.leer(_claveHuella(usuarioId, 'pin'));
    return clave != null && pin != null;
  }

  Future<void> fijarClave(int usuarioId, String clave) =>
      _fijarSecreto(usuarioId, 'clave', clave);

  Future<void> fijarPin(int usuarioId, String pin) =>
      _fijarSecreto(usuarioId, 'pin', pin);

  Future<void> borrarCredenciales(int usuarioId) async {
    await _almacen.eliminar(_claveHuella(usuarioId, 'clave'));
    await _almacen.eliminar(_claveHuella(usuarioId, 'pin'));
    await _almacen.eliminar(_claveIntentos(usuarioId));
    await _almacen.eliminar(_claveBloqueo(usuarioId));
  }

  // ----- Intentos y bloqueo -----

  /// Cuánto falta para que se levante el bloqueo (null si no hay).
  Future<Duration?> bloqueoRestante(int usuarioId) async {
    final texto = await _almacen.leer(_claveBloqueo(usuarioId));
    if (texto == null) return null;
    final hasta = int.tryParse(texto);
    if (hasta == null) return null;
    final restante = DateTime.fromMillisecondsSinceEpoch(hasta)
        .difference(DateTime.now());
    return restante > Duration.zero ? restante : null;
  }

  Future<void> _registrarFallo(int usuarioId) async {
    final actual =
        int.tryParse(await _almacen.leer(_claveIntentos(usuarioId)) ?? '') ?? 0;
    final nuevo = actual + 1;
    if (nuevo >= maxIntentos) {
      final hasta = DateTime.now().add(duracionBloqueo);
      await _almacen.guardar(
        _claveBloqueo(usuarioId),
        hasta.millisecondsSinceEpoch.toString(),
      );
      await _almacen.guardar(_claveIntentos(usuarioId), '0');
    } else {
      await _almacen.guardar(_claveIntentos(usuarioId), nuevo.toString());
    }
  }

  Future<void> _registrarExito(int usuarioId) async {
    await _almacen.guardar(_claveIntentos(usuarioId), '0');
    await _almacen.eliminar(_claveBloqueo(usuarioId));
  }

  // ----- Entradas -----

  Future<ResultadoAcceso> _intentar(
    int usuarioId,
    String tipo,
    String secreto,
  ) async {
    if (await bloqueoRestante(usuarioId) != null) {
      return ResultadoAcceso.bloqueado;
    }
    if (await _almacen.leer(_claveHuella(usuarioId, tipo)) == null) {
      return ResultadoAcceso.sinCredenciales;
    }
    if (await _secretoCoincide(usuarioId, tipo, secreto)) {
      await _registrarExito(usuarioId);
      return ResultadoAcceso.correcto;
    }
    await _registrarFallo(usuarioId);
    return ResultadoAcceso.incorrecto;
  }

  /// Entrada rápida con el PIN de la persona.
  Future<ResultadoAcceso> entrarConPin(int usuarioId, String pin) =>
      _intentar(usuarioId, 'pin', pin);

  /// Entrada completa con la contraseña de la persona.
  Future<ResultadoAcceso> entrarConClave(int usuarioId, String clave) =>
      _intentar(usuarioId, 'clave', clave);

  /// Comprobar la contraseña actual (para cambios de seguridad).
  Future<bool> claveActualCoincide(int usuarioId, String clave) =>
      _secretoCoincide(usuarioId, 'clave', clave);

  /// Comprobar el PIN actual (para cambios de seguridad).
  Future<bool> pinActualCoincide(int usuarioId, String pin) =>
      _secretoCoincide(usuarioId, 'pin', pin);

  // ----- Personas -----

  /// ¿Ya existe alguien con ese nombre? (sin distinguir mayúsculas)
  Future<bool> nombreEnUso(String nombre, {int? exceptoId}) async {
    final existente = await _base.usuarioPorNombre(nombre);
    return existente != null && existente.id != exceptoId;
  }

  /// Crea una persona con su contraseña y su PIN.
  ///
  /// Lanza [ArgumentError] si el nombre ya está en uso.
  Future<Usuario> crearPersona({
    required String nombre,
    required String rol,
    required String clave,
    required String pin,
  }) async {
    final limpio = nombre.trim();
    if (await nombreEnUso(limpio)) {
      throw ArgumentError('Ya hay una persona con ese nombre.');
    }
    final ahora = DateTime.now();
    final id = await _base.crearUsuario(
      UsuariosCompanion.insert(
        nombre: limpio,
        rol: Value(rol),
        creadoEn: ahora,
      ),
    );
    await fijarClave(id, clave);
    await fijarPin(id, pin);
    final creado = await _base.usuarioPorId(id);
    return creado!;
  }

  /// Cambia el nombre de una persona (v0.7.1). Su historial la sigue:
  /// los gastos que decían su nombre viejo quedan con el nuevo, y su
  /// contraseña y su PIN no cambian (van por su número de usuario).
  ///
  /// Lanza [ArgumentError] si el nombre queda vacío o ya lo usa otra
  /// persona (sin distinguir mayúsculas).
  Future<void> renombrarPersona(int usuarioId, String nuevoNombre) async {
    final limpio = nuevoNombre.trim();
    if (limpio.isEmpty) {
      throw ArgumentError('Escribe un nombre.');
    }
    final actual = await _base.usuarioPorId(usuarioId);
    if (actual == null) {
      throw ArgumentError('Esa persona ya no existe.');
    }
    if (actual.nombre.trim().toLowerCase() == limpio.toLowerCase()) return;
    if (await nombreEnUso(limpio, exceptoId: usuarioId)) {
      throw ArgumentError('Ya hay una persona con ese nombre.');
    }
    await _base.transaction(() async {
      await _base.actualizarUsuario(actual.copyWith(nombre: limpio));
      await _base.renombrarHechoPor(actual.nombre, limpio);
    });
  }

  /// Elimina a la persona y sus credenciales de este equipo.
  Future<void> eliminarPersona(int usuarioId) async {
    await borrarCredenciales(usuarioId);
    await _base.eliminarUsuario(usuarioId);
  }
}

// ---------------- Validaciones de formato ----------------

/// Mensaje de error si la contraseña no sirve (null si está bien).
String? errorDeClave(String clave) {
  if (clave.length < 6) return 'La contraseña debe tener al menos 6 letras.';
  return null;
}

/// Mensaje de error si el PIN no sirve (null si está bien).
String? errorDePin(String pin) {
  if (pin.length < 4 || pin.length > 6) {
    return 'El PIN debe tener de 4 a 6 números.';
  }
  if (int.tryParse(pin) == null) return 'El PIN solo puede tener números.';
  return null;
}
