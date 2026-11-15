/// Intérprete de dictados de gasto (v0.7.0).
///
/// Recibe el texto que reconoció la voz del equipo y saca, SOLO si está
/// claro, el monto, la categoría, la fecha y el método de pago. Lo que
/// no entiende NO lo inventa: queda en null y el formulario lo deja
/// para que la persona lo complete a mano. Nada se guarda sin pasar
/// por la revisión del formulario.
library;

import '../../core/base_de_datos/base_de_datos.dart';

/// Lo entendido de un dictado.
class ResultadoDictado {
  const ResultadoDictado({
    required this.textoOriginal,
    required this.fecha,
    required this.fechaMencionada,
    this.montoPesos,
    this.categoria,
    this.metodoPago,
    this.descripcionSugerida,
  });

  /// El texto tal como lo reconoció el equipo (para mostrarlo).
  final String textoOriginal;

  /// Monto en pesos (COP), si se entendió.
  final int? montoPesos;

  /// Categoría identificada, si se entendió.
  final Categoria? categoria;

  /// Fecha del gasto (hoy si no se mencionó otra).
  final DateTime fecha;

  /// True si el dictado mencionó la fecha («ayer», «anteayer»).
  final bool fechaMencionada;

  /// 'efectivo', 'tarjeta' o 'transferencia', si se mencionó.
  final String? metodoPago;

  /// Descripción propuesta con lo que sobró del dictado, si aplica.
  final String? descripcionSugerida;
}

/// Una palabra del dictado, en su forma original y en su forma
/// «limpia» (minúsculas, sin tildes ni signos) para comparar.
class _Palabra {
  _Palabra(this.original, this.limpia);

  final String original;
  final String limpia;
  bool usada = false;
}

String _limpiar(String texto) {
  var r = texto.toLowerCase();
  const mapa = {
    'á': 'a',
    'é': 'e',
    'í': 'i',
    'ó': 'o',
    'ú': 'u',
    'ü': 'u',
    'ñ': 'n',
  };
  mapa.forEach((k, v) => r = r.replaceAll(k, v));
  // Quita signos de los bordes (¡!¿?.,;:«»"$), conservando los puntos y
  // comas INTERNOS de los números (45.000).
  r = r.replaceAll(RegExp(r'^[^\w]+|[^\w]+$'), '');
  return r;
}

const _valoresPalabra = <String, int>{
  'cero': 0,
  'un': 1,
  'uno': 1,
  'una': 1,
  'dos': 2,
  'tres': 3,
  'cuatro': 4,
  'cinco': 5,
  'seis': 6,
  'siete': 7,
  'ocho': 8,
  'nueve': 9,
  'diez': 10,
  'once': 11,
  'doce': 12,
  'trece': 13,
  'catorce': 14,
  'quince': 15,
  'dieciseis': 16,
  'diecisiete': 17,
  'dieciocho': 18,
  'diecinueve': 19,
  'veinte': 20,
  'veintiuno': 21,
  'veintiun': 21,
  'veintidos': 22,
  'veintitres': 23,
  'veinticuatro': 24,
  'veinticinco': 25,
  'veintiseis': 26,
  'veintisiete': 27,
  'veintiocho': 28,
  'veintinueve': 29,
  'treinta': 30,
  'cuarenta': 40,
  'cincuenta': 50,
  'sesenta': 60,
  'setenta': 70,
  'ochenta': 80,
  'noventa': 90,
  'cien': 100,
  'ciento': 100,
  'doscientos': 200,
  'trescientos': 300,
  'cuatrocientos': 400,
  'quinientos': 500,
  'seiscientos': 600,
  'setecientos': 700,
  'ochocientos': 800,
  'novecientos': 900,
};

bool _esDeNumero(String p) =>
    _valoresPalabra.containsKey(p) ||
    p == 'y' ||
    p == 'mil' ||
    p == 'millon' ||
    p == 'millones';

int? _evaluarPalabrasNumero(List<String> run) {
  var total = 0;
  var grupo = 0;
  var algo = false;
  for (final w in run) {
    if (w == 'y') continue;
    if (w == 'mil') {
      grupo = (grupo == 0 ? 1 : grupo) * 1000;
      total += grupo;
      grupo = 0;
      algo = true;
      continue;
    }
    if (w == 'millon' || w == 'millones') {
      grupo = (grupo == 0 ? 1 : grupo) * 1000000;
      total += grupo;
      grupo = 0;
      algo = true;
      continue;
    }
    final v = _valoresPalabra[w];
    if (v == null) return null;
    grupo += v;
    algo = true;
  }
  if (!algo) return null;
  return total + grupo;
}

/// Palabras que la gente dice y la categoría a la que apuntan (se busca
/// la categoría cuyo nombre contenga el fragmento dado).
const _sinonimosCategoria = <String, String>{
  'supermercado': 'mercado',
  'super': 'mercado',
  'alimentos': 'mercado',
  'fruver': 'mercado',
  'luz': 'servicios',
  'agua': 'servicios',
  'energia': 'servicios',
  'celular': 'servicios',
  'gasolina': 'transporte',
  'combustible': 'transporte',
  'bus': 'transporte',
  'taxi': 'transporte',
  'uber': 'transporte',
  'peaje': 'transporte',
  'parqueadero': 'transporte',
  'medicina': 'salud',
  'medicinas': 'salud',
  'farmacia': 'salud',
  'medico': 'salud',
  'doctor': 'salud',
  'drogueria': 'salud',
  'colegio': 'educacion',
  'escuela': 'educacion',
  'universidad': 'educacion',
  'utiles': 'educacion',
  'matricula': 'educacion',
  'reparacion': 'imprevistos',
  'arreglo': 'imprevistos',
  'arreglos': 'imprevistos',
  'repuesto': 'imprevistos',
  'repuestos': 'imprevistos',
  'cine': 'ocio',
  'salida': 'ocio',
  'paseo': 'ocio',
  'diversion': 'ocio',
  'deuda': 'deudas',
  'credito': 'deudas',
  'creditos': 'deudas',
  'cuota': 'deudas',
  'prestamo': 'deudas',
};

/// Palabras de relleno que se quitan del comienzo de lo que sobra al
/// armar la descripción sugerida.
const _rellenoInicial = {
  'gaste',
  'pague',
  'compre',
  'gasto',
  'pago',
  'compra',
  'en',
  'de',
  'por',
  'para',
  'con',
  'el',
  'la',
  'los',
  'las',
  'un',
  'una',
  'unos',
  'unas',
  'del',
  'al',
  'mi',
  'me',
};

/// Interpreta [texto] (lo reconocido por la voz) contra [categorias].
ResultadoDictado interpretarDictado(
  String texto,
  List<Categoria> categorias, {
  DateTime? hoy,
}) {
  final base = hoy ?? DateTime.now();
  final diaBase = DateTime(base.year, base.month, base.day);
  final palabras = <_Palabra>[
    for (final trozo in texto.trim().split(RegExp(r'\s+')))
      if (trozo.isNotEmpty) _Palabra(trozo, _limpiar(trozo)),
  ];

  // ---- Método de pago (se marca primero: «con tarjeta» es método,
  // no la categoría de deudas). ----
  String? metodo;
  for (var i = 0; i < palabras.length; i++) {
    final p = palabras[i].limpia;
    if (p == 'efectivo') {
      metodo = 'efectivo';
      palabras[i].usada = true;
    } else if (p == 'tarjeta') {
      metodo = 'tarjeta';
      palabras[i].usada = true;
    } else if (p == 'transferencia') {
      metodo = 'transferencia';
      palabras[i].usada = true;
    }
    if (metodo != null) break;
  }

  // ---- Fecha ----
  var fecha = diaBase;
  var fechaMencionada = false;
  for (var i = 0; i < palabras.length; i++) {
    final p = palabras[i].limpia;
    if (p == 'anteayer') {
      fecha = diaBase.subtract(const Duration(days: 2));
      fechaMencionada = true;
      palabras[i].usada = true;
      break;
    }
    if (p == 'antes' &&
        i + 2 < palabras.length &&
        palabras[i + 1].limpia == 'de' &&
        palabras[i + 2].limpia == 'ayer') {
      fecha = diaBase.subtract(const Duration(days: 2));
      fechaMencionada = true;
      palabras[i].usada = true;
      palabras[i + 1].usada = true;
      palabras[i + 2].usada = true;
      break;
    }
    if (p == 'ayer') {
      fecha = diaBase.subtract(const Duration(days: 1));
      fechaMencionada = true;
      palabras[i].usada = true;
      break;
    }
  }

  // ---- Monto: el primer número convincente del dictado. ----
  int? monto;
  for (var i = 0; i < palabras.length && monto == null; i++) {
    if (palabras[i].usada) continue;
    final p = palabras[i].limpia;
    // ¿Dígitos? (45, 45.000, 120000, 45.5 con «mil» después…)
    if (RegExp(r'^\d[\d.,]*$').hasMatch(p)) {
      final siguiente = i + 1 < palabras.length ? palabras[i + 1].limpia : null;
      final multiplicador = siguiente == 'mil'
          ? 1000
          : (siguiente == 'millon' || siguiente == 'millones')
          ? 1000000
          : 1;
      int? valor;
      if (RegExp(r'^\d{1,3}([.,]\d{3})+$').hasMatch(p)) {
        // Separador de miles: 45.000 → 45000.
        valor = int.parse(p.replaceAll(RegExp(r'[.,]'), ''));
      } else if (RegExp(r'^\d+[.,]\d{1,2}$').hasMatch(p) && multiplicador > 1) {
        // Decimal con multiplicador: 45,5 mil → 45500.
        final n = double.parse(p.replaceAll(',', '.'));
        valor = (n * multiplicador).round();
      } else if (RegExp(r'^\d+$').hasMatch(p)) {
        valor = int.parse(p) * multiplicador;
      }
      if (valor != null && valor > 0) {
        monto = valor;
        palabras[i].usada = true;
        if (multiplicador > 1) palabras[i + 1].usada = true;
      }
      continue;
    }
    // ¿Palabras de número? (cuarenta y cinco mil, un millón…)
    if (_esDeNumero(p)) {
      final run = <String>[];
      var j = i;
      while (j < palabras.length &&
          !palabras[j].usada &&
          _esDeNumero(palabras[j].limpia)) {
        run.add(palabras[j].limpia);
        j++;
      }
      final valor = _evaluarPalabrasNumero(run);
      if (valor != null && valor > 0) {
        monto = valor;
        for (var k = i; k < j; k++) {
          palabras[k].usada = true;
        }
      }
    }
  }
  // Un «pesos» pegado al monto también se marca como usado.
  if (monto != null) {
    for (var i = 0; i < palabras.length; i++) {
      if (!palabras[i].usada &&
          (palabras[i].limpia == 'pesos' || palabras[i].limpia == 'peso')) {
        palabras[i].usada = true;
        break;
      }
    }
  }

  // ---- Categoría: palabra del nombre o sinónimo conocido. ----
  Categoria? categoria;
  var mejorPuntaje = 0;
  for (var i = 0; i < palabras.length; i++) {
    if (palabras[i].usada) continue;
    final p = palabras[i].limpia;
    if (p.length < 3) continue;
    Categoria? candidata;
    // (a) Palabra del propio nombre de la categoría.
    for (final c in categorias) {
      final nombreLimpio = _limpiar(c.nombre);
      // Se corta también por «/» («internet/TV» guarda «internet»).
      final partes = nombreLimpio
          .split(RegExp(r'[\s/]+'))
          .where((w) => w.length >= 4)
          .toList();
      if (partes.contains(p)) {
        candidata = c;
        break;
      }
    }
    // (b) Sinónimo: apunta a la categoría cuyo nombre lo contiene.
    if (candidata == null && _sinonimosCategoria.containsKey(p)) {
      final fragmento = _sinonimosCategoria[p]!;
      for (final c in categorias) {
        if (_limpiar(c.nombre).contains(fragmento)) {
          candidata = c;
          break;
        }
      }
    }
    if (candidata != null && p.length > mejorPuntaje) {
      categoria = candidata;
      mejorPuntaje = p.length;
      // Se consume la palabra ganadora al final (aquí solo se anota).
      palabras[i].usada = true;
    }
  }

  // ---- Descripción sugerida: lo que sobró, sin el relleno inicial. --
  final sobrantes = <_Palabra>[
    for (final p in palabras)
      if (!p.usada) p,
  ];
  while (sobrantes.isNotEmpty &&
      _rellenoInicial.contains(sobrantes.first.limpia)) {
    sobrantes.removeAt(0);
  }
  String? descripcion;
  if (sobrantes.isNotEmpty) {
    final junto = sobrantes.map((p) => p.original).join(' ').trim();
    final limpio = sobrantes.map((p) => p.limpia).join(' ');
    // Si lo que sobró es solo el nombre de la categoría, no aporta.
    if (junto.length >= 3 &&
        (categoria == null || limpio != _limpiar(categoria.nombre))) {
      descripcion = junto[0].toUpperCase() + junto.substring(1);
    }
  }

  return ResultadoDictado(
    textoOriginal: texto,
    fecha: fecha,
    fechaMencionada: fechaMencionada,
    montoPesos: monto,
    categoria: categoria,
    metodoPago: metodo,
    descripcionSugerida: descripcion,
  );
}
