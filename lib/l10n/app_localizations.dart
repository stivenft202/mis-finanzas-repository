import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @agregarGasto.
  ///
  /// In es, this message translates to:
  /// **'Agregar gasto'**
  String get agregarGasto;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @cantidadDeGastos.
  ///
  /// In es, this message translates to:
  /// **'{cantidad} gastos'**
  String cantidadDeGastos(int cantidad);

  /// No description provided for @categoria.
  ///
  /// In es, this message translates to:
  /// **'Categoría'**
  String get categoria;

  /// No description provided for @categoriaConGastos.
  ///
  /// In es, this message translates to:
  /// **'Esta categoría ya tiene gastos. Mejor ocúltala para no perder el historial.'**
  String get categoriaConGastos;

  /// No description provided for @categorias.
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get categorias;

  /// No description provided for @confirmarEliminarCategoria.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar esta categoría?'**
  String get confirmarEliminarCategoria;

  /// No description provided for @confirmarEliminarGasto.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este gasto?'**
  String get confirmarEliminarGasto;

  /// No description provided for @descripcion.
  ///
  /// In es, this message translates to:
  /// **'Descripción (opcional)'**
  String get descripcion;

  /// No description provided for @deshacer.
  ///
  /// In es, this message translates to:
  /// **'Deshacer'**
  String get deshacer;

  /// No description provided for @editar.
  ///
  /// In es, this message translates to:
  /// **'Editar'**
  String get editar;

  /// No description provided for @efectivo.
  ///
  /// In es, this message translates to:
  /// **'Efectivo'**
  String get efectivo;

  /// No description provided for @eliminar.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get eliminar;

  /// No description provided for @errorCategoria.
  ///
  /// In es, this message translates to:
  /// **'Elige una categoría.'**
  String get errorCategoria;

  /// No description provided for @errorMonto.
  ///
  /// In es, this message translates to:
  /// **'Escribe un monto válido, mayor que cero.'**
  String get errorMonto;

  /// No description provided for @fecha.
  ///
  /// In es, this message translates to:
  /// **'Fecha'**
  String get fecha;

  /// No description provided for @gastoEliminado.
  ///
  /// In es, this message translates to:
  /// **'Gasto eliminado.'**
  String get gastoEliminado;

  /// No description provided for @gastoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Gasto guardado.'**
  String get gastoGuardado;

  /// No description provided for @gastosDeEsteMes.
  ///
  /// In es, this message translates to:
  /// **'Gastos de este mes'**
  String get gastosDeEsteMes;

  /// No description provided for @guardar.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get guardar;

  /// No description provided for @metodoDePago.
  ///
  /// In es, this message translates to:
  /// **'Método de pago'**
  String get metodoDePago;

  /// No description provided for @monto.
  ///
  /// In es, this message translates to:
  /// **'Monto'**
  String get monto;

  /// No description provided for @mostrar.
  ///
  /// In es, this message translates to:
  /// **'Mostrar'**
  String get mostrar;

  /// No description provided for @nombreCategoria.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la categoría'**
  String get nombreCategoria;

  /// No description provided for @nuevaCategoria.
  ///
  /// In es, this message translates to:
  /// **'Nueva categoría'**
  String get nuevaCategoria;

  /// No description provided for @ocultar.
  ///
  /// In es, this message translates to:
  /// **'Ocultar'**
  String get ocultar;

  /// No description provided for @otro.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get otro;

  /// No description provided for @quienLoHizo.
  ///
  /// In es, this message translates to:
  /// **'¿Quién lo hizo?'**
  String get quienLoHizo;

  /// No description provided for @sinGastosEsteMes.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay gastos este mes. Toca «Agregar gasto» para registrar el primero.'**
  String get sinGastosEsteMes;

  /// No description provided for @tarjeta.
  ///
  /// In es, this message translates to:
  /// **'Tarjeta'**
  String get tarjeta;

  /// No description provided for @tipoFacturaOpcional.
  ///
  /// In es, this message translates to:
  /// **'Tipo de factura (opcional)'**
  String get tipoFacturaOpcional;

  /// No description provided for @tituloApp.
  ///
  /// In es, this message translates to:
  /// **'Finanzas del Hogar'**
  String get tituloApp;

  /// No description provided for @transferencia.
  ///
  /// In es, this message translates to:
  /// **'Transferencia'**
  String get transferencia;

  /// No description provided for @ultimosGastos.
  ///
  /// In es, this message translates to:
  /// **'Últimos gastos'**
  String get ultimosGastos;

  /// No description provided for @verGastos.
  ///
  /// In es, this message translates to:
  /// **'Ver gastos'**
  String get verGastos;

  /// No description provided for @agregarGastoFijo.
  ///
  /// In es, this message translates to:
  /// **'Agregar gasto fijo'**
  String get agregarGastoFijo;

  /// No description provided for @agregarIngresoFijo.
  ///
  /// In es, this message translates to:
  /// **'Agregar ingreso fijo'**
  String get agregarIngresoFijo;

  /// No description provided for @confirmarEliminarFijo.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar este fijo?'**
  String get confirmarEliminarFijo;

  /// No description provided for @descripcionCorta.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descripcionCorta;

  /// No description provided for @diaDelMes.
  ///
  /// In es, this message translates to:
  /// **'Día {dia}'**
  String diaDelMes(int dia);

  /// No description provided for @diaEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Día del mes'**
  String get diaEtiqueta;

  /// No description provided for @enCero.
  ///
  /// In es, this message translates to:
  /// **'Ni sobra ni falta'**
  String get enCero;

  /// No description provided for @errorNombre.
  ///
  /// In es, this message translates to:
  /// **'Escribe un nombre.'**
  String get errorNombre;

  /// No description provided for @fechaRecurrente.
  ///
  /// In es, this message translates to:
  /// **'Fecha recurrente'**
  String get fechaRecurrente;

  /// No description provided for @fijoEliminado.
  ///
  /// In es, this message translates to:
  /// **'Fijo eliminado.'**
  String get fijoEliminado;

  /// No description provided for @fijoGuardado.
  ///
  /// In es, this message translates to:
  /// **'Fijo guardado.'**
  String get fijoGuardado;

  /// No description provided for @fijosDelMes.
  ///
  /// In es, this message translates to:
  /// **'Fijos del mes'**
  String get fijosDelMes;

  /// No description provided for @gastoFijo.
  ///
  /// In es, this message translates to:
  /// **'Gasto fijo'**
  String get gastoFijo;

  /// No description provided for @gastosFijos.
  ///
  /// In es, this message translates to:
  /// **'GASTOS FIJOS'**
  String get gastosFijos;

  /// No description provided for @ingresoFijo.
  ///
  /// In es, this message translates to:
  /// **'Ingreso fijo'**
  String get ingresoFijo;

  /// No description provided for @ingresosFijos.
  ///
  /// In es, this message translates to:
  /// **'INGRESOS FIJOS'**
  String get ingresosFijos;

  /// No description provided for @nombre.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nombre;

  /// No description provided for @sinGastosFijos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay gastos fijos. Agrega el primero con el botón de abajo.'**
  String get sinGastosFijos;

  /// No description provided for @sinIngresosFijos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay ingresos fijos. Agrega el primero con el botón de abajo.'**
  String get sinIngresosFijos;

  /// No description provided for @teFalta.
  ///
  /// In es, this message translates to:
  /// **'Te falta'**
  String get teFalta;

  /// No description provided for @teSobra.
  ///
  /// In es, this message translates to:
  /// **'Te sobra'**
  String get teSobra;

  /// No description provided for @totalGastos.
  ///
  /// In es, this message translates to:
  /// **'TOTAL GASTOS'**
  String get totalGastos;

  /// No description provided for @totalIngresos.
  ///
  /// In es, this message translates to:
  /// **'TOTAL INGRESOS'**
  String get totalIngresos;

  /// No description provided for @utilidadDeuda.
  ///
  /// In es, this message translates to:
  /// **'UTILIDAD / DEUDA'**
  String get utilidadDeuda;

  /// No description provided for @valor.
  ///
  /// In es, this message translates to:
  /// **'Valor'**
  String get valor;

  /// No description provided for @respaldo.
  ///
  /// In es, this message translates to:
  /// **'Respaldo'**
  String get respaldo;

  /// No description provided for @respaldoIntro.
  ///
  /// In es, this message translates to:
  /// **'Pasa todos tus datos de un equipo a otro en un solo archivo: expórtalos aquí, lleva el archivo al otro equipo (por WhatsApp, cable o Drive) e impórtalo allá. No tendrás que volver a ingresar nada.'**
  String get respaldoIntro;

  /// No description provided for @exportarMisDatos.
  ///
  /// In es, this message translates to:
  /// **'Exportar mis datos'**
  String get exportarMisDatos;

  /// No description provided for @exportarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Guarda un archivo con todos tus gastos, categorías y fijos.'**
  String get exportarAyuda;

  /// No description provided for @importarDatos.
  ///
  /// In es, this message translates to:
  /// **'Importar datos'**
  String get importarDatos;

  /// No description provided for @importarAyuda.
  ///
  /// In es, this message translates to:
  /// **'Elige un archivo de respaldo y este equipo queda con todos esos datos.'**
  String get importarAyuda;

  /// No description provided for @guardarRespaldoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Guardar archivo de respaldo'**
  String get guardarRespaldoTitulo;

  /// No description provided for @elegirRespaldoTitulo.
  ///
  /// In es, this message translates to:
  /// **'Elegir archivo de respaldo'**
  String get elegirRespaldoTitulo;

  /// No description provided for @exportarListo.
  ///
  /// In es, this message translates to:
  /// **'Respaldo guardado. Ahora lleva el archivo al otro equipo e impórtalo allá.'**
  String get exportarListo;

  /// No description provided for @importarListo.
  ///
  /// In es, this message translates to:
  /// **'Datos importados. Este equipo ya tiene todo lo del archivo.'**
  String get importarListo;

  /// No description provided for @importarAvisoTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿Reemplazar todos los datos?'**
  String get importarAvisoTitulo;

  /// No description provided for @importarAvisoTexto.
  ///
  /// In es, this message translates to:
  /// **'El archivo trae {gastos} gastos, {categorias} categorías y {fijos} fijos. Al importar se BORRA todo lo que hay ahora en este equipo y queda lo del archivo. Esto no se puede deshacer.'**
  String importarAvisoTexto(int gastos, int categorias, int fijos);

  /// No description provided for @siImportar.
  ///
  /// In es, this message translates to:
  /// **'Sí, importar'**
  String get siImportar;

  /// No description provided for @archivoNoValido.
  ///
  /// In es, this message translates to:
  /// **'Ese archivo no es un respaldo válido de esta app.'**
  String get archivoNoValido;

  /// No description provided for @errorRespaldo.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar el respaldo. Inténtalo de nuevo.'**
  String get errorRespaldo;

  /// No description provided for @actualizacion.
  ///
  /// In es, this message translates to:
  /// **'Actualización'**
  String get actualizacion;

  /// No description provided for @versionActual.
  ///
  /// In es, this message translates to:
  /// **'Versión actual: {version}'**
  String versionActual(String version);

  /// No description provided for @buscarActualizacion.
  ///
  /// In es, this message translates to:
  /// **'Buscar actualización'**
  String get buscarActualizacion;

  /// No description provided for @buscandoActualizacion.
  ///
  /// In es, this message translates to:
  /// **'Buscando…'**
  String get buscandoActualizacion;

  /// No description provided for @yaTienesLaUltima.
  ///
  /// In es, this message translates to:
  /// **'Ya tienes la última versión. No hay nada que actualizar.'**
  String get yaTienesLaUltima;

  /// No description provided for @hayVersionNueva.
  ///
  /// In es, this message translates to:
  /// **'Hay una versión nueva: {version}'**
  String hayVersionNueva(String version);

  /// No description provided for @actualizarAhora.
  ///
  /// In es, this message translates to:
  /// **'Actualizar ahora'**
  String get actualizarAhora;

  /// No description provided for @descargandoActualizacion.
  ///
  /// In es, this message translates to:
  /// **'Descargando la actualización…'**
  String get descargandoActualizacion;

  /// No description provided for @errorAlBuscarActualizacion.
  ///
  /// In es, this message translates to:
  /// **'No se pudo buscar la actualización. Revisa tu conexión a internet e inténtalo de nuevo.'**
  String get errorAlBuscarActualizacion;

  /// No description provided for @errorAlActualizar.
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal al actualizar. Inténtalo de nuevo.'**
  String get errorAlActualizar;

  /// No description provided for @instaladorAbierto.
  ///
  /// In es, this message translates to:
  /// **'Se abrió el instalador: toca «Instalar» para terminar de actualizar.'**
  String get instaladorAbierto;

  /// No description provided for @actualizarAvisoWindows.
  ///
  /// In es, this message translates to:
  /// **'La app se va a cerrar un momento, se actualiza sola y se vuelve a abrir ya con la versión nueva. Tus datos no se tocan.'**
  String get actualizarAvisoWindows;

  /// No description provided for @hayActualizacionCorta.
  ///
  /// In es, this message translates to:
  /// **'Hay una versión nueva'**
  String get hayActualizacionCorta;

  /// No description provided for @actualizar.
  ///
  /// In es, this message translates to:
  /// **'Actualizar'**
  String get actualizar;

  /// No description provided for @bienvenidaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a Finanzas del Hogar'**
  String get bienvenidaTitulo;

  /// No description provided for @creandoAdminIntro.
  ///
  /// In es, this message translates to:
  /// **'Primero crea tu usuario. Serás el administrador: podrás agregar a tu familia y cuidar los datos de este equipo.'**
  String get creandoAdminIntro;

  /// No description provided for @crearMiUsuario.
  ///
  /// In es, this message translates to:
  /// **'Crear mi usuario'**
  String get crearMiUsuario;

  /// No description provided for @nombrePersona.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nombrePersona;

  /// No description provided for @contrasena.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get contrasena;

  /// No description provided for @confirmarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmarContrasena;

  /// No description provided for @pin.
  ///
  /// In es, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @pinAyuda.
  ///
  /// In es, this message translates to:
  /// **'De 4 a 6 números. Es tu entrada rápida de cada día.'**
  String get pinAyuda;

  /// No description provided for @confirmarPin.
  ///
  /// In es, this message translates to:
  /// **'Confirmar el PIN'**
  String get confirmarPin;

  /// No description provided for @lasClavesNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden.'**
  String get lasClavesNoCoinciden;

  /// No description provided for @losPinesNoCoinciden.
  ///
  /// In es, this message translates to:
  /// **'Los PIN no coinciden.'**
  String get losPinesNoCoinciden;

  /// No description provided for @eligeTuUsuario.
  ///
  /// In es, this message translates to:
  /// **'¿Quién va a entrar?'**
  String get eligeTuUsuario;

  /// No description provided for @entrar.
  ///
  /// In es, this message translates to:
  /// **'Entrar'**
  String get entrar;

  /// No description provided for @usarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Entrar con mi contraseña'**
  String get usarContrasena;

  /// No description provided for @usarPin.
  ///
  /// In es, this message translates to:
  /// **'Entrar con mi PIN'**
  String get usarPin;

  /// No description provided for @pinIncorrecto.
  ///
  /// In es, this message translates to:
  /// **'PIN incorrecto. Inténtalo de nuevo.'**
  String get pinIncorrecto;

  /// No description provided for @claveIncorrecta.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta. Inténtalo de nuevo.'**
  String get claveIncorrecta;

  /// No description provided for @accesoBloqueado.
  ///
  /// In es, this message translates to:
  /// **'Demasiados intentos fallidos. Espera {segundos} segundos y vuelve a intentarlo.'**
  String accesoBloqueado(int segundos);

  /// No description provided for @sinCredencialesAviso.
  ///
  /// In es, this message translates to:
  /// **'Esta persona aún no tiene contraseña en este equipo. Un administrador puede restablecerla en Usuarios.'**
  String get sinCredencialesAviso;

  /// No description provided for @appBloqueada.
  ///
  /// In es, this message translates to:
  /// **'La app se bloqueó por seguridad. Escribe tu PIN para seguir.'**
  String get appBloqueada;

  /// No description provided for @cambiarDeUsuario.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de usuario'**
  String get cambiarDeUsuario;

  /// No description provided for @usuarios.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get usuarios;

  /// No description provided for @miSeguridad.
  ///
  /// In es, this message translates to:
  /// **'Mi seguridad'**
  String get miSeguridad;

  /// No description provided for @cambiarContrasena.
  ///
  /// In es, this message translates to:
  /// **'Cambiar mi contraseña'**
  String get cambiarContrasena;

  /// No description provided for @cambiarPin.
  ///
  /// In es, this message translates to:
  /// **'Cambiar mi PIN'**
  String get cambiarPin;

  /// No description provided for @contrasenaActual.
  ///
  /// In es, this message translates to:
  /// **'Contraseña actual'**
  String get contrasenaActual;

  /// No description provided for @contrasenaNueva.
  ///
  /// In es, this message translates to:
  /// **'Contraseña nueva'**
  String get contrasenaNueva;

  /// No description provided for @pinActual.
  ///
  /// In es, this message translates to:
  /// **'PIN actual'**
  String get pinActual;

  /// No description provided for @pinNuevo.
  ///
  /// In es, this message translates to:
  /// **'PIN nuevo'**
  String get pinNuevo;

  /// No description provided for @bloqueoAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Bloqueo automático'**
  String get bloqueoAutomatico;

  /// No description provided for @bloqueoNunca.
  ///
  /// In es, this message translates to:
  /// **'Nunca (no bloquear)'**
  String get bloqueoNunca;

  /// No description provided for @bloqueoTras1.
  ///
  /// In es, this message translates to:
  /// **'Tras 1 minuto sin usar'**
  String get bloqueoTras1;

  /// No description provided for @bloqueoTras5.
  ///
  /// In es, this message translates to:
  /// **'Tras 5 minutos sin usar'**
  String get bloqueoTras5;

  /// No description provided for @bloqueoTras15.
  ///
  /// In es, this message translates to:
  /// **'Tras 15 minutos sin usar'**
  String get bloqueoTras15;

  /// No description provided for @cambiosGuardados.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados.'**
  String get cambiosGuardados;

  /// No description provided for @errorClaveActual.
  ///
  /// In es, this message translates to:
  /// **'La contraseña actual no coincide.'**
  String get errorClaveActual;

  /// No description provided for @errorPinActual.
  ///
  /// In es, this message translates to:
  /// **'El PIN actual no coincide.'**
  String get errorPinActual;

  /// No description provided for @personasDelHogar.
  ///
  /// In es, this message translates to:
  /// **'Personas del hogar'**
  String get personasDelHogar;

  /// No description provided for @agregarPersona.
  ///
  /// In es, this message translates to:
  /// **'Agregar persona'**
  String get agregarPersona;

  /// No description provided for @personaCreada.
  ///
  /// In es, this message translates to:
  /// **'Persona agregada.'**
  String get personaCreada;

  /// No description provided for @personaEliminada.
  ///
  /// In es, this message translates to:
  /// **'Persona eliminada.'**
  String get personaEliminada;

  /// No description provided for @confirmarEliminarPersona.
  ///
  /// In es, this message translates to:
  /// **'¿Eliminar a {nombre}? Ya no podrá entrar en este equipo.'**
  String confirmarEliminarPersona(String nombre);

  /// No description provided for @noPuedesEliminarte.
  ///
  /// In es, this message translates to:
  /// **'No puedes eliminarte a ti mismo.'**
  String get noPuedesEliminarte;

  /// No description provided for @ultimoAdministrador.
  ///
  /// In es, this message translates to:
  /// **'Debe quedar al menos un administrador en el hogar.'**
  String get ultimoAdministrador;

  /// No description provided for @cambiarRol.
  ///
  /// In es, this message translates to:
  /// **'Cambiar rol'**
  String get cambiarRol;

  /// No description provided for @restablecerClave.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get restablecerClave;

  /// No description provided for @restablecerPin.
  ///
  /// In es, this message translates to:
  /// **'Restablecer PIN'**
  String get restablecerPin;

  /// No description provided for @rol.
  ///
  /// In es, this message translates to:
  /// **'Rol'**
  String get rol;

  /// No description provided for @rolAdministrador.
  ///
  /// In es, this message translates to:
  /// **'Administrador'**
  String get rolAdministrador;

  /// No description provided for @rolMiembro.
  ///
  /// In es, this message translates to:
  /// **'Miembro'**
  String get rolMiembro;

  /// No description provided for @rolLectura.
  ///
  /// In es, this message translates to:
  /// **'Solo lectura'**
  String get rolLectura;

  /// No description provided for @holaUsuario.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombre}'**
  String holaUsuario(String nombre);

  /// No description provided for @salir.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get salir;

  /// No description provided for @notaSoloLectura.
  ///
  /// In es, this message translates to:
  /// **'Tu usuario es de solo lectura: puedes mirar todo, pero no cambiar datos.'**
  String get notaSoloLectura;

  /// No description provided for @importarSoloAdmin.
  ///
  /// In es, this message translates to:
  /// **'Solo un administrador puede importar datos, porque importar reemplaza todo lo que hay en el equipo.'**
  String get importarSoloAdmin;

  /// No description provided for @modoClaro.
  ///
  /// In es, this message translates to:
  /// **'Modo claro'**
  String get modoClaro;

  /// No description provided for @modoOscuro.
  ///
  /// In es, this message translates to:
  /// **'Modo oscuro'**
  String get modoOscuro;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
