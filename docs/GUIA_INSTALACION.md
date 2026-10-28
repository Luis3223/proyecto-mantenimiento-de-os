# 📖 Guía Completa de Instalación y Despliegue — Win-Optimizador Pro v2.0

Esta guía explica detalladamente todas las formas disponibles para desplegar, instalar o utilizar **Win-Optimizador Pro** en cualquier equipo con Windows 10 u 11, adaptándose a las necesidades tanto de **técnicos de soporte y administradores de sistemas**, como de **usuarios sin conocimientos técnicos**.

---

## 🧭 Tabla Comparativa de Métodos de Uso

| Método | Destinado a | ¿Requiere Descargar ZIP? | Instalación Permanente | Tiempo de Puesta en Marcha |
|---|---|:---:|:---:|:---:|
| **⚡ 1. Ejecución Remota (1-Línea)** | Técnicos, Soporte Remoto (AnyDesk/TeamViewer) | ❌ No | Opcional | **3 segundos** |
| **📦 2. Instalador Asistido** | Usuarios finales que desean la app fija | ✔️ Sí | ✔️ Sí (Menú Inicio y Escritorio) | **10 segundos** |
| **💼 3. Modo Portable (USB)** | Técnicos de campo, talleres de informática | ✔️ Sí | ❌ No (Cero huellas) | **Instantáneo** |
| **💻 4. Repositorio Git** | Desarrolladores, SysAdmins | ✔️ Sí (`git clone`) | Opcional | **15 segundos** |

---

## ⚡ Método 1: Para Técnicos y Soporte Remoto (Sin Descargar Nada)

Si te encuentras brindando soporte a un usuario o administrando un equipo de manera remota, **no es necesario que abras un navegador, descargues archivos comprimidos ni extraigas carpetas manualmente**.

### Pasos:
1. Presiona `Windows + X` y selecciona **PowerShell (Administrador)** o **Terminal (Administrador)**.
2. Copia y pega el siguiente comando de una sola línea y presiona `Enter`:

```powershell
irm https://raw.githubusercontent.com/Luis3223/proyecto-mantenimiento-de-os/main/run.ps1 | iex
```

### Opciones Automáticas por Parámetro:
Si deseas que se inicie directamente un entorno sin pasar por el menú interactivo, utiliza:

- **Iniciar Modo Técnico (Terminal TUI) directamente:**
  ```powershell
  & { irm https://raw.githubusercontent.com/Luis3223/proyecto-mantenimiento-de-os/main/run.ps1 | iex } -Modo TUI
  ```

- **Iniciar Modo Gráfico (Ventana Asistida) directamente:**
  ```powershell
  & { irm https://raw.githubusercontent.com/Luis3223/proyecto-mantenimiento-de-os/main/run.ps1 | iex } -Modo GUI
  ```

- **Instalar la Suite permanentemente en el equipo remoto en 1 comando:**
  ```powershell
  & { irm https://raw.githubusercontent.com/Luis3223/proyecto-mantenimiento-de-os/main/run.ps1 | iex } -Modo Install
  ```

---

## 📦 Método 2: Instalador Asistido para Cualquier Usuario (1 Clic)

Recomendado para cualquier usuario que desee tener la herramienta permanentemente disponible en su computadora, con su icono en el Escritorio y en el Menú Inicio de Windows como una aplicación tradicional.

### Pasos:
1. Descarga el paquete ZIP del proyecto:
   - [Descargar ZIP de Win-Optimizador Pro](https://github.com/Luis3223/proyecto-mantenimiento-de-os/archive/refs/heads/main.zip)
2. Haz clic derecho sobre el archivo ZIP descargado y selecciona **Extraer todo...**.
3. Abre la carpeta resultante y haz doble clic sobre el archivo:
   ```text
   📦 Instalar-WinOptimizador.bat
   ```
4. Acepta el cuadro de permisos de Administrador (UAC) de Windows.
5. El instalador se encargará automáticamente de:
   - Copiar los archivos a `C:\Program Files\WinOptimizador`.
   - Crear el acceso directo en tu **Escritorio** (`Win-Optimizador Pro.lnk`).
   - Crear la entrada en el **Menú Inicio de Windows** (puedes buscarlo escribiendo `WinOptimizador`).
   - Registrar la aplicación en el **Panel de Control / Configuración de Windows** (para desinstalarlo cuando quieras).
   - Agregar el comando global `winoptimizador` y `winoptimizador-gui` para usarlo desde cualquier terminal.

---

## 💼 Método 3: Modo Portable (Ideal para Memoria USB de Soporte)

Si eres técnico de campo y visitas clientes con una memoria USB, puedes llevar la suite lista para usar en cualquier equipo sin dejar residuos ni modificar el sistema operativo del cliente.

### Pasos:
1. Copia la carpeta completa del proyecto a tu memoria USB.
2. Conecta la memoria USB al equipo que deseas optimizar.
3. Elige el modo que prefieras ejecutar según la necesidad:
   - Para abrir la interfaz visual asistida: Haz doble clic en **`WinOptimizador-Grafico.bat`**.
   - Para abrir la terminal interactiva por teclado: Haz doble clic en **`WinOptimizador-Tecnico.bat`**.
   - Para ver el selector de modos: Haz doble clic en **`Iniciar-WinOptimizador.bat`**.
   - *(Opcional)*: Para crear un acceso directo temporal en el Escritorio del cliente mientras trabajas, haz doble clic en **`Crear-Acceso-Directo.bat`**.

---

## 💻 Método 4: Para Desarrolladores y Administradores (Git Clone)

Para administradores de sistemas que deseen clonar el repositorio e integrar la suite en scripts de despliegue automatizado o repositorios internos:

```bash
# 1. Clonar el repositorio
git clone https://github.com/Luis3223/proyecto-mantenimiento-de-os.git

# 2. Ingresar al directorio
cd "proyecto-mantenimiento-de-os"

# 3. Ejecutar el instalador o modo deseado
.\Instalar-WinOptimizador.bat
```

---

## 🗑️ ¿Cómo Desinstalar la Herramienta?

Si instalaste la suite con el Método 2 y deseas retirarla de tu equipo:

1. Ve a **Configuración de Windows** ➔ **Aplicaciones** ➔ **Aplicaciones instaladas** (o Panel de Control ➔ Desinstalar un programa).
2. Localiza **Win-Optimizador Pro v2.0** y selecciona **Desinstalar**.
3. O bien, ejecuta directamente:
   ```text
   C:\Program Files\WinOptimizador\Desinstalar-WinOptimizador.bat
   ```
4. El desinstalador retirará los accesos directos del Menú Inicio y Escritorio, borrará la clave del registro de Windows y suprimirá la carpeta del programa de forma limpia y transparente.

---

## ❓ Preguntas Frecuentes y Solución de Problemas

### 1. ¿Qué hago si Windows muestra "Windows protegió su PC" (SmartScreen)?
Al ser un script administrativo en formato `.bat` descargado de Internet, el filtro SmartScreen puede mostrar una advertencia azul.  
Haz clic en **"Más información"** y luego en **"Ejecutar de todas formas"**.

### 2. ¿Por qué se requieren permisos de Administrador?
La suite realiza tareas de bajo nivel indispensables para el mantenimiento de un sistema operativo, tales como:
- Reparar archivos del sistema protegidos (`SFC /scannow`).
- Reparar la imagen de Windows (`DISM`).
- Detener y limpiar servicios del sistema (`wuauserv`, `Spooler`).
- Vaciar papelera de todas las unidades y temporales del sistema (`C:\Windows\Temp`).

### 3. ¿Requiere instalar Node.js, Python o algún software adicional?
**No, cero dependencias externas.**  
WinOptimizador funciona de forma 100% nativa con las tecnologías preinstaladas en Windows: **Windows PowerShell 5.1** y **Microsoft Edge** (para renderizar la interfaz gráfica moderna en modo aplicación independiente).
