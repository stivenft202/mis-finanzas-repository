import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/features/gastos/interprete_dictado.dart';
import 'package:flutter_test/flutter_test.dart';

/// Las 8 categorías iniciales de la app, como quedan sembradas.
List<Categoria> categoriasDePrueba() {
  const nombres = [
    'Mercado y comida',
    'Servicios públicos e internet/TV',
    'Transporte y combustible',
    'Salud y medicinas',
    'Educación e hijos',
    'Imprevistos y reparaciones',
    'Ocio y salidas',
    'Deudas y créditos',
  ];
  return [
    for (var i = 0; i < nombres.length; i++)
      Categoria(
        id: i + 1,
        nombre: nombres[i],
        colorValor: 0xFF455A64,
        icono: 'otros',
        oculta: false,
        tipoFactura: null,
        orden: i,
      ),
  ];
}

void main() {
  final hoy = DateTime(2026, 11, 15);
  final categorias = categoriasDePrueba();

  ResultadoDictado decir(String texto) =>
      interpretarDictado(texto, categorias, hoy: hoy);

  group('el monto', () {
    test('en palabras: «cuarenta y cinco mil»', () {
      final r = decir('gasté cuarenta y cinco mil en mercado');
      expect(r.montoPesos, 45000);
    });

    test('en dígitos con «mil»: «45 mil»', () {
      final r = decir('gasté 45 mil en mercado');
      expect(r.montoPesos, 45000);
    });

    test('en dígitos con punto de miles: «45.000»', () {
      final r = decir('gasté 45.000 en mercado');
      expect(r.montoPesos, 45000);
    });

    test('«un millón doscientos mil»', () {
      final r = decir('pagué un millón doscientos mil del colegio');
      expect(r.montoPesos, 1200000);
    });

    test('«novecientos noventa y nueve mil quinientos»', () {
      final r = decir('gasté novecientos noventa y nueve mil quinientos');
      expect(r.montoPesos, 999500);
    });

    test('«mil» a secas son 1.000', () {
      final r = decir('gasté mil en el bus');
      expect(r.montoPesos, 1000);
    });

    test('sin monto, no inventa', () {
      final r = decir('gasté en mercado');
      expect(r.montoPesos, isNull);
    });
  });

  group('la categoría', () {
    test('por palabra del nombre: mercado', () {
      final r = decir('gasté 45 mil en mercado');
      expect(r.categoria?.nombre, 'Mercado y comida');
    });

    test('por sinónimo: gasolina → transporte', () {
      final r = decir('gasté 50 mil en gasolina');
      expect(r.categoria?.nombre, 'Transporte y combustible');
    });

    test('por sinónimo: farmacia → salud', () {
      final r = decir('compré medicinas por veinte mil en la farmacia');
      expect(r.categoria?.nombre, 'Salud y medicinas');
      expect(r.montoPesos, 20000);
    });

    test('por palabra del nombre: internet → servicios', () {
      final r = decir('pagué 80 mil de internet');
      expect(r.categoria?.nombre, 'Servicios públicos e internet/TV');
    });

    test('sin categoría clara, no inventa', () {
      final r = decir('gasté 50 mil en el cumpleaños de mi mamá');
      expect(r.categoria, isNull);
    });
  });

  group('el método y la fecha', () {
    test('«en efectivo» y queda la categoría libre', () {
      final r = decir('gasté cuarenta y cinco mil en mercado en efectivo');
      expect(r.metodoPago, 'efectivo');
      expect(r.categoria?.nombre, 'Mercado y comida');
      expect(r.montoPesos, 45000);
    });

    test('«con tarjeta» es método, no categoría de deudas', () {
      final r = decir('pagué 120 mil de servicios ayer con tarjeta');
      expect(r.metodoPago, 'tarjeta');
      expect(r.categoria?.nombre, 'Servicios públicos e internet/TV');
      expect(r.montoPesos, 120000);
    });

    test('«ayer» mueve la fecha un día', () {
      final r = decir('pagué 120 mil de servicios ayer con tarjeta');
      expect(r.fechaMencionada, isTrue);
      expect(r.fecha, DateTime(2026, 11, 14));
    });

    test('«anteayer» mueve la fecha dos días', () {
      final r = decir('gasté 10 mil en bus anteayer');
      expect(r.fecha, DateTime(2026, 11, 13));
    });

    test('sin fecha mencionada, es hoy y no se marca', () {
      final r = decir('gasté 10 mil en bus');
      expect(r.fechaMencionada, isFalse);
      expect(r.fecha, hoy);
    });
  });

  group('la descripción sugerida', () {
    test('lo que sobra se propone como descripción, con sus tildes', () {
      final r = decir('gasté 50 mil en el cumpleaños de mi mamá');
      expect(r.descripcionSugerida, 'Cumpleaños de mi mamá');
    });

    test('si todo se entendió, no sobra descripción', () {
      final r = decir('gasté cuarenta y cinco mil en mercado en efectivo');
      expect(r.descripcionSugerida, isNull);
    });
  });
}
