import 'package:finanzas_hogar/src/features/nube/servicio_nube.dart';
import 'package:flutter_test/flutter_test.dart';

/// La decisión de sincronizar (v0.8.0), caso por caso.
void main() {
  final t0 = DateTime(2026, 11, 10, 10);
  final t1 = DateTime(2026, 11, 12, 10);
  final t2 = DateTime(2026, 11, 14, 10);

  group('decidirSync', () {
    test('sin documento en la nube: subir', () {
      expect(
        decidirSync(
          hayRemoto: false,
          remotoGeneradoEn: null,
          ultimoSync: null,
          localModificadoEn: null,
        ),
        AccionSync.subir,
      );
    });

    test('primera vez y este equipo no tiene datos: bajar', () {
      expect(
        decidirSync(
          hayRemoto: true,
          remotoGeneradoEn: t0,
          ultimoSync: null,
          localModificadoEn: null,
        ),
        AccionSync.bajar,
      );
    });

    test('primera vez y los dos lados tienen datos: conflicto', () {
      expect(
        decidirSync(
          hayRemoto: true,
          remotoGeneradoEn: t0,
          ultimoSync: null,
          localModificadoEn: t1,
        ),
        AccionSync.conflicto,
      );
    });

    test('al día: nada', () {
      expect(
        decidirSync(
          hayRemoto: true,
          remotoGeneradoEn: t0,
          ultimoSync: t0,
          localModificadoEn: null,
        ),
        AccionSync.nada,
      );
    });

    test('solo cambió este equipo: subir', () {
      expect(
        decidirSync(
          hayRemoto: true,
          remotoGeneradoEn: t0,
          ultimoSync: t0,
          localModificadoEn: t1,
        ),
        AccionSync.subir,
      );
    });

    test('solo cambió la nube: bajar', () {
      expect(
        decidirSync(
          hayRemoto: true,
          remotoGeneradoEn: t1,
          ultimoSync: t0,
          localModificadoEn: null,
        ),
        AccionSync.bajar,
      );
    });

    test('cambiaron los dos y lo local es más reciente: subir', () {
      expect(
        decidirSync(
          hayRemoto: true,
          remotoGeneradoEn: t1,
          ultimoSync: t0,
          localModificadoEn: t2,
        ),
        AccionSync.subir,
      );
    });

    test('cambiaron los dos y la nube es más reciente: bajar', () {
      expect(
        decidirSync(
          hayRemoto: true,
          remotoGeneradoEn: t2,
          ultimoSync: t0,
          localModificadoEn: t1,
        ),
        AccionSync.bajar,
      );
    });
  });
}
