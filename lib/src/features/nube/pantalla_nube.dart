/// Pantalla «Nube del hogar» (v0.8.0): crear la cuenta del hogar o
/// entrar con ella, ver el estado de la sincronización, sincronizar
/// a mano, resolver el choque de la primera vez y salir de la cuenta
/// en este equipo.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/providers.dart';
import '../../core/ui/titulo_appbar.dart';
import '../../core/utilidades/fechas.dart';
import 'cliente_nube.dart';
import 'config_nube.dart';
import 'servicio_nube.dart';

class PantallaNube extends ConsumerStatefulWidget {
  const PantallaNube({super.key});

  @override
  ConsumerState<PantallaNube> createState() => _Estado();
}

class _Estado extends ConsumerState<PantallaNube> {
  final _correoCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  bool _ocupado = false;

  @override
  void dispose() {
    _correoCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _conCuenta({required bool crear}) async {
    final textos = context.textos;
    final correo = _correoCtrl.text.trim();
    final clave = _claveCtrl.text;
    if (correo.isEmpty || clave.isEmpty) {
      _aviso(textos.faltaCorreoClaveNube);
      return;
    }
    setState(() => _ocupado = true);
    final servicio = ref.read(servicioNubeProvider);
    try {
      if (crear) {
        await servicio.crearCuenta(correo, clave);
      } else {
        await servicio.entrar(correo, clave);
      }
    } on ErrorNube catch (e) {
      if (mounted) _aviso(e.mensaje);
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _resolver(ResolucionConflicto resolucion) async {
    await ref.read(servicioNubeProvider).sincronizar(resolucion: resolucion);
  }

  Future<void> _salirCuenta() async {
    final textos = context.textos;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(textos.salirCuentaEquipo),
        content: Text(textos.salirCuentaExplicacion),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(textos.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(textos.salir),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    await ref.read(servicioNubeProvider).salirCuenta();
  }

  String _cuando(DateTime fecha) {
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
    return '${fechaCorta(fecha)} · $hora';
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final servicio = ref.watch(servicioNubeProvider);
    return Scaffold(
      appBar: AppBar(title: TituloAppBar(textos.nubeDelHogar)),
      body: ValueListenableBuilder<EstadoNube>(
        valueListenable: servicio.estadoNotifier,
        builder: (context, estado, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (!ConfigNube.configurada)
                Card(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(textos.nubeNoConfigurada),
                  ),
                )
              else if (!estado.conectado) ...[
                Text(textos.nubeExplicacion),
                const SizedBox(height: 20),
                TextField(
                  controller: _correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: textos.nubeCorreo,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _claveCtrl,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: textos.nubeContrasena,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(textos.crearCuentaHogar),
                  onPressed:
                      _ocupado ? null : () => _conCuenta(crear: true),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.login),
                  label: Text(textos.yaTengoCuenta),
                  onPressed:
                      _ocupado ? null : () => _conCuenta(crear: false),
                ),
                if (_ocupado) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator()),
                ],
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.cloud_done),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${textos.conectadoComo} ${estado.correo ?? ''}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          estado.ultimoSync == null
                              ? textos.nuncaSincronizado
                              : '${textos.ultimaSincronizacion} '
                                  '${_cuando(estado.ultimoSync!)}',
                        ),
                        if (estado.sincronizando)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(textos.sincronizando),
                          )
                        else if (estado.ultimoResultado ==
                            ResultadoSync.subido)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(textos.nubeSubidoOk),
                          )
                        else if (estado.ultimoResultado ==
                            ResultadoSync.bajado)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(textos.nubeBajadoOk),
                          )
                        else if (estado.ultimoResultado == ResultadoSync.nada)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(textos.nubeAlDia),
                          ),
                        if (estado.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              estado.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (estado.hayConflicto) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textos.nubeConflictoTitulo,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(textos.nubeConflictoExplicacion),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            icon: const Icon(Icons.cloud_download),
                            label: Text(textos.usarDatosNube),
                            onPressed: estado.sincronizando
                                ? null
                                : () => _resolver(ResolucionConflicto.usarNube),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                            ),
                            icon: const Icon(Icons.phone_android),
                            label: Text(textos.usarDatosEquipo),
                            onPressed: estado.sincronizando
                                ? null
                                : () =>
                                    _resolver(ResolucionConflicto.usarEsteEquipo),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                  ),
                  icon: const Icon(Icons.sync),
                  label: Text(textos.sincronizarAhora),
                  onPressed: estado.sincronizando
                      ? null
                      : () => servicio.sincronizar(),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.logout),
                  label: Text(textos.salirCuentaEquipo),
                  onPressed: _salirCuenta,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
