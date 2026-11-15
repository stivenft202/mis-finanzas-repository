/// Botón grande con degradado de color, el estilo principal de la app
/// desde la v0.6.0 (pedido de Esteban: botones más estéticos).
///
/// Es grande a propósito (68 de alto, letra de 17) para que cualquier
/// persona del hogar lo toque sin esfuerzo. El texto va en un
/// [FittedBox] que lo encoge un poco si hace falta: el texto NUNCA se
/// corta con «…» (corrección v0.6.1: en los celulares angostos «Ver
/// gastos», «Categorías» y «Fijos del mes» salían recortados).
/// Si [onPressed] es null, se ve apagado y no responde (así se muestra
/// lo que un usuario de solo lectura no puede hacer).
library;

import 'package:flutter/material.dart';

class BotonDegradado extends StatelessWidget {
  const BotonDegradado({
    super.key,
    required this.icono,
    required this.texto,
    required this.colores,
    required this.onPressed,
    this.alto = 68,
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
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icono, color: Colors.white, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      texto,
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
