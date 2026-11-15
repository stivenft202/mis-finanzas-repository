/// Botón grande con degradado de color, el estilo principal de la app
/// desde la v0.6.0 (pedido de Esteban: botones más estéticos).
///
/// Es grande a propósito (mínimo 56 de alto, letra de 18) para que
/// cualquier persona del hogar lo toque sin esfuerzo. Si [onPressed]
/// es null, se ve apagado y no responde (así se muestra lo que un
/// usuario de solo lectura no puede hacer).
library;

import 'package:flutter/material.dart';

class BotonDegradado extends StatelessWidget {
  const BotonDegradado({
    super.key,
    required this.icono,
    required this.texto,
    required this.colores,
    required this.onPressed,
    this.alto = 60,
  });

  final IconData icono;
  final String texto;

  /// Los dos (o más) colores del degradado, de izquierda a derecha.
  final List<Color> colores;

  final VoidCallback? onPressed;
  final double alto;

  @override
  Widget build(BuildContext context) {
    final activo = onPressed != null;
    final coloresEfectivos = activo
        ? colores
        : const [Color(0xFF9E9E9E), Color(0xFF757575)];
    return Container(
      height: alto,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: coloresEfectivos,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: activo
            ? [
                BoxShadow(
                  color: coloresEfectivos.last.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, color: Colors.white, size: 26),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
