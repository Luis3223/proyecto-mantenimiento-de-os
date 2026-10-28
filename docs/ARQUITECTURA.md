# 📘 Arquitectura Técnica y Manual de Mantenimiento

Este documento detalla el funcionamiento interno de cada módulo implementado en **Win-Optimizador Pro** y la estrategia de **Doble Interfaz Adaptativa** (`winoptimizador.ps1` y `winoptimizador_gui.ps1`).

---

## 1. Arquitectura de Doble Interfaz (Técnico vs Usuario)

Para garantizar accesibilidad tanto a personal IT especializado como a usuarios convencionales, la suite desacopla el motor de ejecución en dos capas de presentación:

1. **Capa TUI (Terminal User Interface - `winoptimizador.ps1`)**:
   - Orientada a administradores de sistemas y entornos de diagnóstico rápido.
   - Bucle interactivo sin recarga completa mediante `$Host.UI.RawUI.ReadKey` y posicionamiento de cursor.
   - Consumo de recursos mínimo y soporte para 100% navegación con teclado (`↑/↓`, `←/→`, `Tab`, `Enter`).
   - Monitor de telemetría superior en vivo (UAC, Disco C: y RAM física).

2. **Capa GUI (Interfaz Gráfica Fluent - `winoptimizador_gui.ps1`)**:
   - Orientada a cualquier usuario final sin conocimientos de comandos.
   - Construida sobre `System.Windows.Forms` y `System.Drawing` con diseño asíncrono y paleta Fluent Dark (`#0B132B`, `#0F172A`, `#1E293B`).
   - Navegación lateral por categorías (Sidebar) con tarjetas explicativas que evitan el desbordamiento o corte de botones.
   - "Modo 1-Clic" asistido para mantenimiento rápido desatendido.

3. **Capa de Despliegue Remoto (`run.ps1`)**:
   - Permite ejecución en 1 línea (`irm ... | iex`) descargando los componentes en memoria temporal (`$env:TEMP\WinOptimizadorPro`) sin requerir instalación previa.

---

## 2. Mecanismo de Auto-Elevación (UAC)

El script implementa una verificación inicial de seguridad en tiempo de ejecución:

```powershell
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
```

- **Objetivo**: Garantizar que todas las operaciones de bajo nivel (manipulación del catálogo de servicios, DISM, SFC, Registro y volumen) dispongan del Token de Seguridad de Administrador.
- **Transparencia**: Si el usuario lo ejecuta sin privilegios, se invoca un subproceso con `-Verb RunAs` provocando el diálogo del Control de Cuentas de Usuario (UAC).

---

## 2. Clasificación de Módulos

```
                   ┌── [1-5, 23] Limpieza de Temporales, Logs y Archivos Pesados
                   ├── [6-8] Optimización y Organización
                   ├── [9-10] Pila de Red TCP/IP y DNS
WinOptimizador ────┼── [11-14] Reparación DISM / SFC / CHKDSK
                   ├── [15-20] Seguridad, Telemetría y Monitoreo
                   └── [21-22] Automatización DHCP y Servicios
```

### 🧹 Limpieza y Optimización del Espacio
- **Módulo 1 (`Temp / Prefetch`)**: Libera espacio ocupado por archivos temporales de usuario y cachés de pre-carga del sistema.
- **Módulo 3 (`SoftwareDistribution`)**: Detiene de forma segura el servicio `wuauserv` para vaciar instaladores descargados pendientes que puedan estar corruptos.
- **Módulos 7 y 8 (`Organización Inteligente`)**: Automatizan la clasificación de carpetas críticas agrupando los ficheros en carpetas según su extensión `.pdf`, `.exe`, `.docx`, etc.
- **Módulo 23 (`Archivos Pesados`)**: Escanea archivos que más espacio ocupan en disco (>10MB), permite selección granular de cuáles borrar y calcula de forma byte-exacta el espacio liberado en MB/GB con telemetría en vivo.

### 🌐 Conectividad y Red
- **Módulo 9 (`DNS Flush & Renew`)**: Limpia el resolver cache local y fuerza la renegociación de direcciones IP ante el servidor DHCP.
- **Módulo 10 (`Winsock Reset`)**: Restaura el catálogo de WinSock (Windows Sockets API) a valores de fábrica, útil frente a bloqueos por malware o firewalls defectuosos.

### 🩺 Diagnóstico e Integridad
- **Módulo 11 (`SFC`)**: Audita la base de datos de firmas digitales de archivos DLL y SYS.
- **Módulo 12 (`DISM`)**: Restaura el almacén de componentes de Windows (`WinSxS`) conectándose a los servidores de Windows Update.
- **Módulo 13 (`CHKDSK`)**: Ejecuta un análisis de metadatos en la partición `C:` para detectar sectores defectuosos sin desmontar el volumen.

### ⚙️ Automatización de Red y Servicios (Fase 1 y Fase 2)
- **Módulo 21 (`DHCP Standard`)**: Estandariza la tarjeta de red Wi-Fi hacia configuración dinámica automática (IP y DNS).
- **Módulo 22 (`Spooler`)**: Optimiza el consumo de memoria en equipos que no requieren soporte para impresoras físicas o virtuales.

---

## 3. Guía de Contribución

1. Mantener las opciones organizadas en bloques dentro del bloque `switch ($opcion)`.
2. Todo comando destructivo debe incluir manejo silencioso o confirmación previa para salvaguardar los datos del usuario.
3. Probar siempre en una máquina virtual o sandbox antes de enviar cambios al repositorio principal.
