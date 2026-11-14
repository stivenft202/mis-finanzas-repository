# Finanzas del Hogar

App familiar para llevar los gastos, ingresos, presupuestos y ahorros del hogar **sin cuaderno**.
100 % en español, con botones grandes, letra legible y pocos pasos por acción.
Un mismo código corre en **Android** y en **Windows (PC)**.

> Nombre provisional de trabajo: «Finanzas del Hogar». Se puede cambiar cuando Esteban lo decida.

## Qué hace la app (resumen)

- Registrar gastos a mano, **dictándolos por voz** o con **foto de la factura**.
- Gastos fijos que se generan solos (arriendo, internet, suscripciones) y recordatorios de pago.
- Presupuestos por categoría con avisos al 80 % y al 100 %.
- Ingresos y metas de ahorro con barra de progreso.
- Varias monedas (COP, ARS, MXN, UYU, PEN, USD) con conversión automática a la moneda base del hogar.
- Un «hogar» con varias personas y tres roles: Administrador, Miembro y Solo lectura.
- Funciona **sin internet**: todo se guarda primero en el dispositivo y se sincroniza cuando hay conexión.
- Exporta a Excel y PDF, y se actualiza sola desde las versiones publicadas en este repositorio.

## Tecnología (decisiones de la Fase 0)

| Pieza | Elección |
|---|---|
| Lenguaje y marco | Flutter + Dart (última versión estable) |
| Estado de la app | Riverpod |
| Base de datos local | SQLite con Drift, cifrada con SQLCipher |
| Nube (usuarios, sincronización, copias) | Firebase: Auth + Firestore + Storage |
| Tasas de cambio | ExchangeRate-API (plan abierto) + proveedor de respaldo |
| Voz en Android | Reconocimiento de voz del sistema |
| Voz en Windows | Grabación + transcripción (Whisper) — decisión final en la Fase 5 |
| OCR en Android | ML Kit |
| OCR en Windows | Tesseract |
| Compilación automática | GitHub Actions al publicar una versión (Release) |

El detalle y los motivos están en [docs/arquitectura.md](docs/arquitectura.md).

## Estructura del proyecto

```
lib/
  main.dart                Punto de entrada
  src/
    app/                   Arranque, rutas y tema (claro/oscuro)
    core/                  Monedas, base de datos, sincronización, textos
    features/
      gastos/              Registro manual, voz y foto
      ingresos/            Sueldos y otros ingresos
      categorias/          Categorías de gasto
      presupuestos/        Presupuesto mensual y alertas
      metas/               Metas de ahorro
      recordatorios/       Pagos por vencer y notificaciones
      usuarios/            Hogar, roles, PIN y seguridad
      reportes/            Inicio, comparativos y exportaciones
      ajustes/             Moneda, tema, copias y actualizaciones
  l10n/                    Todos los textos en español (archivo de traducciones)
test/                      Pruebas automáticas de cada fase
```

El esqueleto de código con esta estructura exacta se genera al abrir la **Fase 1**, para compilarlo y probarlo desde el primer día.

## Fases de entrega

Cada fase se entrega, se prueba y espera la aprobación de Esteban («listo») antes de seguir.

- [x] **Fase 0** — Stack, estructura, repositorio y guía de instalación · `v0.1.0`
- [x] **Fase 1** — Base de datos local, categorías, gastos manuales e inicio · `v0.2.0`
- [x] **Fase 2** — Módulo «Fijos del mes»: gastos e ingresos fijos en tablas con totales y utilidad/deuda en colores (pedido directo de Esteban; adelanta parte de las fases 4 y 5 originales) · `v0.3.0`
- [x] **Fase 3** — Módulo «Respaldo»: exportar e importar TODOS los datos en un solo archivo, para migrar entre Windows y Android sin reingresar nada (pedido directo de Esteban; archivo simple, sin clave) · `v0.4.0`
- [x] **Fase 4** — Actualización desde dentro de la app: la app revisa sola si hay versión nueva en GitHub, la descarga por dentro y la instala, sin descargar el instalador a mano (pedido directo de Esteban; era la última fase del plan y se adelantó) · `v0.5.1`
- [ ] **Fase 5** — Usuarios, roles, PIN y seguridad · `v0.6.0`
- [ ] **Fase 6** — Recurrentes, variables, recordatorios y notificaciones · `v0.7.0`
- [ ] **Fase 7** — Presupuestos, ingresos, metas y multimoneda · `v0.8.0`
- [ ] **Fase 8** — Registro por voz con confirmación · `v0.9.0`
- [ ] **Fase 9** — Fotos de facturas y OCR · `v0.10.0`
- [ ] **Fase 10** — Búsqueda de precios por internet · `v0.11.0`
- [ ] **Fase 11** — Sincronización en la nube y copias de seguridad · `v0.12.0`
- [ ] **Fase 12** — Exportación a Excel/PDF y modo oscuro · `v0.13.0`
- [ ] **Fase 13** — Empaquetado final · `v1.0.0`

## Versionado

Versiones semánticas `MAYOR.MENOR.PARCHE`. Durante el desarrollo por fases, cada fase sube el número MENOR; la primera versión completa para la familia será la `1.0.0`. Los cambios de cada versión quedan en [CHANGELOG.md](CHANGELOG.md).

## Instalar en tu PC

Para **usar** la app no necesitas instalar nada de programación: basta el APK (Android) o el instalador (Windows) de la sección *Releases*. La guía completa, en lenguaje sencillo, está en [docs/guia-instalacion-pc.md](docs/guia-instalacion-pc.md).

## Privacidad

Este repositorio es **público**: cualquiera puede ver el *código*, y eso es lo que permite que la app descargue actualizaciones sin pedir claves. Los **datos del hogar nunca viven aquí**: quedan en los dispositivos y en la nube privada del proyecto (Firebase), protegidos por usuario y contraseña.
