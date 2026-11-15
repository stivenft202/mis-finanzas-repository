/// Pantalla de acceso: la persona toca su nombre y entra con su PIN
/// (rápido) o con su contraseña. También sirve para desbloquear la
/// app cuando se bloqueó sola por inactividad.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/providers.dart';
import '../../core/seguridad/autenticacion.dart';
import 'roles_ui.dart';

class PantallaAcceso extends ConsumerStatefulWidget {
  const PantallaAcceso({super.key});

  @override
  ConsumerState<PantallaAcceso> createState() => _Estado();
}

class _Estado extends ConsumerState<PantallaAcceso> {
  int? _seleccionadoId;
  bool _usarClave = false;
  final _pin = TextEditingController();
  final _clave = TextEditingController();
  String? _error;
  Duration? _restante;
  bool _entrando = false;

  @override
  void dispose() {
    _pin.dispose();
    _clave.dispose();
    super.dispose();
  }

  Usuario? _buscar(List<Usuario> usuarios, int? id) {
    for (final u in usuarios) {
      if (u.id == id) return u;
    }
    return null;
  }

  void _seleccionar(Usuario usuario) {
    setState(() {
      _seleccionadoId = usuario.id;
      _error = null;
      _restante = null;
      _pin.clear();
      _clave.clear();
    });
    _revisarBloqueo(usuario.id);
  }

  Future<void> _revisarBloqueo(int usuarioId) async {
    final restante = await ref
        .read(servicioAutenticacionProvider)
        .bloqueoRestante(usuarioId);
    if (mounted) setState(() => _restante = restante);
  }

  Future<void> _intentar(Usuario usuario) async {
    final textos = context.textos;
    final servicio = ref.read(servicioAutenticacionProvider);
    setState(() {
      _entrando = true;
      _error = null;
    });
    final resultado = _usarClave
        ? await servicio.entrarConClave(usuario.id, _clave.text)
        : await servicio.entrarConPin(usuario.id, _pin.text);
    if (!mounted) return;
    switch (resultado) {
      case ResultadoAcceso.correcto:
        ref.read(controlAccesoProvider.notifier).entrar(usuario.id);
      case ResultadoAcceso.incorrecto:
        final restante = await servicio.bloqueoRestante(usuario.id);
        setState(() {
          _entrando = false;
          _restante = restante;
          _error = restante != null
              ? textos.accesoBloqueado(restante.inSeconds + 1)
              : (_usarClave ? textos.claveIncorrecta : textos.pinIncorrecto);
        });
      case ResultadoAcceso.bloqueado:
        final restante = await servicio.bloqueoRestante(usuario.id);
        setState(() {
          _entrando = false;
          _restante = restante;
          _error = textos.accesoBloqueado((restante?.inSeconds ?? 0) + 1);
        });
      case ResultadoAcceso.sinCredenciales:
        setState(() {
          _entrando = false;
          _error = textos.sinCredencialesAviso;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final usuarios = ref.watch(usuariosProvider).value ?? const <Usuario>[];
    final acceso = ref.watch(controlAccesoProvider);
    final bloqueada = acceso.bloqueada && acceso.usuarioId != null
        ? _buscar(usuarios, acceso.usuarioId)
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(textos.tituloApp)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.lock, size: 56),
          const SizedBox(height: 12),
          if (bloqueada != null) ...[
            Text(
              textos.appBloqueada,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _tarjetaPersona(context, bloqueada, seleccionada: true),
            const SizedBox(height: 16),
            _formulario(context, bloqueada, soloPin: true),
            const SizedBox(height: 12),
            TextButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: Text(textos.cambiarDeUsuario),
              onPressed: () =>
                  ref.read(controlAccesoProvider.notifier).salir(),
            ),
          ] else ...[
            Text(
              textos.eligeTuUsuario,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            for (final usuario in usuarios) ...[
              _tarjetaPersona(
                context,
                usuario,
                seleccionada:
                    (usuario.id == (_seleccionadoId ?? usuarios.first.id)),
                alTocar: () => _seleccionar(usuario),
              ),
              const SizedBox(height: 8),
            ],
            if (usuarios.isNotEmpty) ...[
              const SizedBox(height: 8),
              _formulario(
                context,
                _buscar(usuarios, _seleccionadoId) ?? usuarios.first,
                soloPin: false,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _tarjetaPersona(
    BuildContext context,
    Usuario usuario, {
    required bool seleccionada,
    VoidCallback? alTocar,
  }) {
    final esquema = Theme.of(context).colorScheme;
    return Card(
      color: seleccionada ? esquema.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: esquema.primary,
          foregroundColor: esquema.onPrimary,
          child: Text(
            usuario.nombre.trim().isEmpty
                ? '?'
                : usuario.nombre.trim()[0].toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(usuario.nombre),
        subtitle: Text(nombreRol(context, usuario.rol)),
        trailing: Icon(iconoRol(usuario.rol)),
        onTap: alTocar,
      ),
    );
  }

  Widget _formulario(BuildContext context, Usuario usuario,
      {required bool soloPin}) {
    final textos = context.textos;
    final bloqueado = _restante != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_usarClave && !soloPin)
          TextField(
            controller: _clave,
            decoration: InputDecoration(
              labelText: textos.contrasena,
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
            onSubmitted: (_) => _intentar(usuario),
          )
        else
          TextField(
            controller: _pin,
            decoration: InputDecoration(
              labelText: textos.pin,
              prefixIcon: const Icon(Icons.pin),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 8),
            onSubmitted: (_) => _intentar(usuario),
          ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          style:
              FilledButton.styleFrom(minimumSize: const Size.fromHeight(60)),
          icon: const Icon(Icons.login, size: 26),
          label: Text(textos.entrar),
          onPressed: (_entrando || bloqueado) ? null : () => _intentar(usuario),
        ),
        if (!soloPin) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => setState(() {
              _usarClave = !_usarClave;
              _error = null;
            }),
            child: Text(_usarClave ? textos.usarPin : textos.usarContrasena),
          ),
        ],
      ],
    );
  }
}
