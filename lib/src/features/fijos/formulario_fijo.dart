/// Formulario para crear o editar un gasto o ingreso fijo del mes.
///
/// Campos: nombre, descripción (opcional), valor y día del mes en que
/// se repite. Si se está editando, abajo aparece el botón de eliminar
/// (al borrar, la pantalla de la tabla ofrece «Deshacer»).
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/monedas/monedas.dart';
import '../../core/providers.dart';

class FormularioFijo extends ConsumerStatefulWidget {
  const FormularioFijo({super.key, required this.tipo, this.fijo});

  /// 'gasto' o 'ingreso'.
  final String tipo;

  /// Si viene un fijo, el formulario edita; si no, crea uno nuevo.
  final Fijo? fijo;

  @override
  ConsumerState<FormularioFijo> createState() => _FormularioFijoState();
}

class _FormularioFijoState extends ConsumerState<FormularioFijo> {
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _montoCtrl = TextEditingController();
  int _dia = 1;
  String? _error;

  bool get _esGasto => widget.tipo == 'gasto';

  @override
  void initState() {
    super.initState();
    final f = widget.fijo;
    if (f != null) {
      final moneda = monedaPorCodigo(f.moneda);
      _nombreCtrl.text = f.nombre;
      _descripcionCtrl.text = f.descripcion;
      _montoCtrl.text = (f.montoMenor / moneda.factor).toStringAsFixed(
        moneda.decimales == 0 ? 0 : moneda.decimales,
      );
      _dia = f.diaDelMes;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _montoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final textos = context.textos;
    const moneda = monedaPorDefecto;
    if (_nombreCtrl.text.trim().isEmpty) {
      setState(() => _error = textos.errorNombre);
      return;
    }
    final monto = textoAMontoMenor(_montoCtrl.text, moneda);
    if (monto == null || monto <= 0) {
      setState(() => _error = textos.errorMonto);
      return;
    }
    final base = ref.read(baseDeDatosProvider);
    final ahora = DateTime.now();
    final existente = widget.fijo;
    if (existente == null) {
      await base.crearFijo(
        FijosCompanion.insert(
          tipo: widget.tipo,
          nombre: _nombreCtrl.text.trim(),
          descripcion: Value(_descripcionCtrl.text.trim()),
          montoMenor: monto,
          moneda: Value(moneda),
          diaDelMes: _dia,
          creadoEn: ahora,
          actualizadoEn: ahora,
        ),
      );
    } else {
      await base.actualizarFijo(
        existente.copyWith(
          nombre: _nombreCtrl.text.trim(),
          descripcion: _descripcionCtrl.text.trim(),
          montoMenor: monto,
          diaDelMes: _dia,
          actualizadoEn: ahora,
        ),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(textos.fijoGuardado)),
    );
    Navigator.of(context).pop();
  }

  Future<void> _eliminar() async {
    final textos = context.textos;
    final existente = widget.fijo;
    if (existente == null) return;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(textos.confirmarEliminarFijo),
        content: Text(existente.nombre),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(textos.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(textos.eliminar),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;
    await ref.read(baseDeDatosProvider).eliminarFijo(existente.id);
    if (!mounted) return;
    // Devuelve el fijo borrado para que la tabla ofrezca «Deshacer».
    Navigator.of(context).pop(existente);
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final tituloNuevo = _esGasto ? textos.agregarGastoFijo : textos.agregarIngresoFijo;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fijo == null
            ? tituloNuevo
            : '${textos.editar} · $tituloNuevo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombreCtrl,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(
              labelText: _esGasto ? textos.gastoFijo : textos.ingresoFijo,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descripcionCtrl,
            decoration: InputDecoration(labelText: textos.descripcion),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _montoCtrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.headlineLarge,
            decoration: InputDecoration(
              labelText: '${textos.valor} (${monedaPorDefecto})',
              prefixText: r'$ ',
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            initialValue: _dia,
            decoration: InputDecoration(labelText: textos.diaEtiqueta),
            items: [
              for (var d = 1; d <= 31; d++)
                DropdownMenuItem(value: d, child: Text(textos.diaDelMes(d))),
            ],
            onChanged: (valor) {
              if (valor != null) setState(() => _dia = valor);
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 16,
              ),
            ),
          ],
          const SizedBox(height: 28),
          FilledButton.icon(
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64)),
            icon: const Icon(Icons.save, size: 26),
            label: Text(textos.guardar),
            onPressed: _guardar,
          ),
          if (widget.fijo != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              icon: const Icon(Icons.delete_outline),
              label: Text(textos.eliminar),
              onPressed: _eliminar,
            ),
          ],
        ],
      ),
    );
  }
}
