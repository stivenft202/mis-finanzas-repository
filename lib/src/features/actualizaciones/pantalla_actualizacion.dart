/// Pantalla «Actualización»: muestra la versión instalada, permite
/// buscar si hay una nueva y, si la hay, la descarga y la instala
/// desde la propia app (v0.5.0).
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import 'servicio_actualizacion.dart';

class PantallaActualizacion extends ConsumerStatefulWidget {
  const PantallaActualizacion({super.key});

  @override
  ConsumerState<PantallaActualizacion> createState() =>
      _PantallaActualizacionState();
}

class _PantallaActualizacionState extends ConsumerState<PantallaActualizacion> {
  bool _buscando = false;
  bool _descargando = false;
  double? _progreso;
  bool _yaBusco = false;
  InfoActualizacion? _info;
  String? _mensaje;
  bool _mensajeEsError = false;

  Future<void> _buscar() async {
    final textos = context.textos;
    setState(() {
      _buscando = true;
      _mensaje = null;
    });
    try {
      final encontrada = await buscarActualizacion();
      if (!mounted) return;
      setState(() {
        _info = encontrada;
        _yaBusco = true;
        _mensaje = encontrada == null ? textos.yaTienesLaUltima : null;
        _mensajeEsError = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _yaBusco = true;
        _mensaje = textos.errorAlBuscarActualizacion;
        _mensajeEsError = true;
      });
    } finally {
      if (mounted) setState(() => _buscando = false);
    }
  }

  Future<void> _actualizar() async {
    final textos = context.textos;
    final info = _info;
    if (info == null) return;

    if (Platform.isWindows) {
      final confirma = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(textos.actualizarAhora),
          content: Text(textos.actualizarAvisoWindows),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(textos.cancelar),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(textos.actualizarAhora),
            ),
          ],
        ),
      );
      if (confirma != true) return;
    }

    setState(() {
      _descargando = true;
      _progreso = null;
      _mensaje = null;
    });
    try {
      final archivo = await descargarActualizacion(
        info,
        alProgreso: (p) {
          if (mounted) setState(() => _progreso = p);
        },
      );
      if (Platform.isAndroid) {
        await instalarEnAndroid(archivo);
        if (!mounted) return;
        setState(() {
          _mensaje = textos.instaladorAbierto;
          _mensajeEsError = false;
        });
      } else if (Platform.isWindows) {
        await aplicarEnWindows(archivo); // La app se cierra aquí.
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _mensaje = textos.errorAlActualizar;
        _mensajeEsError = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _descargando = false;
          _progreso = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final versionActual = ref.watch(versionActualProvider);
    // Si la revisión automática del inicio ya encontró una, se ofrece.
    final automatica = ref.watch(actualizacionDisponibleProvider).value;
    final info = _info ?? automatica;
    final esquema = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(textos.actualizacion)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          versionActual.when(
            data: (v) => Text(
              textos.versionActual('v$v'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 24),
          if (info != null && !_descargando) ...[
            Card(
              color: esquema.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      textos.hayVersionNueva(info.version),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: esquema.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                      ),
                      icon: const Icon(Icons.system_update, size: 26),
                      label: Text(textos.actualizarAhora),
                      onPressed: _actualizar,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_descargando) ...[
            Text(textos.descargandoActualizacion),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _progreso),
            const SizedBox(height: 16),
          ],
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
            ),
            icon: const Icon(Icons.refresh, size: 26),
            label: Text(
              _buscando ? textos.buscandoActualizacion : textos.buscarActualizacion,
            ),
            onPressed: (_buscando || _descargando) ? null : _buscar,
          ),
          if (_mensaje != null) ...[
            const SizedBox(height: 20),
            Text(
              _mensaje!,
              style: TextStyle(
                color: _mensajeEsError ? esquema.error : null,
                fontSize: 16,
              ),
            ),
          ],
          if (_yaBusco && info == null && _mensaje == null)
            const SizedBox.shrink(),
        ],
      ),
    );
  }
}
