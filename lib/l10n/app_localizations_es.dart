// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get agregarGasto => 'Agregar gasto';

  @override
  String get cancelar => 'Cancelar';

  @override
  String cantidadDeGastos(int cantidad) {
    return '$cantidad gastos';
  }

  @override
  String get categoria => 'Categoría';

  @override
  String get categoriaConGastos =>
      'Esta categoría ya tiene gastos. Mejor ocúltala para no perder el historial.';

  @override
  String get categorias => 'Categorías';

  @override
  String get confirmarEliminarCategoria => '¿Eliminar esta categoría?';

  @override
  String get confirmarEliminarGasto => '¿Eliminar este gasto?';

  @override
  String get descripcion => 'Descripción (opcional)';

  @override
  String get deshacer => 'Deshacer';

  @override
  String get editar => 'Editar';

  @override
  String get efectivo => 'Efectivo';

  @override
  String get eliminar => 'Eliminar';

  @override
  String get errorCategoria => 'Elige una categoría.';

  @override
  String get errorMonto => 'Escribe un monto válido, mayor que cero.';

  @override
  String get fecha => 'Fecha';

  @override
  String get gastoEliminado => 'Gasto eliminado.';

  @override
  String get gastoGuardado => 'Gasto guardado.';

  @override
  String get gastosDeEsteMes => 'Gastos de este mes';

  @override
  String get guardar => 'Guardar';

  @override
  String get metodoDePago => 'Método de pago';

  @override
  String get monto => 'Monto';

  @override
  String get mostrar => 'Mostrar';

  @override
  String get nombreCategoria => 'Nombre de la categoría';

  @override
  String get nuevaCategoria => 'Nueva categoría';

  @override
  String get ocultar => 'Ocultar';

  @override
  String get otro => 'Otro';

  @override
  String get quienLoHizo => '¿Quién lo hizo?';

  @override
  String get sinGastosEsteMes =>
      'Todavía no hay gastos este mes. Toca «Agregar gasto» para registrar el primero.';

  @override
  String get tarjeta => 'Tarjeta';

  @override
  String get tipoFacturaOpcional => 'Tipo de factura (opcional)';

  @override
  String get tituloApp => 'Finanzas del Hogar';

  @override
  String get transferencia => 'Transferencia';

  @override
  String get ultimosGastos => 'Últimos gastos';

  @override
  String get verGastos => 'Ver gastos';

  @override
  String get agregarGastoFijo => 'Agregar gasto fijo';

  @override
  String get agregarIngresoFijo => 'Agregar ingreso fijo';

  @override
  String get confirmarEliminarFijo => '¿Eliminar este fijo?';

  @override
  String get descripcionCorta => 'Descripción';

  @override
  String diaDelMes(int dia) {
    return 'Día $dia';
  }

  @override
  String get diaEtiqueta => 'Día del mes';

  @override
  String get enCero => 'Ni sobra ni falta';

  @override
  String get errorNombre => 'Escribe un nombre.';

  @override
  String get fechaRecurrente => 'Fecha recurrente';

  @override
  String get fijoEliminado => 'Fijo eliminado.';

  @override
  String get fijoGuardado => 'Fijo guardado.';

  @override
  String get fijosDelMes => 'Fijos del mes';

  @override
  String get gastoFijo => 'Gasto fijo';

  @override
  String get gastosFijos => 'GASTOS FIJOS';

  @override
  String get ingresoFijo => 'Ingreso fijo';

  @override
  String get ingresosFijos => 'INGRESOS FIJOS';

  @override
  String get nombre => 'Nombre';

  @override
  String get sinGastosFijos =>
      'Todavía no hay gastos fijos. Agrega el primero con el botón de abajo.';

  @override
  String get sinIngresosFijos =>
      'Todavía no hay ingresos fijos. Agrega el primero con el botón de abajo.';

  @override
  String get teFalta => 'Te falta';

  @override
  String get teSobra => 'Te sobra';

  @override
  String get totalGastos => 'TOTAL GASTOS';

  @override
  String get totalIngresos => 'TOTAL INGRESOS';

  @override
  String get utilidadDeuda => 'UTILIDAD / DEUDA';

  @override
  String get valor => 'Valor';

  @override
  String get respaldo => 'Respaldo';

  @override
  String get respaldoIntro =>
      'Pasa todos tus datos de un equipo a otro en un solo archivo: expórtalos aquí, lleva el archivo al otro equipo (por WhatsApp, cable o Drive) e impórtalo allá. No tendrás que volver a ingresar nada.';

  @override
  String get exportarMisDatos => 'Exportar mis datos';

  @override
  String get exportarAyuda =>
      'Guarda un archivo con todos tus gastos, categorías y fijos.';

  @override
  String get importarDatos => 'Importar datos';

  @override
  String get importarAyuda =>
      'Elige un archivo de respaldo y este equipo queda con todos esos datos.';

  @override
  String get guardarRespaldoTitulo => 'Guardar archivo de respaldo';

  @override
  String get elegirRespaldoTitulo => 'Elegir archivo de respaldo';

  @override
  String get exportarListo =>
      'Respaldo guardado. Ahora lleva el archivo al otro equipo e impórtalo allá.';

  @override
  String get importarListo =>
      'Datos importados. Este equipo ya tiene todo lo del archivo.';

  @override
  String get importarAvisoTitulo => '¿Reemplazar todos los datos?';

  @override
  String importarAvisoTexto(int gastos, int categorias, int fijos) {
    return 'El archivo trae $gastos gastos, $categorias categorías y $fijos fijos. Al importar se BORRA todo lo que hay ahora en este equipo y queda lo del archivo. Esto no se puede deshacer.';
  }

  @override
  String get siImportar => 'Sí, importar';

  @override
  String get archivoNoValido =>
      'Ese archivo no es un respaldo válido de esta app.';

  @override
  String get errorRespaldo =>
      'No se pudo guardar el respaldo. Inténtalo de nuevo.';

  @override
  String get actualizacion => 'Actualización';

  @override
  String versionActual(String version) {
    return 'Versión actual: $version';
  }

  @override
  String get buscarActualizacion => 'Buscar actualización';

  @override
  String get buscandoActualizacion => 'Buscando…';

  @override
  String get yaTienesLaUltima =>
      'Ya tienes la última versión. No hay nada que actualizar.';

  @override
  String hayVersionNueva(String version) {
    return 'Hay una versión nueva: $version';
  }

  @override
  String get actualizarAhora => 'Actualizar ahora';

  @override
  String get descargandoActualizacion => 'Descargando la actualización…';

  @override
  String get errorAlBuscarActualizacion =>
      'No se pudo buscar la actualización. Revisa tu conexión a internet e inténtalo de nuevo.';

  @override
  String get errorAlActualizar =>
      'Algo salió mal al actualizar. Inténtalo de nuevo.';

  @override
  String get instaladorAbierto =>
      'Se abrió el instalador: toca «Instalar» para terminar de actualizar.';

  @override
  String get actualizarAvisoWindows =>
      'La app se va a cerrar un momento, se actualiza sola y se vuelve a abrir ya con la versión nueva. Tus datos no se tocan.';

  @override
  String get hayActualizacionCorta => 'Hay una versión nueva';

  @override
  String get actualizar => 'Actualizar';

  @override
  String get bienvenidaTitulo => 'Bienvenido a Finanzas del Hogar';

  @override
  String get creandoAdminIntro =>
      'Primero crea tu usuario. Serás el administrador: podrás agregar a tu familia y cuidar los datos de este equipo.';

  @override
  String get crearMiUsuario => 'Crear mi usuario';

  @override
  String get nombrePersona => 'Nombre';

  @override
  String get contrasena => 'Contraseña';

  @override
  String get confirmarContrasena => 'Confirmar contraseña';

  @override
  String get pin => 'PIN';

  @override
  String get pinAyuda => 'De 4 a 6 números. Es tu entrada rápida de cada día.';

  @override
  String get confirmarPin => 'Confirmar el PIN';

  @override
  String get lasClavesNoCoinciden => 'Las contraseñas no coinciden.';

  @override
  String get losPinesNoCoinciden => 'Los PIN no coinciden.';

  @override
  String get eligeTuUsuario => '¿Quién va a entrar?';

  @override
  String get entrar => 'Entrar';

  @override
  String get usarContrasena => 'Entrar con mi contraseña';

  @override
  String get usarPin => 'Entrar con mi PIN';

  @override
  String get pinIncorrecto => 'PIN incorrecto. Inténtalo de nuevo.';

  @override
  String get claveIncorrecta => 'Contraseña incorrecta. Inténtalo de nuevo.';

  @override
  String accesoBloqueado(int segundos) {
    return 'Demasiados intentos fallidos. Espera $segundos segundos y vuelve a intentarlo.';
  }

  @override
  String get sinCredencialesAviso =>
      'Esta persona aún no tiene contraseña en este equipo. Un administrador puede restablecerla en Usuarios.';

  @override
  String get appBloqueada =>
      'La app se bloqueó por seguridad. Escribe tu PIN para seguir.';

  @override
  String get cambiarDeUsuario => 'Cambiar de usuario';

  @override
  String get usuarios => 'Usuarios';

  @override
  String get miSeguridad => 'Mi seguridad';

  @override
  String get cambiarContrasena => 'Cambiar mi contraseña';

  @override
  String get cambiarPin => 'Cambiar mi PIN';

  @override
  String get contrasenaActual => 'Contraseña actual';

  @override
  String get contrasenaNueva => 'Contraseña nueva';

  @override
  String get pinActual => 'PIN actual';

  @override
  String get pinNuevo => 'PIN nuevo';

  @override
  String get bloqueoAutomatico => 'Bloqueo automático';

  @override
  String get bloqueoNunca => 'Nunca (no bloquear)';

  @override
  String get bloqueoTras1 => 'Tras 1 minuto sin usar';

  @override
  String get bloqueoTras5 => 'Tras 5 minutos sin usar';

  @override
  String get bloqueoTras15 => 'Tras 15 minutos sin usar';

  @override
  String get cambiosGuardados => 'Cambios guardados.';

  @override
  String get errorClaveActual => 'La contraseña actual no coincide.';

  @override
  String get errorPinActual => 'El PIN actual no coincide.';

  @override
  String get personasDelHogar => 'Personas del hogar';

  @override
  String get agregarPersona => 'Agregar persona';

  @override
  String get personaCreada => 'Persona agregada.';

  @override
  String get personaEliminada => 'Persona eliminada.';

  @override
  String confirmarEliminarPersona(String nombre) {
    return '¿Eliminar a $nombre? Ya no podrá entrar en este equipo.';
  }

  @override
  String get noPuedesEliminarte => 'No puedes eliminarte a ti mismo.';

  @override
  String get ultimoAdministrador =>
      'Debe quedar al menos un administrador en el hogar.';

  @override
  String get cambiarRol => 'Cambiar rol';

  @override
  String get restablecerClave => 'Restablecer contraseña';

  @override
  String get restablecerPin => 'Restablecer PIN';

  @override
  String get rol => 'Rol';

  @override
  String get rolAdministrador => 'Administrador';

  @override
  String get rolMiembro => 'Miembro';

  @override
  String get rolLectura => 'Solo lectura';

  @override
  String holaUsuario(String nombre) {
    return 'Hola, $nombre';
  }

  @override
  String get salir => 'Salir';

  @override
  String get notaSoloLectura =>
      'Tu usuario es de solo lectura: puedes mirar todo, pero no cambiar datos.';

  @override
  String get importarSoloAdmin =>
      'Solo un administrador puede importar datos, porque importar reemplaza todo lo que hay en el equipo.';

  @override
  String get modoClaro => 'Modo claro';

  @override
  String get modoOscuro => 'Modo oscuro';

  @override
  String get dictarGasto => 'Dictar gasto';

  @override
  String get escuchandoTocaParaParar => 'Escuchando… toca para parar';

  @override
  String get escuche => 'Escuché';

  @override
  String get dictadoAyuda =>
      'Di el gasto en una frase, por ejemplo: «Gasté cuarenta y cinco mil en mercado, en efectivo». Lo que se entienda se llena solo; tú lo revisas antes de guardar.';

  @override
  String get dictadoNoDisponible =>
      'El reconocimiento de voz no está disponible en este equipo.';

  @override
  String get dictadoTipWindows =>
      'En Windows también puedes dictar en cualquier campo tocándolo y oprimiendo Win + H.';

  @override
  String get sinMontoEscuchado =>
      'No escuché el monto: escríbelo tú, por favor.';

  @override
  String get sinCategoriaEscuchada =>
      'No identifiqué la categoría: revisa la que quedó marcada.';
}
