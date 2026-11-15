/// Cliente de la nube del hogar (v0.8.0): habla con Firebase por su
/// interfaz web (REST), igual en Android y en Windows, sin paquetes
/// nativos. La cuenta del hogar es un correo y una contraseña; los
/// datos viven en UN documento por hogar, protegido por las reglas
/// de la base de datos (solo la propia cuenta puede leerlo).
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config_nube.dart';

/// La sesión abierta con la cuenta del hogar.
class SesionNube {
  const SesionNube({
    required this.uid,
    required this.correo,
    required this.idToken,
    required this.refreshToken,
    required this.expiraEn,
  });

  /// El número de la cuenta: también es el nombre de su documento.
  final String uid;
  final String correo;
  final String idToken;
  final String refreshToken;
  final DateTime expiraEn;

  SesionNube copyWith({
    String? idToken,
    String? refreshToken,
    DateTime? expiraEn,
  }) {
    return SesionNube(
      uid: uid,
      correo: correo,
      idToken: idToken ?? this.idToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiraEn: expiraEn ?? this.expiraEn,
    );
  }
}

/// El documento del hogar tal como vive en la nube.
class DocNube {
  const DocNube({
    required this.contenido,
    required this.generadoEn,
    required this.origen,
  });

  /// La foto completa del hogar, como texto JSON.
  final String contenido;

  /// Cuándo cambió ese contenido por última vez.
  final DateTime generadoEn;

  /// Qué equipo lo subió (solo para saber, no decide nada).
  final String origen;
}

/// Error de la nube con el mensaje ya en español, listo para mostrar.
class ErrorNube implements Exception {
  ErrorNube(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

abstract interface class ClienteNube {
  Future<SesionNube> crearCuenta(String correo, String clave);
  Future<SesionNube> entrar(String correo, String clave);
  Future<SesionNube> refrescar(SesionNube sesion);
  Future<DocNube?> leerDocumento(SesionNube sesion);
  Future<void> escribirDocumento(
    SesionNube sesion, {
    required String contenido,
    required DateTime generadoEn,
    required String origen,
  });
}

class ClienteNubeFirebase implements ClienteNube {
  ClienteNubeFirebase({http.Client? cliente})
      : _http = cliente ?? http.Client();

  final http.Client _http;

  String get _llave => ConfigNube.apiKey;
  String get _proyecto => ConfigNube.projectId;

  Uri _auth(String accion) => Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$accion?key=$_llave',
      );

  Uri get _docBase => Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$_proyecto'
        '/databases/(default)/documents/hogares',
      );

  /// Traduce el código de error de Firebase a español claro.
  static String mensajeDeError(String? codigo) {
    switch (codigo) {
      case 'EMAIL_EXISTS':
        return 'Ese correo ya tiene una cuenta del hogar. '
            'Toca «Ya tengo cuenta» para entrar.';
      case 'EMAIL_NOT_FOUND':
      case 'INVALID_PASSWORD':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Correo o contraseña incorrectos.';
      case 'INVALID_EMAIL':
        return 'Ese correo no se ve válido.';
      case 'WEAK_PASSWORD : Password should be at least 6 characters':
      case 'WEAK_PASSWORD':
        return 'La contraseña debe tener al menos 6 letras.';
      case 'USER_DISABLED':
        return 'La cuenta del hogar está desactivada.';
      case 'TOO_MANY_ATTEMPTS_TRY_LATER':
        return 'Demasiados intentos: espera un momento y vuelve a probar.';
      case 'OPERATION_NOT_ALLOWED':
        return 'En tu proyecto de Firebase falta activar el acceso con '
            'correo y contraseña (paso 2 de la guía).';
      default:
        return 'La nube no respondió como se esperaba. '
            'Revisa tu conexión e inténtalo de nuevo.';
    }
  }

  /// Envía una petición y devuelve la respuesta completa (así el
  /// cliente se puede probar con un transporte falso).
  Future<http.Response> _enviar(
    String metodo,
    Uri url, {
    Map<String, String>? headers,
    String? body,
  }) async {
    final peticion = http.Request(metodo, url);
    if (headers != null) peticion.headers.addAll(headers);
    if (body != null) peticion.body = body;
    try {
      return await http.Response.fromStream(await _http.send(peticion));
    } catch (_) {
      throw ErrorNube(
        'Sin conexión con la nube. Revisa tu internet e inténtalo de nuevo.',
      );
    }
  }

  Future<Map<String, Object?>> _postJson(Uri url, Object cuerpo,
      {String? token}) async {
    final respuesta = await _enviar(
      'POST',
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(cuerpo),
    );
    final datos = respuesta.body.isEmpty
        ? <String, Object?>{}
        : (jsonDecode(respuesta.body) as Map).map(
            (k, v) => MapEntry(k.toString(), v),
          );
    if (respuesta.statusCode >= 400) {
      final error = datos['error'];
      final codigo = error is Map ? error['message']?.toString() : null;
      throw ErrorNube(mensajeDeError(codigo));
    }
    return datos;
  }

  SesionNube _sesionDesde(Map<String, Object?> datos, {String? correo}) {
    final segundos = int.tryParse(datos['expiresIn']?.toString() ?? '') ??
        int.tryParse(datos['expires_in']?.toString() ?? '') ??
        3600;
    return SesionNube(
      uid: (datos['localId'] ?? datos['user_id']).toString(),
      correo: correo ?? datos['email']?.toString() ?? '',
      idToken: (datos['idToken'] ?? datos['id_token']).toString(),
      refreshToken:
          (datos['refreshToken'] ?? datos['refresh_token']).toString(),
      expiraEn: DateTime.now().add(Duration(seconds: segundos)),
    );
  }

  @override
  Future<SesionNube> crearCuenta(String correo, String clave) async {
    final datos = await _postJson(_auth('signUp'), {
      'email': correo,
      'password': clave,
      'returnSecureToken': true,
    });
    return _sesionDesde(datos, correo: correo);
  }

  @override
  Future<SesionNube> entrar(String correo, String clave) async {
    final datos = await _postJson(_auth('signInWithPassword'), {
      'email': correo,
      'password': clave,
      'returnSecureToken': true,
    });
    return _sesionDesde(datos, correo: correo);
  }

  @override
  Future<SesionNube> refrescar(SesionNube sesion) async {
    final datos = await _postJson(
      Uri.parse('https://securetoken.googleapis.com/v1/token?key=$_llave'),
      {'grant_type': 'refresh_token', 'refresh_token': sesion.refreshToken},
    );
    final nueva = _sesionDesde(datos, correo: sesion.correo);
    return sesion.copyWith(
      idToken: nueva.idToken,
      refreshToken: nueva.refreshToken,
      expiraEn: nueva.expiraEn,
    );
  }

  @override
  Future<DocNube?> leerDocumento(SesionNube sesion) async {
    final respuesta = await _enviar(
      'GET',
      Uri.parse('$_docBase/${sesion.uid}'),
      headers: {'Authorization': 'Bearer ${sesion.idToken}'},
    );
    if (respuesta.statusCode == 404) return null;
    if (respuesta.statusCode >= 400) {
      throw ErrorNube(mensajeDeError(null));
    }
    final datos = (jsonDecode(respuesta.body) as Map).map(
      (k, v) => MapEntry(k.toString(), v),
    );
    final campos = datos['fields'];
    if (campos is! Map) return null;
    String textoDe(String nombre) {
      final campo = campos[nombre];
      if (campo is Map && campo['stringValue'] is String) {
        return campo['stringValue'] as String;
      }
      return '';
    }

    DateTime fechaDe(String nombre) {
      final campo = campos[nombre];
      if (campo is Map && campo['timestampValue'] is String) {
        return DateTime.parse(campo['timestampValue'] as String);
      }
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DocNube(
      contenido: textoDe('contenido'),
      generadoEn: fechaDe('generadoEn'),
      origen: textoDe('origen'),
    );
  }

  @override
  Future<void> escribirDocumento(
    SesionNube sesion, {
    required String contenido,
    required DateTime generadoEn,
    required String origen,
  }) async {
    final respuesta = await _enviar(
      'PATCH',
      Uri.parse('$_docBase/${sesion.uid}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${sesion.idToken}',
      },
      body: jsonEncode({
        'fields': {
          'contenido': {'stringValue': contenido},
          'generadoEn': {
            'timestampValue': generadoEn.toUtc().toIso8601String(),
          },
          'origen': {'stringValue': origen},
        },
      }),
    );
    if (respuesta.statusCode >= 400) {
      throw ErrorNube(mensajeDeError(null));
    }
  }
}
