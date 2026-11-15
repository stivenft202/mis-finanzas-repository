/// Servicio de dictado por voz (v0.7.0).
///
/// Envuelve el reconocedor de voz del equipo (en Android, el de
/// Google que el celular ya trae; sin cuentas ni pagos). La app solo
/// escucha cuando la persona toca el botón «Dictar gasto», y lo
/// reconocido se interpreta con [interpretarDictado] para llenar el
/// formulario: NADA se guarda sin la revisión de la persona.
library;

import 'package:speech_to_text/speech_to_text.dart';

class ServicioDictado {
  final SpeechToText _voz = SpeechToText();
  bool _preparado = false;

  bool get escuchando => _voz.isListening;

  /// Inicializa el reconocedor. Devuelve false si el equipo no tiene
  /// reconocimiento de voz disponible.
  Future<bool> preparar({
    SpeechErrorListener? alError,
    SpeechStatusListener? alEstado,
  }) async {
    if (_preparado) return true;
    try {
      _preparado = await _voz.initialize(onError: alError, onStatus: alEstado);
    } catch (_) {
      _preparado = false;
    }
    return _preparado;
  }

  /// Elige el español del equipo: primero es_CO, luego cualquier es_*.
  Future<String?> _idiomaEspanol() async {
    try {
      final locales = await _voz.locales();
      for (final l in locales) {
        if (l.localeId.toLowerCase().startsWith('es_co')) return l.localeId;
      }
      for (final l in locales) {
        if (l.localeId.toLowerCase().startsWith('es')) return l.localeId;
      }
    } catch (_) {
      // Sin lista de idiomas: se usa el del sistema.
    }
    return null;
  }

  /// Empieza a escuchar y va entregando lo reconocido (parcial y
  /// final) a [alResultado].
  Future<void> escuchar({required SpeechResultListener alResultado}) async {
    final localeId = await _idiomaEspanol();
    await _voz.listen(
      onResult: alResultado,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        pauseFor: const Duration(seconds: 4),
        listenFor: const Duration(seconds: 30),
        localeId: localeId,
      ),
    );
  }

  Future<void> detener() async {
    try {
      await _voz.stop();
    } catch (_) {
      // Si ya no estaba escuchando, no pasa nada.
    }
  }
}
