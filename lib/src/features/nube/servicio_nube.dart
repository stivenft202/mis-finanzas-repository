/// El cerebro de la nube del hogar (v0.8.0).
///
/// Cada equipo guarda todo en su propio disco y la app funciona sin
/// internet. Cuando hay conexión, los equipos se ponen al día con una
/// «foto completa» del hogar (datos + personas + huellas de acceso)
/// que vive en un documento privado de la cuenta del hogar:
///
/// - Si solo cambió un lado, ese lado manda.
/// - Si es la primera vez de un equipo con datos propios y la nube
///   ya tiene datos, NO se pisa nada: la persona decide cuál manda.
/// - Si cambiaron los dos lados desde la última vez, gana el cambio
///   más reciente.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/seguridad/autenticacion.dart';
import 'cliente_nube.dart';

enum AccionSync { subir, bajar, nada, conflicto }

enum ResolucionConflicto { usarNube, usarEsteEquipo }

enum ResultadoSync { subido, bajado, nada, conflicto, sinCuenta, ocupado, error }

/// La decisión de sincronizar, en puro (se prueba sin nube ni base).
AccionSync decidirSync({
  required bool hayRemoto,
  required DateTime? remotoGeneradoEn,
  required DateTime? ultimoSync,
  required DateTime? localModificadoEn,
}) {
  if (!hayRemoto) return AccionSync.subir;
  if (ultimoSync == null) {
    // Primera vez de este equipo y la nube ya tiene datos: si aquí
    // también hay datos propios, que la persona decida; si no, bajar.
    return localModificadoEn != null
        ? AccionSync.conflicto
        : AccionSync.bajar;
  }
  final remotoNuevo =
      remotoGeneradoEn != null && remotoGeneradoEn.isAfter(ultimoSync);
  if (!remotoNuevo) {
    return localModificadoEn != null ? AccionSync.subir : AccionSync.nada;
  }
  if (localModificadoEn == null) return AccionSync.bajar;
  // Cambiaron los dos: gana el cambio más reciente.
  return localModificadoEn.isAfter(remotoGeneradoEn!)
      ? AccionSync.subir
      : AccionSync.bajar;
}

/// Lo que la pantalla de la nube muestra del estado.
class EstadoNube {
  const EstadoNube({
    this.conectado = false,
    this.correo,
    this.sincronizando = false,
    this.ultimoSync,
    this.hayConflicto = false,
    this.error,
    this.ultimoResultado,
  });

  final bool conectado;
  final String? correo;
  final bool sincronizando;
  final DateTime? ultimoSync;
  final bool hayConflicto;
  final String? error;
  final ResultadoSync? ultimoResultado;

  EstadoNube copyWith({
    bool? conectado,
    String? correo,
    bool? sincronizando,
    DateTime? ultimoSync,
    bool? hayConflicto,
    String? error,
    ResultadoSync? ultimoResultado,
    bool limpiarError = false,
  }) {
    return EstadoNube(
      conectado: conectado ?? this.conectado,
      correo: correo ?? this.correo,
      sincronizando: sincronizando ?? this.sincronizando,
      ultimoSync: ultimoSync ?? this.ultimoSync,
      hayConflicto: hayConflicto ?? this.hayConflicto,
      error: limpiarError ? null : (error ?? this.error),
      ultimoResultado: ultimoResultado ?? this.ultimoResultado,
    );
  }
}

class ServicioNube {
  ServicioNube(this._base, this._almacen, this._auth, this._cliente) {
    _restaurarEstado();
  }

  final BaseDeDatos _base;
  final AlmacenClaves _almacen;
  final ServicioAutenticacion _auth;
  final ClienteNube _cliente;

  final ValueNotifier<EstadoNube> estadoNotifier =
      ValueNotifier(const EstadoNube());

  SesionNube? _sesion;
  bool _sincronizando = false;
  Timer? _temporizador;

  // ----- Estado y sesión -----

  void _emitir(EstadoNube nuevo) => estadoNotifier.value = nuevo;

  Future<void> _restaurarEstado() async {
    final sesion = await _cargarSesion();
    final ultimo = await _leerFecha('nube_ultimo_sync');
    _emitir(
      EstadoNube(
        conectado: sesion != null,
        correo: sesion?.correo,
        ultimoSync: ultimo,
      ),
    );
  }

  Future<SesionNube?> _cargarSesion() async {
    if (_sesion != null) return _sesion;
    final uid = await _almacen.leer('nube_uid');
    final correo = await _almacen.leer('nube_correo');
    final token = await _almacen.leer('nube_token');
    final refresh = await _almacen.leer('nube_refresh');
    final expira = await _leerFecha('nube_expira');
    if (uid == null || correo == null || token == null || refresh == null) {
      return null;
    }
    _sesion = SesionNube(
      uid: uid,
      correo: correo,
      idToken: token,
      refreshToken: refresh,
      expiraEn: expira ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
    return _sesion;
  }

  Future<void> _guardarSesion(SesionNube sesion) async {
    _sesion = sesion;
    await _almacen.guardar('nube_uid', sesion.uid);
    await _almacen.guardar('nube_correo', sesion.correo);
    await _almacen.guardar('nube_token', sesion.idToken);
    await _almacen.guardar('nube_refresh', sesion.refreshToken);
    await _guardarFecha('nube_expira', sesion.expiraEn);
  }

  Future<DateTime?> _leerFecha(String clave) async {
    final texto = await _almacen.leer(clave);
    return texto == null ? null : DateTime.tryParse(texto);
  }

  Future<void> _guardarFecha(String clave, DateTime fecha) =>
      _almacen.guardar(clave, fecha.toUtc().toIso8601String());

  Future<SesionNube> _tokenFresco(SesionNube sesion) async {
    final limite = DateTime.now().add(const Duration(minutes: 5));
    if (sesion.expiraEn.isAfter(limite)) return sesion;
    final fresca = await _cliente.refrescar(sesion);
    await _guardarSesion(fresca);
    return fresca;
  }

  /// Crea la cuenta del hogar y sincroniza enseguida.
  Future<ResultadoSync> crearCuenta(String correo, String clave) async {
    final sesion = await _cliente.crearCuenta(correo.trim(), clave);
    await _guardarSesion(sesion);
    _emitir(
      estadoNotifier.value.copyWith(
        conectado: true,
        correo: sesion.correo,
        limpiarError: true,
      ),
    );
    return sincronizar();
  }

  /// Entra con la cuenta del hogar y sincroniza enseguida.
  Future<ResultadoSync> entrar(String correo, String clave) async {
    final sesion = await _cliente.entrar(correo.trim(), clave);
    await _guardarSesion(sesion);
    _emitir(
      estadoNotifier.value.copyWith(
        conectado: true,
        correo: sesion.correo,
        limpiarError: true,
      ),
    );
    return sincronizar();
  }

  /// Cierra la cuenta en ESTE equipo (la nube y el otro equipo no se
  /// tocan) y olvida el rastro de sincronización local.
  Future<void> salirCuenta() async {
    _sesion = null;
    for (final clave in const [
      'nube_uid',
      'nube_correo',
      'nube_token',
      'nube_refresh',
      'nube_expira',
      'nube_ultimo_sync',
      'nube_firma',
      'nube_modificado',
    ]) {
      await _almacen.eliminar(clave);
    }
    _emitir(const EstadoNube());
  }

  // ----- La foto completa -----

  Future<({String contenido, String firma})> _fotoActual() async {
    final datos = await _base.exportarSync();
    final usuarios = await _base.listaUsuarios();
    final credenciales = await _auth.credencialesParaSync([
      for (final u in usuarios) u.id,
    ]);
    final contenido = jsonEncode({...datos, 'credenciales': credenciales});
    return (contenido: contenido, firma: huellaDe(contenido, 'firma-nube'));
  }

  Future<void> _aplicarRemoto(DocNube doc) async {
    final mapa = (jsonDecode(doc.contenido) as Map).map(
      (k, v) => MapEntry(k.toString(), v),
    );
    final crudas = mapa.remove('credenciales');
    await _base.importarSync(mapa);
    final credenciales = <String, String>{};
    if (crudas is Map) {
      crudas.forEach((k, v) {
        if (v is String) credenciales[k.toString()] = v;
      });
    }
    final usuarios = await _base.listaUsuarios();
    await _auth.aplicarCredencialesSync(credenciales, [
      for (final u in usuarios) u.id,
    ]);
  }

  Future<bool> _hayDatosPropios() async {
    if ((await _base.listaUsuarios()).isNotEmpty) return true;
    final alguno = await (_base.select(_base.gastos)..limit(1)).get();
    return alguno.isNotEmpty;
  }

  Future<String> _equipoId() async {
    var id = await _almacen.leer('nube_equipo');
    if (id == null) {
      id = 'equipo-${DateTime.now().microsecondsSinceEpoch}';
      await _almacen.guardar('nube_equipo', id);
    }
    return id;
  }

  // ----- Sincronizar -----

  Future<ResultadoSync> sincronizar({ResolucionConflicto? resolucion}) async {
    if (_sincronizando) return ResultadoSync.ocupado;
    final sesion = await _cargarSesion();
    if (sesion == null) return ResultadoSync.sinCuenta;
    _sincronizando = true;
    _emitir(
      estadoNotifier.value.copyWith(sincronizando: true, limpiarError: true),
    );
    try {
      final fresca = await _tokenFresco(sesion);
      final foto = await _fotoActual();
      final firmaGuardada = await _almacen.leer('nube_firma');
      final ultimoSync = await _leerFecha('nube_ultimo_sync');
      final propios = await _hayDatosPropios();
      var modificadoEn = await _leerFecha('nube_modificado');
      if (foto.firma == firmaGuardada && firmaGuardada != null) {
        modificadoEn = null;
        await _almacen.eliminar('nube_modificado');
      } else if (modificadoEn == null) {
        modificadoEn = DateTime.now();
        await _guardarFecha('nube_modificado', modificadoEn);
      }
      final doc = await _cliente.leerDocumento(fresca);
      // En la primera vez, un equipo sin datos propios no «modificó»
      // nada: lo que trae es solo la siembra inicial.
      final modificadoEfectivo =
          (ultimoSync == null && !propios) ? null : modificadoEn;
      var accion = decidirSync(
        hayRemoto: doc != null,
        remotoGeneradoEn: doc?.generadoEn,
        ultimoSync: ultimoSync,
        localModificadoEn: modificadoEfectivo,
      );
      if (resolucion == ResolucionConflicto.usarNube) {
        accion = AccionSync.bajar;
      }
      if (resolucion == ResolucionConflicto.usarEsteEquipo) {
        accion = AccionSync.subir;
      }
      if (accion == AccionSync.bajar && doc == null) {
        accion = AccionSync.subir; // no hay nada que bajar: subir lo local
      }
      switch (accion) {
        case AccionSync.conflicto:
          _emitir(
            estadoNotifier.value.copyWith(
              sincronizando: false,
              hayConflicto: true,
              ultimoResultado: ResultadoSync.conflicto,
            ),
          );
          return ResultadoSync.conflicto;
        case AccionSync.nada:
          _emitir(
            estadoNotifier.value.copyWith(
              sincronizando: false,
              hayConflicto: false,
              ultimoResultado: ResultadoSync.nada,
            ),
          );
          return ResultadoSync.nada;
        case AccionSync.subir:
          final generado = modificadoEn ?? DateTime.now();
          await _cliente.escribirDocumento(
            fresca,
            contenido: foto.contenido,
            generadoEn: generado,
            origen: await _equipoId(),
          );
          await _almacen.guardar('nube_firma', foto.firma);
          await _guardarFecha('nube_ultimo_sync', generado);
          await _almacen.eliminar('nube_modificado');
          _emitir(
            estadoNotifier.value.copyWith(
              sincronizando: false,
              hayConflicto: false,
              ultimoSync: generado,
              ultimoResultado: ResultadoSync.subido,
            ),
          );
          return ResultadoSync.subido;
        case AccionSync.bajar:
          await _aplicarRemoto(doc!);
          await _almacen.guardar(
            'nube_firma',
            huellaDe(doc.contenido, 'firma-nube'),
          );
          await _guardarFecha('nube_ultimo_sync', doc.generadoEn);
          await _almacen.eliminar('nube_modificado');
          _emitir(
            estadoNotifier.value.copyWith(
              sincronizando: false,
              hayConflicto: false,
              ultimoSync: doc.generadoEn,
              ultimoResultado: ResultadoSync.bajado,
            ),
          );
          return ResultadoSync.bajado;
      }
    } on ErrorNube catch (e) {
      _emitir(
        estadoNotifier.value.copyWith(sincronizando: false, error: e.mensaje),
      );
      return ResultadoSync.error;
    } finally {
      _sincronizando = false;
    }
  }

  /// Sincronización automática: al abrir la app y cada 90 segundos
  /// mientras esté abierta. Nunca decide un conflicto sola.
  void iniciarAutoSync() {
    if (_temporizador != null) return;
    sincronizar();
    _temporizador = Timer.periodic(
      const Duration(seconds: 90),
      (_) => sincronizar(),
    );
  }

  void detenerAutoSync() {
    _temporizador?.cancel();
    _temporizador = null;
  }
}
