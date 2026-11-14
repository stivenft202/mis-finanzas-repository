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
