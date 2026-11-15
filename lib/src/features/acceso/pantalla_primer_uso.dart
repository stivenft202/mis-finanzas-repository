/// Primer uso: todavía no hay personas en este equipo, así que se
/// crea la primera, que será la administradora del hogar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/providers.dart';
import '../../core/seguridad/autenticacion.dart';
import '../../core/ui/titulo_appbar.dart';

class PantallaPrimerUso extends ConsumerStatefulWidget {
  const PantallaPrimerUso({super.key});

  @override
  ConsumerState<PantallaPrimerUso> createState() => _Estado();
}

class _Estado extends ConsumerState<PantallaPrimerUso> {
  final _nombre = TextEditingController();
  final _clave = TextEditingController();
  final _clave2 = TextEditingController();
  final _pin = TextEditingController();
  final _pin2 = TextEditingController();
  String? _error;
  bool _creando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _clave.dispose();
    _clave2.dispose();
    _pin.dispose();
    _pin2.dispose();
    super.dispose();
  }

  Future<void> _crear() async {
    final textos = context.textos;
    final nombre = _nombre.text.trim();
    String? error;
    if (nombre.isEmpty) {
      error = textos.errorNombre;
    } else if (errorDeClave(_clave.text) != null) {
      error = errorDeClave(_clave.text);
    } else if (_clave.text != _clave2.text) {
      error = textos.lasClavesNoCoinciden;
    } else if (errorDePin(_pin.text) != null) {
      error = errorDePin(_pin.text);
    } else if (_pin.text != _pin2.text) {
      error = textos.losPinesNoCoinciden;
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _creando = true;
      _error = null;
    });
    try {
      final servicio = ref.read(servicioAutenticacionProvider);
      final usuario = await servicio.crearPersona(
        nombre: nombre,
        rol: Roles.administrador,
        clave: _clave.text,
        pin: _pin.text,
      );
      ref.read(controlAccesoProvider.notifier).entrar(usuario.id);
    } on ArgumentError catch (e) {
      setState(() {
        _creando = false;
        _error = e.message as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    return Scaffold(
      appBar: AppBar(title: TituloAppBar(textos.tituloApp)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.home, size: 64),
          const SizedBox(height: 12),
          Text(
            textos.bienvenidaTitulo,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(textos.creandoAdminIntro, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextField(
            controller: _nombre,
            decoration: InputDecoration(
              labelText: textos.nombrePersona,
              prefixIcon: const Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clave,
            decoration: InputDecoration(
              labelText: textos.contrasena,
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _clave2,
            decoration: InputDecoration(
              labelText: textos.confirmarContrasena,
              prefixIcon: const Icon(Icons.lock),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pin,
            decoration: InputDecoration(
              labelText: textos.pin,
              prefixIcon: const Icon(Icons.pin),
              helperText: textos.pinAyuda,
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pin2,
            decoration: InputDecoration(
              labelText: textos.confirmarPin,
              prefixIcon: const Icon(Icons.pin),
            ),
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(60),
            ),
            icon: const Icon(Icons.check_circle, size: 26),
            label: Text(textos.crearMiUsuario),
            onPressed: _creando ? null : _crear,
          ),
        ],
      ),
    );
  }
}
