/// Formulario para crear o editar una categoría: nombre, color, ícono,
/// tipo de factura opcional y si está oculta.
library;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/providers.dart';
import 'iconos_categoria.dart';
import '../../core/ui/titulo_appbar.dart';

class FormularioCategoria extends ConsumerStatefulWidget {
  const FormularioCategoria({super.key, this.categoria});

  final Categoria? categoria;

  @override
  ConsumerState<FormularioCategoria> createState() =>
      _FormularioCategoriaState();
}

class _FormularioCategoriaState extends ConsumerState<FormularioCategoria> {
  final _nombreCtrl = TextEditingController();
  final _tipoCtrl = TextEditingController();
  int _colorValor = coloresCategoria.first.toARGB32();
  String _icono = 'otros';
  bool _oculta = false;

  @override
  void initState() {
    super.initState();
    final c = widget.categoria;
    if (c != null) {
      _nombreCtrl.text = c.nombre;
      _tipoCtrl.text = c.tipoFactura ?? '';
      _colorValor = c.colorValor;
      _icono = c.icono;
      _oculta = c.oculta;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _tipoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final nombre = _nombreCtrl.text.trim();
    if (nombre.isEmpty) return;
    final base = ref.read(baseDeDatosProvider);
    final existente = widget.categoria;
    final tipo = _tipoCtrl.text.trim();
    if (existente == null) {
      await base.crearCategoria(
        CategoriasCompanion.insert(
          nombre: nombre,
          colorValor: _colorValor,
          icono: Value(_icono),
          tipoFactura: Value(tipo.isEmpty ? null : tipo),
          oculta: Value(_oculta),
        ),
      );
    } else {
      await base.actualizarCategoria(
        existente.copyWith(
          nombre: nombre,
          colorValor: _colorValor,
          icono: _icono,
          tipoFactura: Value(tipo.isEmpty ? null : tipo),
          oculta: _oculta,
        ),
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.textos;
    return Scaffold(
      appBar: AppBar(
        title: TituloAppBar(
          widget.categoria == null
              ? textos.nuevaCategoria
              : '${textos.editar} · ${textos.categorias}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nombreCtrl,
            decoration: InputDecoration(labelText: textos.nombreCategoria),
          ),
          const SizedBox(height: 20),
          Text(
            textos.categoria,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final color in coloresCategoria)
                GestureDetector(
                  onTap: () => setState(() => _colorValor = color.toARGB32()),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: color,
                    child: _colorValor == color.toARGB32()
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entrada in iconosCategoria.entries)
                IconButton.filledTonal(
                  isSelected: _icono == entrada.key,
                  icon: Icon(entrada.value, size: 28),
                  onPressed: () => setState(() => _icono = entrada.key),
                ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _tipoCtrl,
            decoration: InputDecoration(labelText: textos.tipoFacturaOpcional),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: Text(textos.ocultar),
            value: _oculta,
            onChanged: (v) => setState(() => _oculta = v),
          ),
          const SizedBox(height: 24),
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
