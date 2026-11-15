# Historial de cambios

Todos los cambios importantes de la app, versión por versión.
Formato basado en «Keep a Changelog», con versionado semántico.

## [0.7.0] - 2026-11-15

### Agregado
- **Dictado de gastos por voz** (fase adelantada): dentro de «Agregar gasto», el botón «Dictar gasto» usa el reconocedor de voz del equipo (en Android, el que el celular ya trae; sin cuentas ni pagos) y entiende frases como «Gasté cuarenta y cinco mil en mercado, en efectivo»: llena solo el monto (en palabras o en dígitos), la categoría (por su nombre o por palabras conocidas como gasolina, farmacia o colegio), la fecha si se dice «ayer» o «anteayer» y el método si se dice «en efectivo», «con tarjeta» o «por transferencia». Nada se guarda sin revisión: la tarjeta «Escuché» muestra las palabras reconocidas, lo entendido con ✔ y lo que no se entendió, y la persona corrige lo que haga falta y toca Guardar. Lo que no se entiende, no se inventa.

## [0.6.3] - 2026-11-15

### Corregido
- En Android, la fila de un gasto apretaba el texto contra el monto y los nombres largos se partían feo («Imprevistos y reparacione / s» en el inicio y en «Ver gastos»). La fila se rehízo: el texto tiene su espacio asegurado, pasa a dos líneas cortando por palabras y el monto se encoge un poco si hace falta, sin cortarse nunca.
- Los títulos de las barras superiores ya no salen cortados con «…» («Finan…», «Ver gastos · noviembr…»): ahora se encogen lo justo para leerse completos en todas las pantallas.

## [0.6.2] - 2026-11-14

### Corregido
- La actualización dentro de la app en Android fallaba con «conflicto con un paquete»: cada versión se firmaba con una llave temporal distinta (la de prueba de la máquina que compila) y Android, por seguridad, no actualiza una app si la firma cambia. Desde esta versión la app se firma siempre con la misma llave permanente. En Android hay que desinstalar la versión anterior e instalar esta una última vez; de ahí en adelante el botón «Actualizar» funciona siempre.

## [0.6.1] - 2026-11-14

### Corregido
- En «Usuarios», el título «Bloqueo automático» salía letra por letra en los celulares: el selector de minutos, puesto al lado, lo dejaba sin espacio. Ahora el selector va debajo del título, a todo el ancho.
- Los botones con degradado del inicio recortaban su texto en los celulares angostos («Ver gas…», «Catego…», «Fijos d…»). Ahora son un poco más altos, con la letra un poco más pequeña y un ajuste automático: el texto se encoge lo justo si hace falta, pero nunca se corta.

## [0.6.0] - 2026-11-14

### Agregado
- **Fase 5 — Usuarios y seguridad:** la app ahora pide acceso. La primera vez se crea el usuario administrador; después, cada persona del hogar entra tocando su nombre con su PIN (rápido) o su contraseña. Roles: administrador (todo, incluidas las personas y la importación de respaldos), miembro (registra y edita datos) y solo lectura (mira todo, no cambia nada). Tras 5 intentos fallidos el acceso se bloquea 1 minuto, y la app se bloquea sola tras los minutos sin uso que se elijan (1, 5, 15 o nunca). Las contraseñas y PIN se guardan como huella (hash con sal) en el almacenamiento seguro del equipo, nunca en la base ni en los respaldos. En «Usuarios» cada quien cambia su contraseña y su PIN, y el administrador agrega personas, cambia roles y restablece claves.
- **Diseño nuevo (pedido de Esteban):** botones grandes con degradados de colores en el inicio; iconos de sol y luna arriba para cambiar entre modo claro y modo oscuro (la elección queda guardada; el modo oscuro se adelantó desde la Fase 12); el botón de actualizaciones ahora tiene texto «Actualizar» y se destaca cuando hay versión nueva. Saludo con el nombre de quien entró y su rol, y botón «Salir». Al registrar un gasto, «¿Quién lo hizo?» ya viene con el nombre de quien entró.

## [0.5.2] - 2026-11-14

### Corregido
- Causa raíz encontrada gracias al registro de error: el componente de archivos compilaba contra una versión vieja de Android (34) y otro componente exige la 36. Se usa la línea 10 del selector de archivos, que sí compila contra la versión actual. Trae todo lo de la 0.4.0 y la 0.5.0.

## [0.5.1] - 2026-11-14

### Corregido
- La compilación de Android falló en GitHub con el selector de archivos nuevo (file_picker 11, agregado para el módulo Respaldo): se cambió por la línea 8 del mismo componente, de eficacia probada, y la app lo usa igual por dentro. Sin cambios visibles para la persona: trae todo lo de la 0.4.0 y la 0.5.0.

## [0.5.0] - 2026-11-14

### Agregado
- **Actualización desde dentro de la app** (pedido por Esteban: no quiere descargar el instalador en cada versión; era la última fase del plan y se adelantó):
  - Al abrirse, la app revisa sola en GitHub si hay una versión más nueva; si la hay, muestra un aviso en el inicio y un botón en la barra superior.
  - La pantalla «Actualización» muestra la versión instalada, permite buscar a mano y, con el botón **Actualizar ahora**, descarga la versión nueva por dentro (con progreso) y la instala.
  - En **Android** abre el instalador del sistema con el APK descargado (el toque final en «Instalar» lo exige Android; la primera vez pedirá el permiso de instalación, una sola vez).
  - En **Windows** descarga el paquete, se cierra un momento, se reemplaza sola con un ayudante y se vuelve a abrir ya actualizada.
  - Los datos nunca se tocan al actualizar: solo cambia el programa.
- Permisos de Android nuevos: internet (para revisar y descargar) y solicitar instalación de paquetes.

### Notas
- Esta versión se instala a mano **por última vez**: las anteriores no traen el botón de actualización. De aquí en adelante, las versiones llegan desde la propia app.

## [0.4.0] - 2026-11-14

### Agregado
- **Módulo «Respaldo»** (pedido por Esteban tras probar la app): exportar TODOS los datos (gastos, categorías y fijos) a **un solo archivo** e importarlo en otro equipo, en los dos sentidos (Windows → Android y Android → Windows), sin volver a ingresar nada a mano.
- Como eligió Esteban, el archivo es **simple, sin clave**: se pasa por WhatsApp, cable, correo o Drive como cualquier archivo.
- Al importar, la app avisa cuántos datos trae el archivo y pide confirmación, porque **reemplaza todo** lo que haya en el equipo destino (es para migrar, no para mezclar dos equipos).
- Si el archivo no es un respaldo válido, la app lo rechaza **sin tocar ningún dato** (revisión completa antes de reemplazar, con prueba automática).

### Notas
- La sincronización automática en la nube (sin archivos) sigue en su fase posterior; este módulo cubre la migración manual entre equipos.

## [0.3.0] - 2026-11-14

### Agregado
- **Módulo «Fijos del mes»** (pedido por Esteban tras probar la v0.2.0; adelanta parte de las fases de recurrentes e ingresos): dos tablas tipo Excel —gastos fijos e ingresos fijos— con nombre, descripción, valor y día del mes en que se repite cada uno.
- Cada tabla cierra con su **TOTAL**, y abajo el resultado **UTILIDAD / DEUDA = ingresos − gastos**, en verde si sobra y en rojo si falta.
- Agregar, editar y eliminar fijos (con «Deshacer» al eliminar), desde un botón nuevo en la pantalla de inicio.
- Nueva tabla `fijos` en la base de datos (versión de esquema 2); la migración desde la versión 1 conserva todos los datos, con prueba automática que lo verifica.

### Notas
- Los fijos son el tablero de planeación del mes: todavía no generan gastos solos ni avisan; los recordatorios y el «marcar como pagado» llegan con la fase de recurrentes.

## [0.2.0] - 2026-11-14

### Agregado
- Fase 1: la app ya funciona. Base de datos local **cifrada** (SQLite3MultipleCiphers, AES-256; la llave vive en el almacenamiento seguro del equipo).
- Las 8 categorías iniciales de Esteban, con color e ícono; se pueden crear, editar y ocultar (eliminar solo si no tienen gastos).
- Registro manual de gastos en pocos toques: monto, categoría, descripción, quién lo hizo, fecha y método de pago. Editar tocando un gasto; eliminar pide confirmación y ofrece «Deshacer».
- Pantalla de inicio con el total de gastos del mes y los últimos gastos.
- Configuración multimoneda lista en un solo archivo (`lib/src/core/monedas/monedas.dart`): COP, ARS, MXN, UYU, PEN y USD. El selector de moneda llega en la Fase 4.
- Textos de la app en archivo de traducciones (`lib/l10n/app_es.arb`).
- Pruebas automáticas: 13 (monedas, base de datos, cifrado real y pantalla de inicio).
- Publicación automática: cada versión nueva se compila para Android y Windows y se publica en GitHub Releases (`.github/workflows/publicar.yml`).

### Notas
- La versión de Windows se compila en GitHub (las máquinas de desarrollo son Linux) y la de Android también queda en Releases; ambas salen del mismo código.

## [0.1.0] - 2026-11-14

### Agregado
- Fase 0: decisiones de tecnología y arquitectura (`docs/arquitectura.md`).
- Estructura del proyecto definida y plan de fases en el `README.md`.
- Guía de instalación en PC en lenguaje sencillo (`docs/guia-instalacion-pc.md`).
- Base del repositorio: `README.md`, `.gitignore` y este historial.
