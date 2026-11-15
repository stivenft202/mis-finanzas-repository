import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/seguridad/autenticacion.dart';
import 'package:finanzas_hogar/src/features/nube/cliente_nube.dart';
import 'package:finanzas_hogar/src/features/nube/servicio_nube.dart';
import 'package:flutter_test/flutter_test.dart';

import 'autenticacion_test.dart' show AlmacenMemoria;

/// Una nube falsa en memoria: cuentas y un documento por cuenta,
/// compartida por todos los «equipos» de la prueba.
class ClienteNubeFalso implements ClienteNube {
  final Map<String, ({String clave, String uid})> cuentas = {};
  final Map<String, DocNube> documentos = {};
  var _contador = 0;

  SesionNube _sesion(String correo, String uid) => SesionNube(
        uid: uid,
        correo: correo,
        idToken: 'token-$uid',
        refreshToken: 'refresh-$uid',
        expiraEn: DateTime.now().add(const Duration(hours: 1)),
      );

  @override
  Future<SesionNube> crearCuenta(String correo, String clave) async {
    if (cuentas.containsKey(correo)) {
      throw ErrorNube('Ese correo ya tiene una cuenta del hogar.');
    }
    final uid = 'uid-${++_contador}';
    cuentas[correo] = (clave: clave, uid: uid);
    return _sesion(correo, uid);
  }

  @override
  Future<SesionNube> entrar(String correo, String clave) async {
    final cuenta = cuentas[correo];
    if (cuenta == null || cuenta.clave != clave) {
      throw ErrorNube('Correo o contraseña incorrectos.');
    }
    return _sesion(correo, cuenta.uid);
  }

  @override
  Future<SesionNube> refrescar(SesionNube sesion) async => sesion;

  @override
  Future<DocNube?> leerDocumento(SesionNube sesion) async =>
      documentos[sesion.uid];

  @override
  Future<void> escribirDocumento(
    SesionNube sesion, {
    required String contenido,
    required DateTime generadoEn,
    required String origen,
  }) async {
    documentos[sesion.uid] = DocNube(
      contenido: contenido,
      generadoEn: generadoEn,
      origen: origen,
    );
  }
}

/// Un «equipo»: su base, su almacén y sus servicios.
class Equipo {
  Equipo(this.cliente) {
    base = BaseDeDatos(NativeDatabase.memory());
    almacen = AlmacenMemoria();
    auth = ServicioAutenticacion(base, almacen);
    nube = ServicioNube(base, almacen, auth, cliente);
  }

  final ClienteNubeFalso cliente;
  late final BaseDeDatos base;
  late final AlmacenMemoria almacen;
  late final ServicioAutenticacion auth;
  late final ServicioNube nube;

  Future<void> cerrar() => base.close();
}

void main() {
  test('dos equipos se ponen al día sin archivos de por medio', () async {
    final cliente = ClienteNubeFalso();
    final a = Equipo(cliente);
    final b = Equipo(cliente);

    // A crea la cuenta: no hay nube todavía, sube su foto (vacía).
    expect(
      await a.nube.crearCuenta('hogar@correo.com', 'clave-del-hogar'),
      ResultadoSync.subido,
    );

    // A registra una persona y un gasto, y sincroniza: sube.
    final persona = await a.auth.crearPersona(
      nombre: 'Esteban',
      rol: Roles.administrador,
      clave: 'secreto1',
      pin: '1234',
    );
    final categoriaId = await a.base.into(a.base.categorias).insert(
          CategoriasCompanion.insert(
            nombre: 'Mercado y comida',
            colorValor: 0xFF2E7D32,
          ),
        );
    final ahora = DateTime(2026, 11, 14);
    await a.base.crearGasto(
      GastosCompanion.insert(
        montoMenor: 45000,
        montoBaseMenor: 45000,
        fecha: ahora,
        categoriaId: categoriaId,
        creadoEn: ahora,
        actualizadoEn: ahora,
      ),
    );
    expect(await a.nube.sincronizar(), ResultadoSync.subido);

    // B entra con la misma cuenta: baja todo y queda igual que A.
    expect(
      await b.nube.entrar('hogar@correo.com', 'clave-del-hogar'),
      ResultadoSync.bajado,
    );
    final usuariosB = await b.base.listaUsuarios();
    expect(usuariosB.length, 1);
    expect(usuariosB.single.nombre, 'Esteban');
    expect(
      await b.auth.entrarConPin(persona.id, '1234'),
      ResultadoAcceso.correcto,
    );
    final gastosB = await b.base.select(b.base.gastos).get();
    expect(gastosB.length, 1);
    expect(gastosB.single.montoMenor, 45000);

    // Sin cambios en ningún lado: nada.
    expect(await b.nube.sincronizar(), ResultadoSync.nada);
    expect(await a.nube.sincronizar(), ResultadoSync.nada);

    await a.cerrar();
    await b.cerrar();
  });

  test('la primera vez con datos en los dos lados: conflicto y decisión',
      () async {
    final cliente = ClienteNubeFalso();
    final a = Equipo(cliente);
    final c = Equipo(cliente);

    await a.nube.crearCuenta('hogar@correo.com', 'clave-del-hogar');
    await a.auth.crearPersona(
      nombre: 'DeLaNube',
      rol: Roles.administrador,
      clave: 'secreto1',
      pin: '1234',
    );
    expect(await a.nube.sincronizar(), ResultadoSync.subido);

    // C ya tenía SU persona antes de conocer la cuenta: conflicto.
    await c.auth.crearPersona(
      nombre: 'DeEsteEquipo',
      rol: Roles.administrador,
      clave: 'secreto1',
      pin: '1234',
    );
    expect(
      await c.nube.entrar('hogar@correo.com', 'clave-del-hogar'),
      ResultadoSync.conflicto,
    );
    // Nada se pisó todavía.
    expect((await c.base.listaUsuarios()).single.nombre, 'DeEsteEquipo');

    // C decide que manda la nube: baja y queda con la persona de A.
    expect(
      await c.nube.sincronizar(resolucion: ResolucionConflicto.usarNube),
      ResultadoSync.bajado,
    );
    expect((await c.base.listaUsuarios()).single.nombre, 'DeLaNube');

    await a.cerrar();
    await c.cerrar();
  });
}
