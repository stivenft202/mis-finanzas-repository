# Arquitectura y decisiones — Fase 0

Documento de decisiones técnicas, escrito en lenguaje sencillo.
Cada decisión dice qué se eligió y por qué. Si algo tiene un límite o un costo, está dicho aquí.

## 1. Marco de trabajo: Flutter + Dart

Un solo código produce la app de **Android** y la de **Windows**. Botones grandes, letra grande y modo oscuro se logran con el sistema de diseño de Flutter (Material 3) sin duplicar trabajo.

- **Estado de la app:** Riverpod. Es la forma ordenada de compartir datos entre pantallas (por ejemplo, el saldo del mes) sin errores de «pantalla desactualizada».
- **Capas:** presentación (pantallas) → dominio (las reglas: presupuestos, conversión de moneda) → datos (base local y nube). Si mañana cambia la nube, no se tocan las pantallas.

## 2. Local primero: la base de datos vive en el dispositivo

- **SQLite con Drift, cifrada con SQLCipher.** Los gastos se guardan primero en el celular o el PC, con contraseña de cifrado. La app funciona completa **sin internet**.
- La sincronización (Fase 8) sube los cambios cuando hay conexión. Si dos personas editan lo mismo, **gana el cambio más reciente** y queda guardado un historial de cambios.
- Nota honesta: el cifrado se activa en la Fase 1 y protege los datos si alguien extrae el archivo de la base; la llave se guarda en el almacenamiento seguro del dispositivo.

## 3. Nube: Firebase (Auth + Firestore + Storage)

¿Por qué Firebase y no Supabase? En tres líneas:

1. Su plan gratuito **no se pausa nunca**; el de Supabase se duerme tras días sin uso y tocaría «despertarlo» a mano en una consola técnica.
2. Firestore ya sabe trabajar sin internet y sincronizar solo, que es justo el diseño «local primero» de esta app.
3. Su capa gratuita (lecturas/escrituras diarias y 1 GB) sobra para un hogar; Supabase se guarda como plan B porque los datos se pueden exportar.

- **Auth:** usuario y contraseña por persona. **Firestore:** los datos del hogar. **Storage:** las fotos de facturas.
- La sesión rápida con **PIN** es local del dispositivo (el PIN se guarda con hash, nunca en texto plano, en el almacenamiento seguro).

## 4. Monedas y tasas de cambio

- Monedas iniciales: **COP, ARS, MXN, UYU, PEN, USD**, definidas en **un solo archivo** de configuración (`core/monedas`) con su símbolo y formato (COP sin decimales, USD con 2, etc.). Agregar una moneda después = agregar una línea ahí.
- Cada gasto guarda: monto y moneda originales, **tasa usada y su fecha**, y el equivalente en la moneda base del hogar. Las tasas viejas **no** se reescriben solas; habrá botón opcional «Recalcular con tasa de hoy», con confirmación.
- **Proveedor principal:** ExchangeRate-API en su plan abierto (`open.er-api.com`): gratuito, sin clave, incluye las seis monedas, se actualiza a diario. La atribución que pide es un texto «Rates by Exchange Rate API» en la pantalla de ajustes.
- **Respaldo:** la API pública de divisas de fawazahmed0 servida por CDN (gratuita, sin clave, también incluye las seis monedas), por si el principal falla.
- **Sin internet:** se usa la última tasa guardada y la pantalla muestra «Tasa del [fecha]». También se podrá escribir una tasa a mano para un gasto puntual.
- **Argentina:** como el ARS tiene varias cotizaciones, en ajustes se elegirá cuál usar (oficial, blue, MEP…). Esas cotizaciones salen de **dolarapi.com** (gratuita) y siempre se marcan como «referencia».
- La app consulta tasas al abrirse y luego cada 12 horas (configurable).

## 5. Voz

- **Android:** el reconocimiento de voz del propio sistema (gratis, sin claves).
- **Windows:** el reconocimiento nativo no es confiable en todos los PC. La ruta elegida: **grabar el audio y transcribirlo**. Hay dos caminos, y el definitivo se decide en la Fase 5:
  - Servicio Whisper (OpenAI): aprox. **0,006 USD por minuto** de audio; un hogar dictando a diario gastaría centavos al mes, pero requiere internet y una clave de pago.
  - Whisper local en el PC (whisper.cpp): **$0**, funciona sin internet, pero ocupa espacio (~1–3 GB) y en PC lentos tarda unos segundos por frase.
- Regla de oro en ambas plataformas: la app **muestra lo que entendió y solo guarda tras la confirmación** de la persona.

## 6. Fotos de facturas (OCR)

- **Android:** ML Kit (gratis, en el propio celular).
- **Windows:** Tesseract (gratis, en el propio PC).
- La foto se comprime antes de guardarse y se sincroniza en la Fase 8.

## 7. Búsqueda de precios (honestidad anticipada, detalle en la Fase 7)

No existe una API pública, gratuita y confiable de precios de productos de supermercado en Colombia. Por eso el diseño usa una capa intercambiable de «proveedor de precios»: la Fase 7 evaluará las opciones reales (con su costo y límites) antes de conectar cualquiera, y todo precio sugerido se marcará siempre como **«estimado»**.

## 8. Actualizaciones desde GitHub

- Al publicar una versión (Release) en este repositorio, **GitHub Actions compila solo** el APK de Android y el instalador de Windows y los deja adjuntos en la Release.
- La app (Fase 10) revisa si hay versión nueva, muestra las notas y, con un toque, descarga e instala. Antes de instalar verifica la integridad con el **hash** publicado.
- Honestidad: se descarga el **paquete completo** de la nueva versión (no «solo los cambios»); los datos del usuario se conservan porque viven aparte del programa.
- **El repositorio debe ser público** para que la app descargue sin credenciales — y este ya lo es. Si un día se quiere privado, la alternativa segura es un servidor intermedio que entregue los paquetes; meter un token dentro de la app **no** es seguro y no se hará.

## 9. Textos e idioma

Todos los textos visibles viven en un archivo de traducciones (`l10n`), hoy solo en español. Agregar otro idioma después no exige tocar el código.

## 10. Pruebas

Cada fase incluye pruebas automáticas básicas (de las reglas de negocio y de la base de datos) que corren en GitHub Actions en cada cambio, además de la prueba manual guiada que se le entrega a Esteban al cerrar cada fase.
