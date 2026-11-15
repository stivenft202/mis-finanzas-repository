import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/seguridad/autenticacion.dart';
import 'package:flutter_test/flutter_test.dart';

import 'autenticacion_test.dart' show AlmacenMemoria;

/// La foto completa de la nube (v0.8.0): datos + personas + huellas
/// salen de un equipo y otro equipo queda idéntico al recibirla.
void main() {
  test('la foto v2 viaja completa: datos, personas y acceso', () async {
    // Equipo A: una persona, un gasto y un fijo.
    final baseA = BaseDeDatos(NativeDatabase.memory());
    final almacenA = AlmacenMemoria();
    final authA = ServicioAutenticacion(baseA, almacenA);
    final persona = await authA.crearPersona(
      nombre: 'Esteban',
      rol: Roles.administrador,
      clave: 'secreto1',
      pin: '1234',
    );
    final categoriaId = await baseA.into(baseA.categorias).insert(
          CategoriasCompanion.insert(
            nombre: 'Mercado y comida',
            colorValor: 0xFF2E7D32,
          ),
        );
    final ahora = DateTime(2026, 11, 14);
    await baseA.crearGasto(
      GastosCompanion.insert(
        montoMenor: 45000,
        montoBaseMenor: 45000,
        fecha: ahora,
        categoriaId: categoriaId,
        hechoPor: const Value('Esteban'),
        creadoEn: ahora,
        actualizadoEn: ahora,
      ),
    );
    await baseA.crearFijo(
      FijosCompanion.insert(
        tipo: 'gasto',
        nombre: 'Arriendo',
        montoMenor: 900000,
        diaDelMes: 5,
        creadoEn: ahora,
        actualizadoEn: ahora,
      ),
    );

    // La foto, tal como la arma el servicio de nube.
    final foto = await baseA.exportarSync();
    final credenciales = await authA.credencialesParaSync([persona.id]);
    expect(credenciales.keys, contains('cred_${persona.id}_clave'));
    expect(credenciales.keys, contains('cred_${persona.id}_pin'));

    // Equipo B: vacío, recibe la foto.
    final baseB = BaseDeDatos(NativeDatabase.memory());
    final almacenB = AlmacenMemoria();
    final authB = ServicioAutenticacion(baseB, almacenB);
    await baseB.importarSync(foto);
    final usuariosB = await baseB.listaUsuarios();
    await authB.aplicarCredencialesSync(
      credenciales,
      [for (final u in usuariosB) u.id],
    );

    // Las personas quedaron con el mismo número y nombre.
    expect(usuariosB.length, 1);
    expect(usuariosB.single.id, persona.id);
    expect(usuariosB.single.nombre, 'Esteban');
    expect(usuariosB.single.rol, Roles.administrador);

    // El acceso funciona en B con la misma clave y el mismo PIN:
    // la huella viajó, no hizo falta crear la persona otra vez.
    expect(
      await authB.entrarConClave(persona.id, 'secreto1'),
      ResultadoAcceso.correcto,
    );
    expect(
      await authB.entrarConPin(persona.id, '1234'),
      ResultadoAcceso.correcto,
    );

    // Los datos quedaron: el gasto con su monto y el fijo del arriendo.
    final gastosB = await baseB.select(baseB.gastos).get();
    expect(gastosB.length, 1);
    expect(gastosB.single.montoMenor, 45000);
    expect(gastosB.single.hechoPor, 'Esteban');
    final fijosB = await baseB.select(baseB.fijos).get();
    expect(fijosB.length, 1);
    expect(fijosB.single.nombre, 'Arriendo');

    await baseA.close();
    await baseB.close();
  });

  test('importarSync rechaza lo que no es una foto v2', () async {
    final base = BaseDeDatos(NativeDatabase.memory());
    expect(
      () => base.importarSync({'aplicacion': 'finanzas-hogar', 'formato': 1}),
      throwsFormatException,
    );
    expect(
      () => base.importarSync({'aplicacion': 'otra', 'formato': 2}),
      throwsFormatException,
    );
    await base.close();
  });
}
