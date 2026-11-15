import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:finanzas_hogar/src/core/base_de_datos/base_de_datos.dart';
import 'package:finanzas_hogar/src/core/seguridad/autenticacion.dart';
import 'package:flutter_test/flutter_test.dart';

/// Almacén de secretos en memoria, para probar sin el equipo real.
class AlmacenMemoria implements AlmacenClaves {
  final Map<String, String> datos = {};

  @override
  Future<String?> leer(String clave) async => datos[clave];

  @override
  Future<void> guardar(String clave, String valor) async {
    datos[clave] = valor;
  }

  @override
  Future<void> eliminar(String clave) async {
    datos.remove(clave);
  }
}

void main() {
  late BaseDeDatos base;
  late ServicioAutenticacion servicio;

  setUp(() {
    base = BaseDeDatos(NativeDatabase.memory());
    servicio = ServicioAutenticacion(base, AlmacenMemoria());
  });

  tearDown(() async {
    await base.close();
  });

  group('huellas (hash)', () {
    test('el mismo secreto con la misma sal da la misma huella', () {
      expect(huellaDe('clave123', 'sal1'), huellaDe('clave123', 'sal1'));
    });

    test('con otra sal o otro secreto, la huella cambia', () {
      final base1 = huellaDe('clave123', 'sal1');
      expect(huellaDe('clave123', 'sal2'), isNot(base1));
      expect(huellaDe('clave124', 'sal1'), isNot(base1));
    });
  });

  group('roles', () {
    test('solo lectura no edita; miembro y administrador sí', () {
      expect(puedeEditar(Roles.lectura), isFalse);
      expect(puedeEditar(Roles.miembro), isTrue);
      expect(puedeEditar(Roles.administrador), isTrue);
    });

    test('solo el administrador administra', () {
      expect(puedeAdministrar(Roles.administrador), isTrue);
      expect(puedeAdministrar(Roles.miembro), isFalse);
      expect(puedeAdministrar(Roles.lectura), isFalse);
    });
  });

  group('formatos', () {
    test('la contraseña pide mínimo 6 letras', () {
      expect(errorDeClave('12345'), isNotNull);
      expect(errorDeClave('123456'), isNull);
    });

    test('el PIN pide de 4 a 6 números', () {
      expect(errorDePin('123'), isNotNull);
      expect(errorDePin('1234567'), isNotNull);
      expect(errorDePin('12a4'), isNotNull);
      expect(errorDePin('1234'), isNull);
      expect(errorDePin('123456'), isNull);
    });
  });

  group('personas y acceso', () {
    test('crear una persona y entrar con su contraseña y su PIN', () async {
      final usuario = await servicio.crearPersona(
        nombre: 'Esteban',
        rol: Roles.administrador,
        clave: 'secreto1',
        pin: '1234',
      );
      expect(usuario.nombre, 'Esteban');
      expect(usuario.rol, Roles.administrador);
      expect(await servicio.tieneCredenciales(usuario.id), isTrue);
      expect(
        await servicio.entrarConClave(usuario.id, 'secreto1'),
        ResultadoAcceso.correcto,
      );
      expect(
        await servicio.entrarConClave(usuario.id, 'otra-clave'),
        ResultadoAcceso.incorrecto,
      );
      expect(
        await servicio.entrarConPin(usuario.id, '1234'),
        ResultadoAcceso.correcto,
      );
      expect(
        await servicio.entrarConPin(usuario.id, '9999'),
        ResultadoAcceso.incorrecto,
      );
      final lista = await base.listaUsuarios();
      expect(lista.length, 1);
      expect(await base.contarAdministradores(), 1);
    });

    test('no se pueden repetir nombres, ni con otras mayúsculas', () async {
      await servicio.crearPersona(
        nombre: 'María',
        rol: Roles.miembro,
        clave: 'secreto1',
        pin: '1234',
      );
      expect(
        () => servicio.crearPersona(
          nombre: 'maría',
          rol: Roles.miembro,
          clave: 'secreto1',
          pin: '1234',
        ),
        throwsArgumentError,
      );
    });

    test('tras 5 intentos fallidos el acceso se bloquea un rato', () async {
      final usuario = await servicio.crearPersona(
        nombre: 'Pedro',
        rol: Roles.miembro,
        clave: 'secreto1',
        pin: '1234',
      );
      for (var i = 0; i < 5; i++) {
        expect(
          await servicio.entrarConPin(usuario.id, '0000'),
          ResultadoAcceso.incorrecto,
        );
      }
      // Ya bloqueado: ni con el PIN bueno entra.
      expect(
        await servicio.entrarConPin(usuario.id, '1234'),
        ResultadoAcceso.bloqueado,
      );
      expect(await servicio.bloqueoRestante(usuario.id), isNotNull);
    });

    test('eliminar a la persona borra también sus credenciales', () async {
      final usuario = await servicio.crearPersona(
        nombre: 'Luisa',
        rol: Roles.lectura,
        clave: 'secreto1',
        pin: '1234',
      );
      await servicio.eliminarPersona(usuario.id);
      expect(await base.listaUsuarios(), isEmpty);
      expect(await servicio.tieneCredenciales(usuario.id), isFalse);
      expect(
        await servicio.entrarConPin(usuario.id, '1234'),
        ResultadoAcceso.sinCredenciales,
      );
    });

    test('restablecer la contraseña deja entrar con la nueva', () async {
      final usuario = await servicio.crearPersona(
        nombre: 'Ana',
        rol: Roles.miembro,
        clave: 'secreto1',
        pin: '1234',
      );
      await servicio.fijarClave(usuario.id, 'nueva-clave');
      expect(
        await servicio.entrarConClave(usuario.id, 'nueva-clave'),
        ResultadoAcceso.correcto,
      );
      expect(
        await servicio.claveActualCoincide(usuario.id, 'secreto1'),
        isFalse,
      );
    });
  });

  group('renombrar personas (v0.7.1)', () {
    test(
      'cambia el nombre y el acceso sigue igual (misma clave y PIN)',
      () async {
        final usuario = await servicio.crearPersona(
          nombre: 'Esteban',
          rol: Roles.administrador,
          clave: 'secreto1',
          pin: '1234',
        );
        await servicio.renombrarPersona(usuario.id, 'Esteban Franco');
        expect((await base.usuarioPorId(usuario.id))?.nombre, 'Esteban Franco');
        expect(
          await servicio.entrarConClave(usuario.id, 'secreto1'),
          ResultadoAcceso.correcto,
        );
        expect(
          await servicio.entrarConPin(usuario.id, '1234'),
          ResultadoAcceso.correcto,
        );
      },
    );

    test('no deja un nombre vacío ni uno ya usado por otra persona', () async {
      final uno = await servicio.crearPersona(
        nombre: 'Ana',
        rol: Roles.miembro,
        clave: 'secreto1',
        pin: '1234',
      );
      await servicio.crearPersona(
        nombre: 'Luis',
        rol: Roles.miembro,
        clave: 'secreto1',
        pin: '1234',
      );
      expect(
        () => servicio.renombrarPersona(uno.id, '  '),
        throwsArgumentError,
      );
      expect(
        () => servicio.renombrarPersona(uno.id, 'LUIS'),
        throwsArgumentError,
      );
      // Su propio nombre con otras mayúsculas no es error: no cambia.
      await servicio.renombrarPersona(uno.id, 'ana');
      expect((await base.usuarioPorId(uno.id))?.nombre, 'Ana');
    });

    test('el historial de gastos queda con el nombre nuevo', () async {
      final usuario = await servicio.crearPersona(
        nombre: 'Esteban',
        rol: Roles.administrador,
        clave: 'secreto1',
        pin: '1234',
      );
      final categoriaId = await base
          .into(base.categorias)
          .insert(
            CategoriasCompanion.insert(
              nombre: 'Mercado y comida',
              colorValor: 0xFF2E7D32,
            ),
          );
      final ahora = DateTime(2026, 11, 14);
      await base.crearGasto(
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
      await servicio.renombrarPersona(usuario.id, 'Esteban Franco');
      final gasto = await base.select(base.gastos).getSingle();
      expect(gasto.hechoPor, 'Esteban Franco');
    });
  });
}
