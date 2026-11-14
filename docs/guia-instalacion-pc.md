# Guía de instalación en tu PC — en cristiano

Esta guía tiene **dos niveles**. Lee solo el que necesites:

- **Nivel A — Solo quiero USAR la app.** No instalas nada de programación. Es el nivel para ti y tu familia.
- **Nivel B — Quiero ver el código o probar versiones en construcción en mi PC.** Solo si te da curiosidad o quieres ayudar a probar.

---

## Nivel A: usar la app (sin programar nada)

### En Windows

1. Entra a la página del proyecto y abre la sección **Releases** (versiones publicadas).
2. Descarga el archivo instalador de Windows (termina en `.exe` o `.msi`).
3. Hazle doble clic y sigue el asistente («Siguiente» hasta terminar). Si Windows muestra un aviso de seguridad porque la app es nueva y no viene de la tienda, elige «Más información» → «Ejecutar de todas formas».
4. Abre la app desde el menú Inicio. Listo.

> Las versiones publicadas (Releases) llegan con la **Fase 10**. Durante el desarrollo, Esteban recibirá los archivos de prueba directamente en el chat.

### En Android

1. Descarga el archivo `.apk` desde **Releases** (o el que te pasen por el chat).
2. Al abrirlo, el teléfono pedirá permiso para «instalar apps desconocidas» desde el navegador o la app de archivos. Actívalo **una sola vez**: Ajustes → Seguridad → Instalar apps desconocidas → elige tu navegador/archivos → Permitir.
3. Vuelve al archivo y toca **Instalar**.
4. Abre la app. Listo: las próximas actualizaciones se podrán hacer desde dentro de la propia app (Fase 10).

**Tus datos no se borran al actualizar:** la información vive aparte del programa.

---

## Nivel B: preparar tu PC para ver el código y probar (opcional)

Solo necesitas esto si quieres abrir el proyecto, leer el código o compilar la app tú mismo en tu PC con Windows. Todo es gratuito.

### 1. Git (para descargar el proyecto y recibir cambios)

- Descarga **Git for Windows** desde git-scm.com y instálalo aceptando las opciones por defecto.
- Comprobación: abre «Símbolo del sistema» y escribe `git --version`. Debe mostrar un número de versión.

### 2. Flutter (el kit con el que se construye la app)

- Descarga el SDK de Flutter para Windows desde docs.flutter.dev y descomprímelo en una carpeta simple, por ejemplo `C:\flutter` (evita `Archivos de programa`).
- Agrega `C:\flutter\bin` a la variable PATH de Windows (busca «variables de entorno» en el menú Inicio).
- Comprobación: en una ventana nueva de «Símbolo del sistema», escribe `flutter --version`.

### 3. Visual Studio 2022 (solo para compilar la versión de Windows)

- Descarga **Visual Studio Community 2022** (gratis) desde visualstudio.microsoft.com.
- En el instalador marca la carga de trabajo **«Desarrollo para el escritorio con C++»**. Sin esto, la app de Windows no compila; la de Android sí.

### 4. Android Studio (solo para compilar/probar la versión de Android en el PC)

- Descarga **Android Studio** desde developer.android.com y instálalo con su asistente (incluye el SDK de Android y permite crear un teléfono virtual/emulador).

### 5. Editor recomendado

- **Visual Studio Code** con la extensión **Flutter**: más liviano que Android Studio para el día a día.

### 6. Verificación final

Con todo instalado, escribe en «Símbolo del sistema»:

```
flutter doctor
```

Ese comando revisa tu PC y te dice, con ✔ y ✘, qué quedó bien y qué falta. Lo ideal es que Flutter, Android y Visual Studio salgan con ✔.

### Tiempos y espacio aproximados

- Descargas totales: unos **8–12 GB** (lo más pesado es Visual Studio y Android Studio).
- Espacio libre recomendado en disco: **20 GB**.
- Tiempo total con buen internet: **1 a 2 horas**, la mayoría esperando descargas.

> Repito lo importante: **nada del Nivel B es obligatorio para usar la app.** Las versiones oficiales las compila GitHub automáticamente; tú solo instalas el resultado.
