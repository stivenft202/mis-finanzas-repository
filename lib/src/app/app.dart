/// La aplicación: une tema, idioma y la puerta de acceso.
///
/// Desde la Fase 5 (v0.6.0) la app abre con control de acceso:
/// - Si no hay personas creadas, pide crear el primer administrador.
/// - Si hay personas pero nadie entró, muestra la pantalla de acceso.
/// - Si la app estuvo sin usarse más de los minutos configurados, se
///   bloquea y pide el PIN de quien tenía la sesión.
/// - Con la sesión abierta, muestra la pantalla de inicio.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../core/providers.dart';
import '../features/acceso/pantalla_acceso.dart';
import '../features/acceso/pantalla_primer_uso.dart';
import '../features/gastos/pantalla_inicio.dart';
import 'tema.dart';

class AppFinanzas extends ConsumerWidget {
  const AppFinanzas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modoTema = ref.watch(modoTemaProvider);
    return MaterialApp(
      title: 'Finanzas del Hogar',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('es'),
      theme: temaClaro(),
      darkTheme: temaOscuro(),
      themeMode: modoTema,
      home: const PuertaAcceso(),
    );
  }
}

/// Decide qué se ve según las personas del hogar y la sesión.
class PuertaAcceso extends ConsumerWidget {
  const PuertaAcceso({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuarios = ref.watch(usuariosProvider);
    final acceso = ref.watch(controlAccesoProvider);
    return usuarios.when(
      loading: () => const _PantallaCargando(),
      error: (_, _) => const _PantallaCargando(),
      data: (lista) {
        if (lista.isEmpty) return const PantallaPrimerUso();
        final id = acceso.usuarioId;
        final sesionViva =
            id != null && lista.any((u) => u.id == id) && !acceso.bloqueada;
        if (!sesionViva) return const PantallaAcceso();
        return const VigilanteBloqueo(child: PantallaInicio());
      },
    );
  }
}

class _PantallaCargando extends StatelessWidget {
  const _PantallaCargando();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Vigila la inactividad: si la app pasa a segundo plano más de los
/// minutos configurados, al volver pide el PIN (bloqueo automático).
class VigilanteBloqueo extends ConsumerStatefulWidget {
  const VigilanteBloqueo({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<VigilanteBloqueo> createState() => _VigilanteBloqueoEstado();
}

class _VigilanteBloqueoEstado extends ConsumerState<VigilanteBloqueo>
    with WidgetsBindingObserver {
  DateTime? _cuandoSeOculto;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.paused ||
        estado == AppLifecycleState.hidden) {
      _cuandoSeOculto = DateTime.now();
    } else if (estado == AppLifecycleState.resumed) {
      final desde = _cuandoSeOculto;
      _cuandoSeOculto = null;
      if (desde != null) _revisarBloqueo(desde);
    }
  }

  Future<void> _revisarBloqueo(DateTime desde) async {
    final minutos = await ref
        .read(autoBloqueoMinutosProvider.future)
        .catchError((_) => 5);
    if (!mounted || minutos <= 0) return;
    if (DateTime.now().difference(desde).inMinutes >= minutos) {
      ref.read(controlAccesoProvider.notifier).bloquear();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Acceso corto a los textos traducidos desde cualquier pantalla.
extension TextosEnContexto on BuildContext {
  AppLocalizations get textos => AppLocalizations.of(this);
}
