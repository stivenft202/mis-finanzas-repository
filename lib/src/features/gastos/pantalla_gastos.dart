/// Lista completa de gastos del mes, con opción de eliminar (con
/// confirmación y botón «Deshacer») y de editar tocando un gasto.
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/monedas/monedas.dart';
import '../../core/providers.dart';
import '../../core/utilidades/fechas.dart';
import 'pantalla_inicio.dart';

class PantallaGastos extends ConsumerWidget {
  const PantallaGastos({super.key});

  Future<void> _eliminar(
    BuildContext context,
    WidgetRef ref,
    Gasto gasto,
  ) async {
    final textos = context.textos;
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(textos.confirmarEliminarGasto),
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
    if (confirmar != true || !context.mounted) return;
    final base = ref.read(baseDeDatosProvider);
    await base.eliminarGasto(gasto.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textos.gastoEliminado),
        action: SnackBarAction(
          label: textos.deshacer,
          onPressed: () async {
            // Se restaura con los mismos datos (recibe un id nuevo).
            await base.crearGasto(
              GastosCompanion.insert(
                montoMenor: gasto.montoMenor,
                moneda: Value(gasto.moneda),
                tasaBase: Value(gasto.tasaBase),
                montoBaseMenor: gasto.montoBaseMenor,
                fecha: gasto.fecha,
                categoriaId: gasto.categoriaId,
                descripcion: Value(gasto.descripcion),
                hechoPor: Value(gasto.hechoPor),
                metodoPago: Value(gasto.metodoPago),
                fotoRuta: Value(gasto.fotoRuta),
                creadoEn: gasto.creadoEn,
                actualizadoEn: DateTime.now(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = context.textos;
    final mes = ref.watch(mesSeleccionadoProvider);
    final gastos = ref.watch(gastosDelMesProvider);
    final total = ref.watch(totalDelMesProvider);
    final categorias = ref.watch(categoriasTodasProvider).value ?? const [];
    final editable = ref.watch(puedeEditarProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${textos.verGastos} · ${nombreDelMes(mes)}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: total.when(
              data: (valor) => Text(
                '${textos.gastosDeEsteMes}: ${formatoMoneda(valor, monedaPorDefecto)}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: gastos.when(
              data: (lista) {
                if (lista.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(textos.sinGastosEsteMes),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (context, i) {
                    final gasto = lista[i];
                    return Row(
                      children: [
                        Expanded(
                          child: TileGasto(
                            gasto: gasto,
                            categorias: categorias,
                            editable: editable,
                          ),
                        ),
                        if (editable)
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: textos.eliminar,
                            onPressed: () => _eliminar(context, ref, gasto),
                          ),
                      ],
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(textos.sinGastosEsteMes)),
            ),
          ),
        ],
      ),
    );
  }
}
