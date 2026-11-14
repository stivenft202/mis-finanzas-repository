/// Actualización desde dentro de la app (v0.5.0, pedido de Esteban:
/// nada de descargar el instalador a mano en cada versión).
///
/// La app revisa en GitHub (repositorio público, sin claves) si hay
/// una versión más nueva que la instalada; si la hay, la descarga por
/// dentro y la instala: en Android abre el instalador del sistema (el
/// toque final en «Instalar» lo exige Android) y en Windows se cierra,
/// se reemplaza sola con un ayudante y se vuelve a abrir.
library;

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Dónde vive la última versión publicada (la API pública de GitHub).
const urlUltimaVersion =
    'https://api.github.com/repos/stivenft202/mis-finanzas-repository/releases/latest';

/// ¿[nueva] es una versión mayor que [actual]?
/// Acepta formatos como «v0.5.0», «0.5.0» o «0.5.0+5».
bool versionEsMayor(String nueva, String actual) {
  List<int> partes(String v) {
    var limpia = v.trim();
    if (limpia.startsWith('v') || limpia.startsWith('V')) {
      limpia = limpia.substring(1);
    }
    limpia = limpia.split('+').first;
    return limpia.split('.').map((p) => int.tryParse(p) ?? 0).toList();
  }

  final n = partes(nueva);
  final a = partes(actual);
  for (var i = 0; i < 3; i++) {
    final nv = i < n.length ? n[i] : 0;
    final av = i < a.length ? a[i] : 0;
    if (nv != av) return nv > av;
  }
  return false;
}

/// Los datos de una actualización disponible.
class InfoActualizacion {
  const InfoActualizacion({
    required this.version,
    required this.urlDescarga,
    required this.nombreArchivo,
  });

  /// La versión nueva, por ejemplo «v0.6.0».
  final String version;

  /// El enlace directo del archivo a descargar.
  final String urlDescarga;

  /// El nombre del archivo (APK en Android, ZIP en Windows).
  final String nombreArchivo;
}

/// Lee la respuesta de GitHub sobre un «Release» y saca la descarga
/// que le sirve a esta plataforma. Devuelve null si no trae el archivo.
InfoActualizacion? interpretarRelease(
  Map<String, dynamic> json, {
  required bool esAndroid,
}) {
  final tag = json['tag_name']?.toString() ?? '';
  final recursos = json['assets'];
  if (tag.isEmpty || recursos is! List) return null;
  final extension = esAndroid ? '.apk' : '.zip';
  for (final recurso in recursos) {
    if (recurso is Map) {
      final nombre = recurso['name']?.toString() ?? '';
      final url = recurso['browser_download_url']?.toString() ?? '';
      if (nombre.toLowerCase().endsWith(extension) && url.isNotEmpty) {
        return InfoActualizacion(
          version: tag,
          urlDescarga: url,
          nombreArchivo: nombre,
        );
      }
    }
  }
  return null;
}

/// Pregunta en GitHub si hay una versión más nueva que la instalada.
/// Devuelve la información de la actualización, o null si la app ya
/// está al día. Lanza si no hay conexión o GitHub no responde.
Future<InfoActualizacion?> buscarActualizacion() async {
  final info = await PackageInfo.fromPlatform();
  final cliente = HttpClient()..connectionTimeout = const Duration(seconds: 15);
  try {
    final peticion = await cliente.getUrl(Uri.parse(urlUltimaVersion));
    peticion.headers.set(HttpHeaders.userAgentHeader, 'FinanzasHogar');
    peticion.headers.set(HttpHeaders.acceptHeader, 'application/vnd.github+json');
    final respuesta = await peticion.close();
    if (respuesta.statusCode != 200) {
      throw HttpException('GitHub respondió ${respuesta.statusCode}');
    }
    final texto = await respuesta.transform(utf8.decoder).join();
    final decodificado = jsonDecode(texto);
    if (decodificado is! Map<String, dynamic>) return null;
    final encontrada = interpretarRelease(
      decodificado,
      esAndroid: Platform.isAndroid,
    );
    if (encontrada == null) return null;
    return versionEsMayor(encontrada.version, info.version)
        ? encontrada
        : null;
  } finally {
    cliente.close();
  }
}

/// Descarga el archivo de la actualización a una carpeta temporal,
/// avisando el progreso (de 0.0 a 1.0; null si no se conoce el total).
Future<File> descargarActualizacion(
  InfoActualizacion info, {
  void Function(double? progreso)? alProgreso,
}) async {
  final temporal = await getTemporaryDirectory();
  final carpeta = Directory('${temporal.path}/actualizacion');
  if (!carpeta.existsSync()) {
    carpeta.createSync(recursive: true);
  }
  final archivo = File('${carpeta.path}/${info.nombreArchivo}');
  final cliente = HttpClient();
  try {
    final peticion = await cliente.getUrl(Uri.parse(info.urlDescarga));
    peticion.headers.set(HttpHeaders.userAgentHeader, 'FinanzasHogar');
    final respuesta = await peticion.close();
    if (respuesta.statusCode != 200) {
      throw HttpException('La descarga respondió ${respuesta.statusCode}');
    }
    final total = respuesta.contentLength;
    var recibidos = 0;
    final salida = archivo.openWrite();
    await for (final trozo in respuesta) {
      salida.add(trozo);
      recibidos += trozo.length;
      alProgreso?.call(total > 0 ? recibidos / total : null);
    }
    await salida.close();
    return archivo;
  } finally {
    cliente.close();
  }
}

/// Android: abre el instalador del sistema con el APK descargado.
/// El último toque en «Instalar» lo pone la persona (lo exige Android
/// para apps que no vienen de la Play Store).
Future<void> instalarEnAndroid(File apk) async {
  final resultado = await OpenFilex.open(apk.path);
  if (resultado.type != ResultType.done) {
    throw Exception('No se pudo abrir el instalador: ${resultado.message}');
  }
}

/// Windows: descomprime el paquete, deja un ayudante (.bat) que espera
/// a que la app se cierre, copia los archivos nuevos encima y vuelve
/// a abrir la app ya actualizada. Al final, esta app se cierra sola.
Future<void> aplicarEnWindows(File zip) async {
  final temporal = await getTemporaryDirectory();
  final carpeta = Directory('${temporal.path}/actualizacion-windows');
  if (carpeta.existsSync()) {
    carpeta.deleteSync(recursive: true);
  }
  carpeta.createSync(recursive: true);

  final bytes = await zip.readAsBytes();
  final descomprimido = ZipDecoder().decodeBytes(bytes);
  extractArchiveToDisk(descomprimido, carpeta.path);

  // El ejecutable puede venir en la raíz del ZIP o dentro de una carpeta.
  File? ejecutable;
  for (final entrada in carpeta.listSync(recursive: true)) {
    if (entrada is File &&
        entrada.path.toLowerCase().endsWith('finanzas_hogar.exe')) {
      ejecutable = entrada;
      break;
    }
  }
  if (ejecutable == null) {
    throw Exception('El paquete descargado no trae el programa.');
  }
  final origen = ejecutable.parent.path;
  final destino = File(Platform.resolvedExecutable).parent.path;
  final nombreExe = ejecutable.uri.pathSegments.last;

  final ayudante = File('${carpeta.path}/actualizar.bat');
  await ayudante.writeAsString(
    '@echo off\r\n'
    'timeout /t 2 /nobreak >nul\r\n'
    ':espera\r\n'
    'tasklist /FI "IMAGENAME eq $nombreExe" 2>nul | find /I "$nombreExe" >nul\r\n'
    'if not errorlevel 1 (\r\n'
    '  timeout /t 1 /nobreak >nul\r\n'
    '  goto espera\r\n'
    ')\r\n'
    'robocopy "$origen" "$destino" /E /R:10 /W:1 >nul\r\n'
    'start "" "$destino\\$nombreExe"\r\n',
  );
  await Process.start(
    'cmd',
    ['/c', 'start', '', ayudante.path],
    mode: ProcessStartMode.detached,
  );
  exit(0);
}

/// La versión instalada de la app, por ejemplo «0.5.0».
final versionActualProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

/// Revisión silenciosa al abrir la app: la actualización disponible,
/// o null si no hay ninguna (o si no se pudo revisar).
final actualizacionDisponibleProvider =
    FutureProvider<InfoActualizacion?>((ref) async {
  try {
    return await buscarActualizacion();
  } catch (_) {
    return null;
  }
});
