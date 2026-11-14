/// Íconos disponibles para las categorías.
///
/// Cada categoría guarda la *clave* del ícono (un texto corto), y aquí se
/// traduce esa clave al dibujo de Material. Lista cerrada a propósito:
/// así el selector de íconos de la app es sencillo y nunca se rompe.
library;

import 'package:flutter/material.dart';

const Map<String, IconData> iconosCategoria = {
  'mercado': Icons.shopping_cart,
  'servicios': Icons.receipt_long,
  'transporte': Icons.directions_car,
  'salud': Icons.medical_services,
  'educacion': Icons.school,
  'imprevistos': Icons.handyman,
  'ocio': Icons.celebration,
  'deudas': Icons.credit_card,
  'casa': Icons.home,
  'ropa': Icons.checkroom,
  'mascotas': Icons.pets,
  'regalos': Icons.card_giftcard,
  'otros': Icons.category,
};

/// Devuelve el ícono de una clave; si no la conoce, usa el genérico.
IconData iconoDeCategoria(String clave) =>
    iconosCategoria[clave] ?? Icons.category;

/// Colores que la persona puede elegir para una categoría.
const List<Color> coloresCategoria = [
  Color(0xFF2E7D32), // verde
  Color(0xFF1565C0), // azul
  Color(0xFFEF6C00), // naranja
  Color(0xFFC62828), // rojo
  Color(0xFF6A1B9A), // morado
  Color(0xFF00838F), // turquesa oscuro
  Color(0xFFAD1457), // rosa fuerte
  Color(0xFF4E342E), // café
  Color(0xFF455A64), // gris azulado
  Color(0xFFF9A825), // amarillo oscuro
];
