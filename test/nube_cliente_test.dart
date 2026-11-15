import 'dart:convert';

import 'package:finanzas_hogar/src/features/nube/cliente_nube.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// El cliente web de Firebase (v0.8.0) contra un transporte falso:
/// se revisan las peticiones que haría y cómo traduce las respuestas.
void main() {
  test('entrar devuelve la sesión con los datos de Firebase', () async {
    final cliente = ClienteNubeFirebase(
      cliente: MockClient((peticion) async {
        expect(peticion.url.path, contains('signInWithPassword'));
        final cuerpo = jsonDecode(peticion.body) as Map;
        expect(cuerpo['email'], 'hogar@correo.com');
        expect(cuerpo['password'], 'clave-del-hogar');
        return http.Response(
          jsonEncode({
            'idToken': 'token-1',
            'refreshToken': 'refresh-1',
            'localId': 'uid-1',
            'email': 'hogar@correo.com',
            'expiresIn': '3600',
          }),
          200,
        );
      }),
    );
    final sesion = await cliente.entrar('hogar@correo.com', 'clave-del-hogar');
    expect(sesion.uid, 'uid-1');
    expect(sesion.idToken, 'token-1');
    expect(sesion.refreshToken, 'refresh-1');
    expect(sesion.correo, 'hogar@correo.com');
  });

  test('una clave mala se traduce a un mensaje en español', () async {
    final cliente = ClienteNubeFirebase(
      cliente: MockClient((peticion) async {
        return http.Response(
          jsonEncode({
            'error': {'message': 'INVALID_LOGIN_CREDENTIALS'},
          }),
          400,
        );
      }),
    );
    expect(
      () => cliente.entrar('hogar@correo.com', 'mala'),
      throwsA(
        isA<ErrorNube>().having(
          (e) => e.mensaje,
          'mensaje',
          'Correo o contraseña incorrectos.',
        ),
      ),
    );
  });

  test('leer el documento: 404 es «todavía no hay» y 200 se interpreta',
      () async {
    final sinDoc = ClienteNubeFirebase(
      cliente: MockClient((peticion) async => http.Response('', 404)),
    );
    final sesion = SesionNube(
      uid: 'uid-1',
      correo: 'hogar@correo.com',
      idToken: 'token-1',
      refreshToken: 'refresh-1',
      expiraEn: DateTime.now().add(const Duration(hours: 1)),
    );
    expect(await sinDoc.leerDocumento(sesion), isNull);

    final conDoc = ClienteNubeFirebase(
      cliente: MockClient((peticion) async {
        expect(peticion.url.path, endsWith('/hogares/uid-1'));
        expect(peticion.headers['Authorization'], 'Bearer token-1');
        return http.Response(
          jsonEncode({
            'fields': {
              'contenido': {'stringValue': '{"formato":2}'},
              'generadoEn': {'timestampValue': '2026-11-14T10:00:00.000Z'},
              'origen': {'stringValue': 'equipo-1'},
            },
          }),
          200,
        );
      }),
    );
    final doc = await conDoc.leerDocumento(sesion);
    expect(doc, isNotNull);
    expect(doc!.contenido, '{"formato":2}');
    expect(doc.origen, 'equipo-1');
    expect(doc.generadoEn, DateTime.utc(2026, 11, 14, 10));
  });

  test('escribir el documento manda la foto como texto y la fecha', () async {
    late http.BaseRequest capturada;
    final cliente = ClienteNubeFirebase(
      cliente: MockClient((peticion) async {
        capturada = peticion;
        return http.Response('{}', 200);
      }),
    );
    final sesion = SesionNube(
      uid: 'uid-1',
      correo: 'hogar@correo.com',
      idToken: 'token-1',
      refreshToken: 'refresh-1',
      expiraEn: DateTime.now().add(const Duration(hours: 1)),
    );
    await cliente.escribirDocumento(
      sesion,
      contenido: '{"formato":2}',
      generadoEn: DateTime.utc(2026, 11, 14, 10),
      origen: 'equipo-1',
    );
    expect(capturada.method, 'PATCH');
    final cuerpo = jsonDecode((capturada as http.Request).body) as Map;
    final campos = cuerpo['fields'] as Map;
    expect((campos['contenido'] as Map)['stringValue'], '{"formato":2}');
    expect(
      (campos['generadoEn'] as Map)['timestampValue'],
      '2026-11-14T10:00:00.000Z',
    );
  });
}
