/// Módulo «Fijos del mes»: el tablero de planeación mensual de Esteban.
///
/// Dos tablas parecidas a Excel (gastos fijos e ingresos fijos) con las
/// columnas que pidió: nombre, descripción, valor y fecha recurrente
/// (día del mes). Cada tabla cierra con su TOTAL y abajo va el
/// resultado: UTILIDAD / DEUDA = ingresos − gastos, en verde si sobra
/// y en rojo si falta.
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/monedas/monedas.dart';
import '../../core/providers.dart';
import 'formulario_fijo.dart';

/// Suma de los montos de una lista de fijos.
int totalDeFijos(List<Fijo> fijos) =>
    fijos.fold<int>(0, (suma, f) => suma + f.montoMenor);

class PantallaFijos extends ConsumerWidget {
  const PantallaFijos({super.key});

  Future<void> _abrirFormulario(
    BuildContext context,
    WidgetRef ref, {
    required String tipo,
    Fijo? fijo,
  }) async {
    final textos = context.textos;
    final borrado = await Navigator.of(context).push<Fijo>(
      MaterialPageRoute(
        builder: (_) => FormularioFijo(tipo: tipo, fijo: fijo),
      ),
    );
    if (borrado == null || !context.mounted) return;
    // El formulario devolvió un fijo borrado: avisar y ofrecer deshacer.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(textos.fijoEliminado),
        action: SnackBarAction(
          label: textos.deshacer,
          onPressed: () async {
            final ahora = DateTime.now();
            await ref.read(baseDeDatosProvider).crearFijo(
                  FijosCompanion.insert(
                    tipo: borrado.tipo,
                    nombre: borrado.nombre,
                    descripcion: Value(borrado.descripcion),
                    montoMenor: borrado.montoMenor,
                    moneda: Value(borrado.moneda),
                    diaDelMes: borrado.diaDelMes,
                    creadoEn: ahora,
                    actualizadoEn: ahora,
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
    final gastosAsync = ref.watch(gastosFijosProvider);
    final ingresosAsync = ref.watch(ingresosFijosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(textos.fijosDelMes)),
      body: gastosAsync.when(
        data: (gastos) => ingresosAsync.when(
          data: (ingresos) => _contenido(context, ref, gastos, ingresos),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _contenido(context, ref, gastos, const []),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(textos.sinGastosFijos)),
      ),
    );
  }

  Widget _contenido(
    BuildContext context,
    WidgetRef ref,
    List<Fijo> gastos,
    List<Fijo> ingresos,
  ) {
    final textos = context.textos;
    final totalGastos = totalDeFijos(gastos);
    final totalIngresos = totalDeFijos(ingresos);
    final resultado = totalIngresos - totalGastos;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _TablaFijos(
          encabezado: textos.gastosFijos,
          columnaNombre: textos.gastoFijo,
          fijos: gastos,
          textoVacio: textos.sinGastosFijos,
          textoTotal: textos.totalGastos,
          onTocar: (fijo) =>
              _abrirFormulario(context, ref, tipo: 'gasto', fijo: fijo),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          icon: const Icon(Icons.add_circle, size: 26),
          label: Text(textos.agregarGastoFijo),
          onPressed: () => _abrirFormulario(context, ref, tipo: 'gasto'),
        ),
        const SizedBox(height: 28),
        _TablaFijos(
          encabezado: textos.ingresosFijos,
          columnaNombre: textos.ingresoFijo,
          fijos: ingresos,
          textoVacio: textos.sinIngresosFijos,
          textoTotal: textos.totalIngresos,
          onTocar: (fijo) =>
              _abrirFormulario(context, ref, tipo: 'ingreso', fijo: fijo),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
          icon: const Icon(Icons.add_circle, size: 26),
          label: Text(textos.agregarIngresoFijo),
          onPressed: () => _abrirFormulario(context, ref, tipo: 'ingreso'),
        ),
        const SizedBox(height: 28),
        _Resultado(resultado: resultado),
      ],
    );
  }
}

/// Una tabla de fijos con su fila de TOTAL.
class _TablaFijos extends StatelessWidget {
  const _TablaFijos({
    required this.encabezado,
    required this.columnaNombre,
    required this.fijos,
    required this.textoVacio,
    required this.textoTotal,
    required this.onTocar,
  });

  final String encabezado;
  final String columnaNombre;
  final List<Fijo> fijos;
  final String textoVacio;
  final String textoTotal;
  final void Function(Fijo fijo) onTocar;

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final esquema = Theme.of(context).colorScheme;
    final estiloEncabezado = Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: esquema.onSurfaceVariant,
        );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: esquema.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Text(
              encabezado,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text(columnaNombre, style: estiloEncabezado)),
                Expanded(flex: 3, child: Text(textos.descripcionCorta, style: estiloEncabezado)),
                Expanded(
                  flex: 2,
                  child: Text(textos.valor,
                      style: estiloEncabezado, textAlign: TextAlign.right),
                ),
                Expanded(
                  flex: 2,
                  child: Text(textos.fechaRecurrente,
                      style: estiloEncabezado, textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (fijos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(textoVacio),
            )
          else
            for (var i = 0; i < fijos.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              InkWell(
                onTap: () => onTocar(fijos[i]),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          fijos[i].nombre,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          fijos[i].descripcion.trim().isEmpty
                              ? '—'
                              : fijos[i].descripcion,
                          style: TextStyle(color: esquema.onSurfaceVariant),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          formatoMoneda(fijos[i].montoMenor, fijos[i].moneda),
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          textos.diaDelMes(fijos[i].diaDelMes),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          const Divider(height: 1),
          Container(
            color: esquema.surfaceContainerHighest,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    textoTotal,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Text(
                  formatoMoneda(totalDeFijos(fijos), monedaPorDefecto),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// El letrero final: UTILIDAD / DEUDA, verde si sobra y rojo si falta.
class _Resultado extends StatelessWidget {
  const _Resultado({required this.resultado});

  /// Ingresos fijos − gastos fijos, en unidades menores de la moneda base.
  final int resultado;

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final sobra = resultado >= 0;
    final color = sobra ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
    final leyenda =
        resultado == 0 ? textos.enCero : (sobra ? textos.teSobra : textos.teFalta);
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              textos.utilidadDeuda,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              formatoMoneda(resultado, monedaPorDefecto),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              leyenda,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
