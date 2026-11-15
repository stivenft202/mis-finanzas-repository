/// Formulario para agregar una persona del hogar (solo administradores).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/providers.dart';
import '../../core/seguridad/autenticacion.dart';
import 'roles_ui.dart';
import '../../core/ui/titulo_appbar.dart';

class FormularioPersona extends ConsumerStatefulWidget {
  const FormularioPersona({super.key});

  @override
  ConsumerState<FormularioPersona> createState() => _Estado();
}

class _Estado extends ConsumerState<FormularioPersona> {
  final _nombre = TextEditingController();
  final _clave = TextEditingController();
  final _pin = TextEditingController();
  String _rol = Roles.miembro;
  String? _error;
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _clave.dispose();
    _pin.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final textos = context.textos;
    final nombre = _nombre.text.trim();
    String? error;
    if (nombre.isEmpty) {
      error = textos.errorNombre;
    } else if (errorDeClave(_clave.text) != null) {
      error = errorDeClave(_clave.text);
    } else if (errorDePin(_pin.text) != null) {
      error = errorDePin(_pin.text);
    }
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _guardando = true;
      _error = null;
    });
    try {
      await ref
          .read(servicioAutenticacionProvider)
          .crearPersona(
            nombre: nombre,
            rol: _rol,
            clave: _clave.text,
            pin: _pin.text,
          );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(textos.personaCreada)));
        Navigator.of(context).pop();
      }
    } on ArgumentError catch (e) {
      setState(() {
        _guardando = false;
        _error = e.message as String?;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    return Scaffold(
      appBar: AppBar(title: TituloAppBar(textos.agregarPersona)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nombre,
            decoration: InputDecoration(
              labelText: textos.nombrePersona,
              prefixIcon: const Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _rol,
            decoration: InputDecoration(
              labelText: textos.rol,
              prefixIcon: const Icon(Icons.badge),
            ),
            items: [
              for (final rol in Roles.todos)
                DropdownMenuItem(
                  value: rol,
                  child: Text(nombreRol(context, rol)),
                ),
            ],
            onChanged: (valor) => setState(() => _rol = valor ?? Roles.miembro),
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
            icon: const Icon(Icons.person_add, size: 26),
            label: Text(textos.guardar),
            onPressed: _guardando ? null : _guardar,
          ),
        ],
      ),
    );
  }
}
