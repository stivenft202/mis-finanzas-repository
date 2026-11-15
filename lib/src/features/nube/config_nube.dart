/// Datos del proyecto de Firebase de Esteban (su registro web).
///
/// Ojo: estos datos NO son contraseñas. Son la dirección pública del
/// proyecto (como la dirección de un edificio); la llave de verdad es
/// la cuenta del hogar (correo y contraseña) y las reglas de la base
/// de datos, que solo dejan entrar a esa cuenta.
library;

abstract final class ConfigNube {
  static const String apiKey = 'AIzaSyDOwUey3yDqnND8DPUFpt_-RoIWhP4Jdwk';
  static const String projectId = 'finanzas-del-hogar-6713a';

  /// ¿Ya están los datos reales del proyecto?
  static bool get configurada =>
      !apiKey.startsWith('PONER-') && !projectId.startsWith('PONER-');
}
