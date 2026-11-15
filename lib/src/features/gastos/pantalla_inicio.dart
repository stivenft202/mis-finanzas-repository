/// Pantalla de inicio: el total del mes en grande, accesos rápidos y
/// los últimos gastos.
///
/// Desde la v0.6.0: botones grandes con degradados (pedido de Esteban),
/// iconos de modo claro y modo oscuro arriba, el botón de
/// actualizaciones con texto (ya no un icono escondido), saludo de la
/// persona que entró y respeto de roles (solo lectura no edita).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart';
import '../../core/base_de_datos/base_de_datos.dart';
import '../../core/monedas/monedas.dart';
import '../../core/providers.dart';
import '../../core/seguridad/autenticacion.dart';
import '../../core/ui/boton_degradado.dart';
import '../../core/utilidades/fechas.dart';
import '../acceso/pantalla_usuarios.dart';
import '../acceso/roles_ui.dart';
import '../categorias/iconos_categoria.dart';
import '../categorias/pantalla_categorias.dart';
import '../actualizaciones/pantalla_actualizacion.dart';
import '../actualizaciones/servicio_actualizacion.dart';
import '../fijos/pantalla_fijos.dart';
import '../respaldo/pantalla_respaldo.dart';
import 'formulario_gasto.dart';
import 'pantalla_gastos.dart';
import '../../core/ui/titulo_appbar.dart';

class PantallaInicio extends ConsumerWidget {
  const PantallaInicio({super.key});

  void _abrirActualizacion(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PantallaActualizacion()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textos = context.textos;
    final mes = ref.watch(mesSeleccionadoProvider);
    final total = ref.watch(totalDelMesProvider);
    final gastos = ref.watch(gastosDelMesProvider);
    final categorias = ref.watch(categoriasTodasProvider).value ?? const [];
    final actualizacion = ref.watch(actualizacionDisponibleProvider).value;
    final yo = ref.watch(usuarioActualProvider);
    final editable = ref.watch(puedeEditarProvider);
    final modoTema = ref.watch(modoTemaProvider);
    final brilloSistema = MediaQuery.platformBrightnessOf(context);
    final esOscuro =
        modoTema == ThemeMode.dark ||
        (modoTema == ThemeMode.system && brilloSistema == Brightness.dark);

    return Scaffold(
      appBar: AppBar(
        title: TituloAppBar(textos.tituloApp),
        actions: [
          IconButton(
            icon: const Icon(Icons.light_mode),
            tooltip: textos.modoClaro,
            style: IconButton.styleFrom(
              backgroundColor: !esOscuro
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
            onPressed: () =>
                ref.read(modoTemaProvider.notifier).cambiar(ThemeMode.light),
          ),
          IconButton(
            icon: const Icon(Icons.dark_mode),
            tooltip: textos.modoOscuro,
            style: IconButton.styleFrom(
              backgroundColor: esOscuro
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
            ),
            onPressed: () =>
                ref.read(modoTemaProvider.notifier).cambiar(ThemeMode.dark),
          ),
          if (actualizacion != null)
            FilledButton.icon(
              icon: const Icon(Icons.system_update, size: 20),
              label: Text(textos.actualizar),
              onPressed: () => _abrirActualizacion(context),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.system_update, size: 20),
              label: Text(textos.actualizar),
              onPressed: () => _abrirActualizacion(context),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (yo != null) ...[
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  child: Text(
                    yo.nombre.trim().isEmpty
                        ? '?'
                        : yo.nombre.trim()[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        textos.holaUsuario(yo.nombre),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(nombreRol(context, yo.rol)),
                    ],
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.logout, size: 20),
                  label: Text(textos.salir),
                  onPressed: () =>
                      ref.read(controlAccesoProvider.notifier).salir(),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (actualizacion != null) ...[
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(
                      Icons.system_update,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${textos.hayActualizacionCorta}: ${actualizacion.version}',
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    FilledButton(
                      onPressed: () => _abrirActualizacion(context),
                      child: Text(textos.actualizar),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
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
          if (yo != null && yo.rol == Roles.lectura) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.visibility),
                    const SizedBox(width: 12),
                    Expanded(child: Text(textos.notaSoloLectura)),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          BotonDegradado(
            icono: Icons.add_circle,
            texto: textos.agregarGasto,
            colores: const [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            alto: 74,
            onPressed: editable
                ? () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FormularioGasto()),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BotonDegradado(
                  icono: Icons.list_alt,
                  texto: textos.verGastos,
                  colores: const [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantallaGastos()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BotonDegradado(
                  icono: Icons.category,
                  texto: textos.categorias,
                  colores: const [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PantallaCategorias(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: BotonDegradado(
                  icono: Icons.table_chart,
                  texto: textos.fijosDelMes,
                  colores: const [Color(0xFF283593), Color(0xFF5C6BC0)],
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantallaFijos()),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BotonDegradado(
                  icono: Icons.backup,
                  texto: textos.respaldo,
                  colores: const [Color(0xFFE65100), Color(0xFFFF9800)],
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PantallaRespaldo()),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BotonDegradado(
            icono: Icons.people,
            texto: textos.usuarios,
            colores: const [Color(0xFF00695C), Color(0xFF26A69A)],
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PantallaUsuarios())),
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
                    TileGasto(
                      gasto: gasto,
                      categorias: categorias,
                      editable: editable,
                    ),
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
  const TileGasto({
    super.key,
    required this.gasto,
    required this.categorias,
    this.editable = true,
  });

  final Gasto gasto;
  final List<Categoria> categorias;

  /// Si es false (usuario de solo lectura), la fila no abre el editor.
  final bool editable;

  @override
  Widget build(BuildContext context) {
    final categoria = categoriaPorId(categorias, gasto.categoriaId);
    final color = Color(categoria?.colorValor ?? 0xFF455A64);
    final titulo = gasto.descripcion.trim().isNotEmpty
        ? gasto.descripcion
        : (categoria?.nombre ?? '');
    // Fila propia (ya no es un ListTile): el ListTile le daba al monto
    // su ancho completo y dejaba el texto en una columna angosta, así
    // que en el celular los nombres largos se partían feo («Imprevistos
    // y reparacione / s»). Aquí el texto manda: tiene su espacio
    // asegurado, pasa a dos líneas cortando por palabras, y el monto se
    // encoge un poco si hace falta, sin cortarse nunca.
    return InkWell(
      onTap: editable
          ? () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FormularioGasto(gasto: gasto)),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color,
              foregroundColor: Colors.white,
              child: Icon(iconoDeCategoria(categoria?.icono ?? 'otros')),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${fechaCorta(gasto.fecha)} · ${gasto.hechoPor}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 4,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  formatoMoneda(gasto.montoMenor, gasto.moneda),
                  maxLines: 1,
                  softWrap: false,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
