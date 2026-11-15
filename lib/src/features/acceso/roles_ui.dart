/// Cómo se muestran los roles en pantalla (nombre bonito e ícono).
library;

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../core/seguridad/autenticacion.dart';

String nombreRol(BuildContext context, String rol) {
  final textos = context.textos;
  return switch (rol) {
    Roles.administrador => textos.rolAdministrador,
    Roles.lectura => textos.rolLectura,
    _ => textos.rolMiembro,
  };
}

IconData iconoRol(String rol) {
  return switch (rol) {
    Roles.administrador => Icons.shield,
    Roles.lectura => Icons.visibility,
    _ => Icons.person,
  };
}
