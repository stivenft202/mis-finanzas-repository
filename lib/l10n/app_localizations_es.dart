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
}
