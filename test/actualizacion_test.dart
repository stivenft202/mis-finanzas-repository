import 'package:finanzas_hogar/src/features/actualizaciones/servicio_actualizacion.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pruebas de la actualización dentro de la app (v0.5.0): comparar
/// versiones y leer la respuesta de GitHub eligiendo el archivo
/// correcto para cada plataforma.
void main() {
  group('versionEsMayor', () {
    test('detecta una versión más nueva', () {
      expect(versionEsMayor('v0.5.0', '0.4.0'), isTrue);
      expect(versionEsMayor('0.5.1', '0.5.0'), isTrue);
      expect(versionEsMayor('1.0.0', '0.9.9'), isTrue);
    });

    test('la misma versión o una vieja no cuentan como nueva', () {
      expect(versionEsMayor('v0.5.0', '0.5.0'), isFalse);
      expect(versionEsMayor('0.4.0', '0.5.0'), isFalse);
      expect(versionEsMayor('v0.5.0', '0.5.0+9'), isFalse);
    });

    test('ignora la «v» inicial y el número de compilación', () {
      expect(versionEsMayor('v0.6.0', '0.5.0+5'), isTrue);
      expect(versionEsMayor('0.10.0', '0.9.0'), isTrue);
    });
  });

  group('interpretarRelease', () {
    final respuestaGitHub = <String, dynamic>{
      'tag_name': 'v0.6.0',
      'assets': [
        {
          'name': 'Finanzas-del-Hogar-Android-v0.6.0.apk',
          'browser_download_url': 'https://ejemplo.com/app.apk',
        },
        {
          'name': 'Finanzas-del-Hogar-Windows-v0.6.0.zip',
          'browser_download_url': 'https://ejemplo.com/app.zip',
        },
      ],
    };

    test('en Android elige el APK', () {
      final info = interpretarRelease(respuestaGitHub, esAndroid: true);
      expect(info, isNotNull);
      expect(info!.version, 'v0.6.0');
      expect(info.urlDescarga, 'https://ejemplo.com/app.apk');
      expect(info.nombreArchivo, endsWith('.apk'));
    });

    test('en Windows elige el ZIP', () {
      final info = interpretarRelease(respuestaGitHub, esAndroid: false);
      expect(info, isNotNull);
      expect(info!.urlDescarga, 'https://ejemplo.com/app.zip');
      expect(info.nombreArchivo, endsWith('.zip'));
    });

    test('sin el archivo de la plataforma, no hay actualización', () {
      final soloWindows = <String, dynamic>{
        'tag_name': 'v0.6.0',
        'assets': [
          {
            'name': 'Finanzas-del-Hogar-Windows-v0.6.0.zip',
            'browser_download_url': 'https://ejemplo.com/app.zip',
          },
        ],
      };
      expect(interpretarRelease(soloWindows, esAndroid: true), isNull);
      expect(interpretarRelease(const {}, esAndroid: true), isNull);
    });
  });
}
