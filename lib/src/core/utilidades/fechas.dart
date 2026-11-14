/// Utilidades de fechas en lenguaje de la app.
library;

/// Primer instante del mes de [fecha].
DateTime inicioDelMes(DateTime fecha) => DateTime(fecha.year, fecha.month);

/// Primer instante del mes siguiente (fin exclusivo del mes de [fecha]).
DateTime finDelMes(DateTime fecha) => DateTime(fecha.year, fecha.month + 1);

/// Nombres de los meses en español, para textos sin depender del sistema.
const List<String> nombresMeses = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// "noviembre de 2026"
String nombreDelMes(DateTime fecha) =>
    '${nombresMeses[fecha.month - 1]} de ${fecha.year}';

/// "14/11/2026"
String fechaCorta(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
