/// Formulario para registrar o editar un gasto.
///
/// Diseñado para el caso típico en máximo 4 toques:
/// monto → categoría → Guardar (la fecha, el método y la persona ya
/// vienen prellenados con lo más habitual).
library;

import 'dart:io' show Platform;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/monedas/monedas.dart';
import '../../core/providers.dart';
import '../../core/utilidades/fechas.dart';
import '../categorias/iconos_categoria.dart';
import '../../core/ui/titulo_appbar.dart';
import 'interprete_dictado.dart';
import 'servicio_dictado.dart';

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

  // Dictado por voz (v0.7.0): lo reconocido llena el formulario y la
  // persona lo revisa antes de guardar. Nada se guarda solo.
  final _dictado = ServicioDictado();
  bool _escuchando = false;
  String? _textoEscuchado;
  ResultadoDictado? _ultimoDictado;
  List<Categoria> _categorias = const [];

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
    _dictado.detener();
    _montoCtrl.dispose();
    _descripcionCtrl.dispose();
    _hechoPorCtrl.dispose();
    super.dispose();
  }

  /// Botón «Dictar gasto»: si ya está escuchando, detiene; si no,
  /// prepara el reconocedor y empieza a escuchar.
  Future<void> _alTocarDictado() async {
    if (_escuchando) {
      await _dictado.detener();
      if (mounted) setState(() => _escuchando = false);
      return;
    }
    final listo = await _dictado.preparar(
      alError: (_) {
        if (mounted) setState(() => _escuchando = false);
      },
      alEstado: (estado) {
        if (!mounted) return;
        if (estado == 'notListening' || estado == 'done') {
          setState(() => _escuchando = false);
        }
      },
    );
    if (!mounted) return;
    if (!listo) {
      final textos = context.textos;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Platform.isWindows
                ? '${textos.dictadoNoDisponible} ${textos.dictadoTipWindows}'
                : textos.dictadoNoDisponible,
          ),
        ),
      );
      return;
    }
    setState(() {
      _escuchando = true;
      _textoEscuchado = null;
      _ultimoDictado = null;
    });
    try {
      await _dictado.escuchar(
        alResultado: (r) =>
            _alResultadoDictado(r.recognizedWords, r.finalResult),
      );
    } catch (_) {
      if (mounted) setState(() => _escuchando = false);
    }
  }

  /// Cada resultado del reconocedor: los parciales solo muestran lo
  /// que se va escuchando; el final se interpreta y llena el formulario.
  void _alResultadoDictado(String texto, bool esFinal) {
    if (!mounted) return;
    if (!esFinal) {
      setState(() => _textoEscuchado = texto);
      return;
    }
    setState(() => _escuchando = false);
    if (texto.trim().isEmpty) return;
    _aplicarDictado(interpretarDictado(texto, _categorias));
  }

  /// Vuelca lo entendido en los campos. Lo no entendido NO se toca:
  /// queda como estaba para que la persona lo complete a mano.
  void _aplicarDictado(ResultadoDictado r) {
    setState(() {
      _textoEscuchado = r.textoOriginal;
      _ultimoDictado = r;
      if (r.montoPesos != null) _montoCtrl.text = r.montoPesos.toString();
      if (r.categoria != null) _categoriaId = r.categoria!.id;
      if (r.metodoPago != null) _metodoPago = r.metodoPago!;
      if (r.fechaMencionada) _fecha = r.fecha;
      if (r.descripcionSugerida != null &&
          _descripcionCtrl.text.trim().isEmpty) {
        _descripcionCtrl.text = r.descripcionSugerida!;
      }
      _error = null;
    });
  }

  /// La tarjeta «Escuché»: muestra las palabras reconocidas y qué se
  /// entendió (con ✔) y qué no (para revisarlo a mano).
  Widget _tarjetaEscuchado(BuildContext context) {
    final textos = context.textos;
    final r = _ultimoDictado;
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hearing, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${textos.escuche}:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('«$_textoEscuchado»'),
            if (r != null) ...[
              const SizedBox(height: 8),
              if (r.montoPesos != null)
                Text(
                  '✔ ${textos.monto}: '
                  '${formatoMoneda(r.montoPesos!, monedaPorDefecto)}',
                )
              else
                Text('• ${textos.sinMontoEscuchado}'),
              if (r.categoria != null)
                Text('✔ ${textos.categoria}: ${r.categoria!.nombre}')
              else
                Text('• ${textos.sinCategoriaEscuchada}'),
              if (r.fechaMencionada)
                Text('✔ ${textos.fecha}: ${fechaCorta(r.fecha)}'),
              if (r.metodoPago != null)
                Text(
                  '✔ ${textos.metodoDePago}: ${r.metodoPago == 'efectivo'
                      ? textos.efectivo
                      : r.metodoPago == 'tarjeta'
                      ? textos.tarjeta
                      : textos.transferencia}',
                ),
            ],
          ],
        ),
      ),
    );
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
          if (!soloLectura) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: _escuchando
                    ? Theme.of(context).colorScheme.error
                    : null,
              ),
              icon: Icon(_escuchando ? Icons.mic : Icons.mic_none, size: 26),
              label: Text(
                _escuchando
                    ? textos.escuchandoTocaParaParar
                    : textos.dictarGasto,
              ),
              onPressed: _alTocarDictado,
            ),
            const SizedBox(height: 8),
            Text(
              textos.dictadoAyuda,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_textoEscuchado != null) ...[
            _tarjetaEscuchado(context),
            const SizedBox(height: 16),
          ],
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
              _categorias = categorias;
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
