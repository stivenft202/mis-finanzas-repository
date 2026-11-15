/// Pantalla de categorías: ver, crear, editar, ocultar y eliminar.
///
/// Eliminar solo se permite si la categoría no tiene gastos; si tiene,
/// se sugiere ocultarla para no perder el historial.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/providers.dart';
import 'formulario_categoria.dart';
import 'iconos_categoria.dart';
import '../../core/ui/titulo_appbar.dart';

class PantallaCategorias extends ConsumerWidget {
  const PantallaCategorias({super.key});

  Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    Categoria categoria,
  ) async {
    final textos = context.textos;
    final base = ref.read(baseDeDatosProvider);
    final cantidad = await base.contarGastosDeCategoria(categoria.id);
    if (!context.mounted) return;
    if (cantidad > 0) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(textos.categoriaConGastos),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(textos.guardar),
            ),
          ],
        ),
      );
      return;
    }
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(textos.confirmarEliminarCategoria),
        content: Text(categoria.nombre),
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
    if (confirmar == true) {
      await base.eliminarCategoria(categoria.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = context.textos;
    final categoriasAsync = ref.watch(categoriasTodasProvider);
    final editable = ref.watch(puedeEditarProvider);

    return Scaffold(
      appBar: AppBar(title: TituloAppBar(textos.categorias)),
      floatingActionButton: editable
          ? FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: Text(textos.nuevaCategoria),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FormularioCategoria()),
              ),
            )
          : null,
      body: categoriasAsync.when(
        data: (categorias) => ListView.builder(
          padding: const EdgeInsets.only(bottom: 96),
          itemCount: categorias.length,
          itemBuilder: (context, i) {
            final c = categorias[i];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(c.colorValor)
                    .withValues(alpha: c.oculta ? 0.35 : 1),
                foregroundColor: Colors.white,
                child: Icon(iconoDeCategoria(c.icono)),
              ),
              title: Text(
                c.nombre,
                style: c.oculta
                    ? TextStyle(color: Theme.of(context).disabledColor)
                    : null,
              ),
              subtitle: c.tipoFactura == null || c.tipoFactura!.isEmpty
                  ? null
                  : Text(c.tipoFactura!),
              trailing: !editable
                  ? null
                  : PopupMenuButton<String>(
                      onSelected: (accion) async {
                        final base = ref.read(baseDeDatosProvider);
                        switch (accion) {
                          case 'editar':
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    FormularioCategoria(categoria: c),
                              ),
                            );
                          case 'ocultar':
                            await base.actualizarCategoria(
                              c.copyWith(oculta: !c.oculta),
                            );
                          case 'eliminar':
                            if (!context.mounted) return;
                            await _eliminar(context, ref, c);
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'editar',
                          child: Text(textos.editar),
                        ),
                        PopupMenuItem(
                          value: 'ocultar',
                          child: Text(
                            c.oculta ? textos.mostrar : textos.ocultar,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Text(textos.eliminar),
                        ),
                      ],
                    ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(textos.sinGastosEsteMes)),
      ),
    );
  }
}
