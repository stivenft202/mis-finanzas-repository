/// Configuración de monedas soportadas por la app.
///
/// TODAS las monedas viven en este único archivo: para agregar una moneda
/// nueva basta con añadir una línea a [monedasSoportadas], sin tocar el
/// resto de la app.
library;

import 'package:intl/intl.dart';

/// Datos de una moneda: código, nombre, símbolo y formato.
class Moneda {
  const Moneda({
    required this.codigo,
    required this.nombre,
    required this.simbolo,
    required this.decimales,
  });

  /// Código ISO, por ejemplo 'COP'.
  final String codigo;

  /// Nombre en español, por ejemplo 'Peso colombiano'.
  final String nombre;

  /// Símbolo visible, por ejemplo '$'.
  final String simbolo;

  /// Cantidad de decimales habituales (COP: 0, USD: 2).
  final int decimales;

  /// Factor para pasar de unidades menores a unidades completas.
  int get factor => decimales == 0 ? 1 : (decimales == 1 ? 10 : 100);
}

/// Monedas soportadas desde el inicio (Fase 0).
const List<Moneda> monedasSoportadas = [
  Moneda(codigo: 'COP', nombre: 'Peso colombiano', simbolo: r'$', decimales: 0),
  Moneda(codigo: 'ARS', nombre: 'Peso argentino', simbolo: r'$', decimales: 2),
  Moneda(codigo: 'MXN', nombre: 'Peso mexicano', simbolo: r'$', decimales: 2),
  Moneda(codigo: 'UYU', nombre: 'Peso uruguayo', simbolo: r'$', decimales: 2),
  Moneda(codigo: 'PEN', nombre: 'Sol peruano', simbolo: 'S/', decimales: 2),
  Moneda(codigo: 'USD', nombre: 'Dólar estadounidense', simbolo: r'$', decimales: 2),
];

/// Moneda por defecto del hogar si nadie elige otra.
const String monedaPorDefecto = 'COP';

/// Busca una moneda por su código. Si no existe, devuelve la de por defecto.
Moneda monedaPorCodigo(String codigo) {
  for (final m in monedasSoportadas) {
    if (m.codigo == codigo) return m;
  }
  return monedasSoportadas.first;
}

/// Da formato a un monto guardado en unidades menores.
///
/// Ejemplo: 45000 en COP se muestra como "$ 45.000 COP" si [conCodigo] es
/// verdadero (por defecto), para no confundir el signo "$" entre monedas.
String formatoMoneda(int montoMenor, String codigoMoneda, {bool conCodigo = true}) {
  final moneda = monedaPorCodigo(codigoMoneda);
  final valor = montoMenor / moneda.factor;
  final formato = NumberFormat.currency(
    locale: 'es_CO',
    symbol: moneda.simbolo,
    decimalDigits: moneda.decimales,
  );
  final texto = formato.format(valor);
  return conCodigo ? '$texto ${moneda.codigo}' : texto;
}

/// Convierte lo que la persona escribe (por ejemplo "45.000" o "12,50")
/// a unidades menores de la moneda indicada. Devuelve null si no es válido.
int? textoAMontoMenor(String texto, String codigoMoneda) {
  final moneda = monedaPorCodigo(codigoMoneda);
  var limpio = texto.trim().replaceAll(moneda.simbolo, '').trim();
  if (limpio.isEmpty) return null;
  // Acepta punto como separador de miles y coma como decimal (es-CO),
  // y también el formato contrario por si acaso.
  if (limpio.contains(',')) {
    limpio = limpio.replaceAll('.', '').replaceAll(',', '.');
  } else {
    final partes = limpio.split('.');
    if (partes.length > 1 && partes.last.length == 3) {
      limpio = limpio.replaceAll('.', '');
    }
  }
  final valor = double.tryParse(limpio);
  if (valor == null) return null;
  return (valor * moneda.factor).round();
}
