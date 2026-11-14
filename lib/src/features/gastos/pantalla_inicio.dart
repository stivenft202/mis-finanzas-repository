/// Pantalla de inicio: el total del mes en grande, accesos rápidos y
/// los últimos gastos. (El saldo completo con ingresos llega en la Fase 4.)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/monedas/monedas.dart';
import '../../core/providers.dart';
import '../../core/utilidades/fechas.dart';
import '../categorias/iconos_categoria.dart';
import '../categorias/pantalla_categorias.dart';
import 'formulario_gasto.dart';
import 'pantalla_gastos.dart';

class PantallaInicio extends ConsumerWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = context.textos;
    final mes = ref.watch(mesSeleccionadoProvider);
    final total = ref.watch(totalDelMesProvider);
    final gastos = ref.watch(gastosDelMesProvider);
    final categorias = ref.watch(categoriasTodasProvider).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(textos.tituloApp)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${textos.gastosDeEsteMes} · ${nombreDelMes(mes)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  total.when(
                    data: (valor) => Text(
                      formatoMoneda(valor, monedaPorDefecto),
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => const Text('—'),
                  ),
                  const SizedBox(height: 4),
                  gastos.when(
                    data: (lista) =>
                        Text(textos.cantidadDeGastos(lista.length)),
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style:
                FilledButton.styleFrom(minimumSize: const Size.fromHeight(64)),
            icon: const Icon(Icons.add_circle, size: 28),
            label: Text(textos.agregarGasto),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const FormularioGasto()),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.list_alt),
                  label: Text(textos.verGastos),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantallaGastos()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.category),
                  label: Text(textos.categorias),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PantallaCategorias()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            textos.ultimosGastos,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          gastos.when(
            data: (lista) {
              if (lista.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(textos.sinGastosEsteMes),
                );
              }
              return Column(
                children: [
                  for (final gasto in lista.take(8))
                    TileGasto(gasto: gasto, categorias: categorias),
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text(textos.sinGastosEsteMes),
          ),
        ],
      ),
    );
  }
}

/// Una fila de gasto, reutilizada en el inicio y en la lista completa.
class TileGasto extends StatelessWidget {
  const TileGasto({super.key, required this.gasto, required this.categorias});

  final Gasto gasto;
  final List<Categoria> categorias;

  @override
  Widget build(BuildContext context) {
    final categoria = categoriaPorId(categorias, gasto.categoriaId);
    final color = Color(categoria?.colorValor ?? 0xFF455A64);
    final titulo = gasto.descripcion.trim().isNotEmpty
        ? gasto.descripcion
        : (categoria?.nombre ?? '');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: color,
        foregroundColor: Colors.white,
        child: Icon(iconoDeCategoria(categoria?.icono ?? 'otros')),
      ),
      title: Text(titulo),
      subtitle: Text('${fechaCorta(gasto.fecha)} · ${gasto.hechoPor}'),
      trailing: Text(
        formatoMoneda(gasto.montoMenor, gasto.moneda),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => FormularioGasto(gasto: gasto)),
      ),
    );
  }
}
