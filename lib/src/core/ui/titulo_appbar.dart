import 'package:flutter/material.dart';

/// Título de una barra superior (AppBar) que NUNCA se corta con «…»:
/// si el texto no cabe en el ancho disponible, se encoge un poco
/// hasta caber completo en una sola línea.
///
/// Nació en la v0.6.3: en el celular de Esteban el título del inicio
/// salía «Finan…» y el de Ver gastos salía «Ver gastos · noviembr…»,
/// porque las acciones de la barra les robaban el espacio.
class TituloAppBar extends StatelessWidget {
  const TituloAppBar(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(texto, maxLines: 1, softWrap: false),
    );
  }
}
