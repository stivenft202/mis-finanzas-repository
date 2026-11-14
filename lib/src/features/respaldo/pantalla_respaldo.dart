/// Módulo «Respaldo»: exportar TODOS los datos a un solo archivo e
/// importarlos en otro equipo (Windows ↔ Android), para que nadie
/// tenga que reingresar sus gastos al cambiar de equipo (v0.4.0).
///
/// Como eligió Esteban: archivo simple, SIN clave. Al importar se
/// reemplaza lo que haya en el equipo destino (es para migrar).
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/providers.dart';

class PantallaRespaldo extends ConsumerStatefulWidget {
  const PantallaRespaldo({super.key});

  @override
  ConsumerState<PantallaRespaldo> createState() => _PantallaRespaldoState();
}

class _PantallaRespaldoState extends ConsumerState<PantallaRespaldo> {
  bool _trabajando = false;

  Future<void> _exportar() async {
    final textos = context.textos;
    setState(() => _trabajando = true);
    try {
      final base = ref.read(baseDeDatosProvider);
      final datos = await base.exportarDatos();
      final contenido = const JsonEncoder.withIndent('  ').convert(datos);
      final bytes = Uint8List.fromList(utf8.encode(contenido));
      final ruta = await FilePicker.saveFile(
        dialogTitle: textos.guardarRespaldoTitulo,
        fileName: 'respaldo-finanzas-hogar.json',
        bytes: bytes,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (ruta == null) return; // La persona canceló el guardado.
      // En escritorio el selector solo elige la ruta: escribimos nosotros.
      // En Android el propio selector guarda los bytes.
      if (!kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        await File(ruta).writeAsBytes(bytes);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.exportarListo)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.errorRespaldo)),
      );
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  Future<void> _importar() async {
    final textos = context.textos;
    final elegido = await FilePicker.pickFiles(
      dialogTitle: textos.elegirRespaldoTitulo,
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    if (elegido == null || elegido.files.isEmpty) return;
    final archivo = elegido.files.single;
    setState(() => _trabajando = true);
    try {
      final String contenido;
      if (archivo.bytes != null) {
        contenido = utf8.decode(archivo.bytes!);
      } else if (archivo.path != null) {
        contenido = await File(archivo.path!).readAsString();
      } else {
        throw const FormatException('El archivo no trajo datos.');
      }
      final decodificado = jsonDecode(contenido);
      if (decodificado is! Map ||
          decodificado['aplicacion'] != 'finanzas-hogar') {
        throw const FormatException('No es un respaldo de esta app.');
      }
      final datos = decodificado.map((k, v) => MapEntry(k.toString(), v));
      int cuenta(String clave) =>
          datos[clave] is List ? (datos[clave] as List).length : 0;

      if (!mounted) return;
      final confirma = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(textos.importarAvisoTitulo),
          content: Text(
            textos.importarAvisoTexto(
              cuenta('gastos'),
              cuenta('categorias'),
              cuenta('fijos'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(textos.cancelar),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(textos.siImportar),
            ),
          ],
        ),
      );
      if (confirma != true) return;

      final base = ref.read(baseDeDatosProvider);
      await base.importarDatos(datos);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.importarListo)),
      );
    } on FormatException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.archivoNoValido)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(textos.archivoNoValido)),
      );
    } finally {
      if (mounted) setState(() => _trabajando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    return Scaffold(
      appBar: AppBar(title: Text(textos.respaldo)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            textos.respaldoIntro,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            icon: const Icon(Icons.upload_file, size: 28),
            label: Text(textos.exportarMisDatos),
            onPressed: _trabajando ? null : _exportar,
          ),
          const SizedBox(height: 8),
          Text(textos.exportarAyuda),
          const SizedBox(height: 28),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(64),
            ),
            icon: const Icon(Icons.download, size: 28),
            label: Text(textos.importarDatos),
            onPressed: _trabajando ? null : _importar,
          ),
          const SizedBox(height: 8),
          Text(textos.importarAyuda),
          if (_trabajando) ...[
            const SizedBox(height: 28),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
