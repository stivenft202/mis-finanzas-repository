/// Pantalla «Usuarios»: mi seguridad (contraseña, PIN y bloqueo
/// automático de este equipo) y, para administradores, la gestión de
/// las personas del hogar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/providers.dart';
import '../../core/seguridad/autenticacion.dart';
import 'formulario_persona.dart';
import 'roles_ui.dart';
import '../../core/ui/titulo_appbar.dart';

class PantallaUsuarios extends ConsumerStatefulWidget {
  const PantallaUsuarios({super.key});

  @override
  ConsumerState<PantallaUsuarios> createState() => _Estado();
}

class _Estado extends ConsumerState<PantallaUsuarios> {
  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  /// Diálogo con campos de texto; devuelve los valores escritos o null.
  Future<List<String>?> _dialogoCampos({
    required String titulo,
    required List<(String, bool, TextInputType?)> campos,
    String? errorInicial,
  }) {
    final textos = context.textos;
    final controles = [for (final _ in campos) TextEditingController()];
    String? error = errorInicial;
    return showDialog<List<String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(titulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < campos.length; i++) ...[
                TextField(
                  controller: controles[i],
                  decoration: InputDecoration(labelText: campos[i].$1),
                  obscureText: campos[i].$2,
                  keyboardType: campos[i].$3,
                ),
                const SizedBox(height: 12),
              ],
              if (error != null)
                Text(
                  error,
                  style: TextStyle(color: Theme.of(ctx).colorScheme.error),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(textos.cancelar),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(ctx).pop([for (final c in controles) c.text]),
              child: Text(textos.guardar),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _cambiarMiClave(Usuario yo) async {
    final textos = context.textos;
    final valores = await _dialogoCampos(
      titulo: textos.cambiarContrasena,
      campos: [
        (textos.contrasenaActual, true, null),
        (textos.contrasenaNueva, true, null),
      ],
    );
    if (valores == null || !mounted) return;
    final servicio = ref.read(servicioAutenticacionProvider);
    final errorFormato = errorDeClave(valores[1]);
    if (errorFormato != null) {
      _aviso(errorFormato);
      return;
    }
    if (!await servicio.claveActualCoincide(yo.id, valores[0])) {
      if (mounted) _aviso(textos.errorClaveActual);
      return;
    }
    await servicio.fijarClave(yo.id, valores[1]);
    if (mounted) _aviso(textos.cambiosGuardados);
  }

  Future<void> _cambiarMiPin(Usuario yo) async {
    final textos = context.textos;
    final valores = await _dialogoCampos(
      titulo: textos.cambiarPin,
      campos: [
        (textos.pinActual, true, TextInputType.number),
        (textos.pinNuevo, true, TextInputType.number),
      ],
    );
    if (valores == null || !mounted) return;
    final servicio = ref.read(servicioAutenticacionProvider);
    final errorFormato = errorDePin(valores[1]);
    if (errorFormato != null) {
      _aviso(errorFormato);
      return;
    }
    if (!await servicio.pinActualCoincide(yo.id, valores[0])) {
      if (mounted) _aviso(textos.errorPinActual);
      return;
    }
    await servicio.fijarPin(yo.id, valores[1]);
    if (mounted) _aviso(textos.cambiosGuardados);
  }

  Future<void> _cambiarAutoBloqueo(int minutos) async {
    await ref
        .read(almacenClavesProvider)
        .guardar('autobloqueo_min', minutos.toString());
    ref.invalidate(autoBloqueoMinutosProvider);
    if (mounted) _aviso(context.textos.cambiosGuardados);
  }

  Future<void> _opcionesPersona(Usuario persona, Usuario yo) async {
    final textos = context.textos;
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                persona.nombre,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              subtitle: Text(nombreRol(ctx, persona.rol)),
            ),
            ListTile(
              leading: const Icon(Icons.badge),
              title: Text(textos.cambiarRol),
              onTap: () => Navigator.of(ctx).pop('rol'),
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset),
              title: Text(textos.restablecerClave),
              onTap: () => Navigator.of(ctx).pop('clave'),
            ),
            ListTile(
              leading: const Icon(Icons.pin),
              title: Text(textos.restablecerPin),
              onTap: () => Navigator.of(ctx).pop('pin'),
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(ctx).colorScheme.error,
              ),
              title: Text(
                textos.eliminar,
                style: TextStyle(color: Theme.of(ctx).colorScheme.error),
              ),
              onTap: () => Navigator.of(ctx).pop('eliminar'),
            ),
          ],
        ),
      ),
    );
    if (!mounted || opcion == null) return;
    final servicio = ref.read(servicioAutenticacionProvider);
    final base = ref.read(baseDeDatosProvider);
    switch (opcion) {
      case 'rol':
        final nuevo = await showDialog<String>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(textos.cambiarRol),
            children: [
              for (final rol in Roles.todos)
                SimpleDialogOption(
                  onPressed: () => Navigator.of(ctx).pop(rol),
                  child: Text(nombreRol(ctx, rol)),
                ),
            ],
          ),
        );
        if (nuevo == null || nuevo == persona.rol || !mounted) return;
        if (persona.rol == Roles.administrador &&
            nuevo != Roles.administrador &&
            await base.contarAdministradores() <= 1) {
          if (mounted) _aviso(textos.ultimoAdministrador);
          return;
        }
        await base.actualizarUsuario(persona.copyWith(rol: nuevo));
        if (mounted) _aviso(textos.cambiosGuardados);
      case 'clave':
        final valores = await _dialogoCampos(
          titulo: textos.restablecerClave,
          campos: [(textos.contrasenaNueva, true, null)],
        );
        if (valores == null || !mounted) return;
        final errorFormato = errorDeClave(valores[0]);
        if (errorFormato != null) {
          _aviso(errorFormato);
          return;
        }
        await servicio.fijarClave(persona.id, valores[0]);
        if (mounted) _aviso(textos.cambiosGuardados);
      case 'pin':
        final valores = await _dialogoCampos(
          titulo: textos.restablecerPin,
          campos: [(textos.pinNuevo, true, TextInputType.number)],
        );
        if (valores == null || !mounted) return;
        final errorFormato = errorDePin(valores[0]);
        if (errorFormato != null) {
          _aviso(errorFormato);
          return;
        }
        await servicio.fijarPin(persona.id, valores[0]);
        if (mounted) _aviso(textos.cambiosGuardados);
      case 'eliminar':
        if (persona.id == yo.id) {
          _aviso(textos.noPuedesEliminarte);
          return;
        }
        if (persona.rol == Roles.administrador &&
            await base.contarAdministradores() <= 1) {
          if (mounted) _aviso(textos.ultimoAdministrador);
          return;
        }
        final confirmar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(textos.eliminar),
            content: Text(textos.confirmarEliminarPersona(persona.nombre)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text(textos.cancelar),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text(textos.eliminar),
              ),
            ],
          ),
        );
        if (confirmar != true || !mounted) return;
        await servicio.eliminarPersona(persona.id);
        if (mounted) _aviso(textos.personaEliminada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final yo = ref.watch(usuarioActualProvider);
    final usuarios = ref.watch(usuariosProvider).value ?? const <Usuario>[];
    final esAdmin = ref.watch(puedeAdministrarProvider);
    final autoBloqueo = ref.watch(autoBloqueoMinutosProvider).value ?? 5;

    return Scaffold(
      appBar: AppBar(title: TituloAppBar(textos.usuarios)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            textos.miSeguridad,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (yo != null)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: Text(textos.cambiarContrasena),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _cambiarMiClave(yo),
                  ),
                  ListTile(
                    leading: const Icon(Icons.pin),
                    title: Text(textos.cambiarPin),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _cambiarMiPin(yo),
                  ),
                  // El selector va DEBAJO del título, a todo el ancho:
                  // como botón lateral apretaba el título hasta salir
                  // letra por letra en los celulares (visto por Esteban).
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.timer),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                textos.bloqueoAutomatico,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          initialValue:
                              const [0, 1, 5, 15].contains(autoBloqueo)
                              ? autoBloqueo
                              : 5,
                          items: [
                            DropdownMenuItem(
                              value: 0,
                              child: Text(textos.bloqueoNunca),
                            ),
                            DropdownMenuItem(
                              value: 1,
                              child: Text(textos.bloqueoTras1),
                            ),
                            DropdownMenuItem(
                              value: 5,
                              child: Text(textos.bloqueoTras5),
                            ),
                            DropdownMenuItem(
                              value: 15,
                              child: Text(textos.bloqueoTras15),
                            ),
                          ],
                          onChanged: (valor) {
                            if (valor != null) _cambiarAutoBloqueo(valor);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (esAdmin && yo != null) ...[
            const SizedBox(height: 24),
            Text(
              textos.personasDelHogar,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            for (final persona in usuarios)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      persona.nombre.trim().isEmpty
                          ? '?'
                          : persona.nombre.trim()[0].toUpperCase(),
                    ),
                  ),
                  title: Text(persona.nombre),
                  subtitle: Text(nombreRol(context, persona.rol)),
                  trailing: Icon(iconoRol(persona.rol)),
                  onTap: () => _opcionesPersona(persona, yo),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              icon: const Icon(Icons.person_add),
              label: Text(textos.agregarPersona),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FormularioPersona()),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
