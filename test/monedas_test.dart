import 'package:finanzas_hogar/src/core/monedas/monedas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatoMoneda', () {
    test('COP se muestra sin decimales y con su código', () {
      final texto = formatoMoneda(45000, 'COP');
      expect(texto, contains('45.000'));
      expect(texto, contains('COP'));
      expect(texto, isNot(contains(',')));
    });

    test('USD se muestra con 2 decimales y su código', () {
      final texto = formatoMoneda(12345, 'USD');
      expect(texto, contains('123,45'));
      expect(texto, contains('USD'));
    });

    test('hay 6 monedas soportadas desde el inicio', () {
      expect(monedasSoportadas.map((m) => m.codigo),
          ['COP', 'ARS', 'MXN', 'UYU', 'PEN', 'USD']);
    });
  });

  group('textoAMontoMenor', () {
    test('interpreta miles con punto en COP', () {
      expect(textoAMontoMenor('45.000', 'COP'), 45000);
      expect(textoAMontoMenor('45000', 'COP'), 45000);
    });

    test('interpreta decimales con coma en USD', () {
      expect(textoAMontoMenor('12,50', 'USD'), 1250);
      expect(textoAMontoMenor('1.234,56', 'USD'), 123456);
    });

    test('rechaza textos que no son montos', () {
      expect(textoAMontoMenor('hola', 'COP'), isNull);
      expect(textoAMontoMenor('', 'COP'), isNull);
    });
  });
}
