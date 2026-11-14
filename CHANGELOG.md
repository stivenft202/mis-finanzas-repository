# Historial de cambios

Todos los cambios importantes de la app, versión por versión.
Formato basado en «Keep a Changelog», con versionado semántico.

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
