# Historial de cambios

Todos los cambios importantes de la app, versión por versión.
Formato basado en «Keep a Changelog», con versionado semántico.

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
