/// Formulario para registrar o editar un gasto.
///
/// Diseñado para el caso típico en máximo 4 toques:
/// monto → categoría → Guardar (la fecha, el método y la persona ya
/// vienen prellenados con lo más habitual).
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/monedas/monedas.dart';
import '../../core/providers.dart';
import '../../core/utilidades/fechas.dart';
import '../categorias/iconos_categoria.dart';
import '../../core/ui/titulo_appbar.dart';

class FormularioGasto extends ConsumerStatefulWidget {
  const FormularioGasto({super.key, this.gasto});

  /// Si viene un gasto, el formulario edita; si no, crea uno nuevo.
  final Gasto? gasto;

  @override
  ConsumerState<FormularioGasto> createState() => _FormularioGastoState();
}

class _FormularioGastoState extends ConsumerState<FormularioGasto> {
  final _montoCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _hechoPorCtrl = TextEditingController(text: 'Yo');
  int? _categoriaId;
  String _metodoPago = 'efectivo';
  DateTime _fecha = DateTime.now();
  String? _error;

  @override
  void initState() {
    super.initState();
    final g = widget.gasto;
    if (g != null) {
      final moneda = monedaPorCodigo(g.moneda);
      _montoCtrl.text = (g.montoMenor / moneda.factor).toStringAsFixed(
        moneda.decimales == 0 ? 0 : moneda.decimales,
      );
      _descripcionCtrl.text = g.descripcion;
      _hechoPorCtrl.text = g.hechoPor;
      _categoriaId = g.categoriaId;
      _metodoPago = g.metodoPago;
      _fecha = g.fecha;
    }
  }

  @override
  void dispose() {
    _montoCtrl.dispose();
    _descripcionCtrl.dispose();
    _hechoPorCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final textos = context.textos;
    // En la Fase 1 la moneda es la del hogar (COP). El selector de moneda
    // junto al monto llega con el sistema multimoneda de la Fase 4.
    const moneda = monedaPorDefecto;
    final monto = textoAMontoMenor(_montoCtrl.text, moneda);
    if (monto == null || monto <= 0) {
      setState(() => _error = textos.errorMonto);
      return;
    }
    if (_categoriaId == null) {
      setState(() => _error = textos.errorCategoria);
      return;
    }
    final base = ref.read(baseDeDatosProvider);
    final ahora = DateTime.now();
    final hechoPor = _hechoPorCtrl.text.trim().isEmpty
        ? 'Yo'
        : _hechoPorCtrl.text.trim();
    final existente = widget.gasto;
    if (existente == null) {
      await base.crearGasto(
        GastosCompanion.insert(
          montoMenor: monto,
          moneda: Value(moneda),
          tasaBase: const Value(1.0),
          montoBaseMenor: monto,
          fecha: _fecha,
          categoriaId: _categoriaId!,
          descripcion: Value(_descripcionCtrl.text.trim()),
          hechoPor: Value(hechoPor),
          metodoPago: Value(_metodoPago),
          creadoEn: ahora,
          actualizadoEn: ahora,
        ),
      );
    } else {
      await base.actualizarGasto(
        existente.copyWith(
          montoMenor: monto,
          descripcion: _descripcionCtrl.text.trim(),
          hechoPor: hechoPor,
          metodoPago: _metodoPago,
          fecha: _fecha,
          categoriaId: _categoriaId!,
          actualizadoEn: ahora,
        ),
      );
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(textos.gastoGuardado)));
    Navigator.of(context).pop();
  }

  bool _hechoPorListo = false;

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    final categoriasAsync = ref.watch(categoriasVisiblesProvider);
    final soloLectura = !ref.watch(puedeEditarProvider);
    // En un gasto nuevo, «¿Quién lo hizo?» viene con el nombre de la
    // persona que entró (se puede cambiar si registró por otra).
    final yo = ref.watch(usuarioActualProvider);
    if (widget.gasto == null && !_hechoPorListo && yo != null) {
      _hechoPorCtrl.text = yo.nombre;
      _hechoPorListo = true;
    }
    final metodos = <String, String>{
      'efectivo': textos.efectivo,
      'tarjeta': textos.tarjeta,
      'transferencia': textos.transferencia,
      'otro': textos.otro,
    };

    return Scaffold(
      appBar: AppBar(
        title: TituloAppBar(
          widget.gasto == null
              ? textos.agregarGasto
              : '${textos.editar} · ${textos.agregarGasto}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _montoCtrl,
            enabled: !soloLectura,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.headlineLarge,
            decoration: InputDecoration(
              labelText: '${textos.monto} (${monedaPorDefecto})',
              prefixText: r'$ ',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            textos.categoria,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          categoriasAsync.when(
            data: (categorias) {
              if (_categoriaId == null && categorias.isNotEmpty) {
                _categoriaId = categorias.first.id;
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in categorias)
                    ChoiceChip(
                      avatar: CircleAvatar(
                        backgroundColor: Color(c.colorValor),
                        child: Icon(
                          iconoDeCategoria(c.icono),
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                      label: Text(c.nombre),
                      selected: _categoriaId == c.id,
                      onSelected: soloLectura
                          ? null
                          : (_) => setState(() => _categoriaId = c.id),
                    ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, _) => Text(textos.errorCategoria),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _descripcionCtrl,
            enabled: !soloLectura,
            decoration: InputDecoration(labelText: textos.descripcion),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hechoPorCtrl,
                  enabled: !soloLectura,
                  decoration: InputDecoration(labelText: textos.quienLoHizo),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${textos.fecha}: ${fechaCorta(_fecha)}'),
                  onPressed: soloLectura
                      ? null
                      : () async {
                          final elegida = await showDatePicker(
                            context: context,
                            initialDate: _fecha,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (elegida != null) setState(() => _fecha = elegida);
                        },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            textos.metodoDePago,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final entrada in metodos.entries)
                ChoiceChip(
                  label: Text(entrada.value),
                  selected: _metodoPago == entrada.key,
                  onSelected: soloLectura
                      ? null
                      : (_) => setState(() => _metodoPago = entrada.key),
                ),
            ],
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
          if (soloLectura)
            Text(textos.notaSoloLectura, textAlign: TextAlign.center)
          else
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(64),
              ),
              icon: const Icon(Icons.save, size: 26),
              label: Text(textos.guardar),
              onPressed: _guardar,
            ),
        ],
      ),
    );
  }
}
