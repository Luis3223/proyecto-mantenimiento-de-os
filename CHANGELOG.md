# 📜 Registro de Cambios (Changelog) — Win-Optimizador Pro

Todas las modificaciones notables realizadas a este proyecto se documentan en este archivo.  
El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/) y sigue el Versionado Semántico [SemVer](https://semver.org/lang/es/).

---

## [2.0.0] - 2026-10-28

### 🚀 Nuevas Características
- **Arquitectura Dual (Técnica y No Técnica):**
  - **Modo Técnico (TUI en Consola):** Terminal interactiva completa con navegación por flechas de teclado (`↑`, `↓`, `←`, `→`, `Tab`), pestañas temáticas, telemetría en vivo (CPU, RAM, Disco) y retroalimentación estilizada.
  - **Modo Usuario (GUI Web Nativa):** Interfaz moderna y fluida desarrollada con HTML5, CSS3 Vanilla y JavaScript moderno, renderizada en una ventana independiente nativa mediante Microsoft Edge App Mode (`--app`), sin necesidad de frameworks pesados como Electron.
- **Módulo 23: Analizador y Liberador de Archivos Pesados en Disco:**
  - Detección ultrarrápida (<300 ms) de archivos grandes (>10MB) en directorios de usuario (`Descargas`, `Videos`, `Escritorio`, `Documentos`, `Temp`).
  - Lista interactiva con casillas de verificación, tipos de archivo, nombres legibles, ubicaciones completas y distintivos de peso en MB/GB.
  - Cálculo con precisión de bytes del espacio recuperado en disco con reporte visual de celebración.
- **Instalador Automatizado en 1 Clic (`install.ps1` / `Instalar-WinOptimizador.bat`):**
  - Despliegue en `C:\Program Files\WinOptimizador`.
  - Creación de accesos directos en el Menú Inicio y en el Escritorio con iconos nativos del sistema.
  - Inclusión de los comandos `winoptimizador` y `winoptimizador-gui` en la variable global PATH.
  - Registro en la configuración de aplicaciones de Windows para desinstalación transparente.
- **Lanzador Remoto en la Nube (`run.ps1`):**
  - Permite a técnicos remotos ejecutar o instalar la suite con una sola línea de comando en PowerShell (`irm ... | iex`) sin descargar archivos manualmente.
- **Optimizaciones de Red y Servicios (Fase 1 y Fase 2):**
  - Módulo 21: Estandarización de interfaz a DHCP dinámico para IP y DNS.
  - Módulo 22: Detención y deshabilitación optimizada del servicio Spooler de impresión.

### 🛡️ Mejoras de Rendimiento y Seguridad
- Codificación estandarizada en UTF-8 con BOM en todos los scripts de PowerShell para compatibilidad total con Windows PowerShell 5.1 y PowerShell 7+.
- Elevación automática de privilegios a Administrador con prompt UAC transparente.
- Cero dependencias externas: no requiere Node.js, Python ni compiladores.

---

## [1.0.0] - Versión Inicial

### ✨ Características Base
- Menú básico por opciones numéricas en consola PowerShell.
- Purga de temporales, vaciado de papelera de reciclaje y vaciado de caché DNS.
- Comprobación de disco con CHKDSK y reparación de archivos protegidos con SFC.
- Punto de restauración del sistema y monitor de recursos Top 5.
