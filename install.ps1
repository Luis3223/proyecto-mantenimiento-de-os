<#
.SYNOPSIS
    Instalador Oficial de Win-Optimizador Pro v2.0
    Instala la suite permanentemente en el sistema, registra accesos en el Menú Inicio,
    crea iconos en el Escritorio, añade el comando a PATH y registra en Programas y Características.
#>

# 1. Elevación a Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
Write-Host "│       INSTALADOR OFICIAL DE WIN-OPTIMIZADOR PRO v2.0                     │" -ForegroundColor Cyan
Write-Host "│       Suite Integral de Mantenimiento y Rendimiento para Windows         │" -ForegroundColor White
Write-Host "╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan
Write-Host ""

$installDir = "C:\Program Files\WinOptimizador"
$sourceDir = Split-Path -Parent $PSCommandPath

Write-Host "[1/5] Preparando directorio de instalación..." -ForegroundColor Cyan
if (-not (Test-Path $installDir)) {
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}
Write-Host "  ✔ Directorio destino: $installDir" -ForegroundColor Green

Write-Host "[2/5] Copiando archivos de la suite..." -ForegroundColor Cyan

# Copiar scripts y batch launchers
$archivos = @(
    "winoptimizador.ps1",
    "winoptimizador_gui.ps1",
    "Iniciar-WinOptimizador.bat",
    "WinOptimizador-Grafico.bat",
    "WinOptimizador-Tecnico.bat",
    "LICENSE",
    "README.md"
)

foreach ($a in $archivos) {
    $origen = Join-Path $sourceDir $a
    if (Test-Path $origen) {
        Copy-Item -Path $origen -Destination $installDir -Force
        Write-Host "  ✔ Archivo instalado: $a" -ForegroundColor DarkGray
    }
}

# Copiar carpeta gui completa
$origenGui = Join-Path $sourceDir "gui"
$destGui = Join-Path $installDir "gui"
if (Test-Path $origenGui) {
    if (-not (Test-Path $destGui)) { New-Item -ItemType Directory -Path $destGui -Force | Out-Null }
    Copy-Item -Path "$origenGui\*" -Destination $destGui -Recurse -Force
    Write-Host "  ✔ Módulos de interfaz gráfica web copiados con éxito." -ForegroundColor DarkGray
}

# Crear shims de línea de comandos en la carpeta de instalación
$shimCli = "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -File `"%~dp0winoptimizador.ps1`" %*"
[System.IO.File]::WriteAllText((Join-Path $installDir "winoptimizador.cmd"), $shimCli, [System.Text.Encoding]::ASCII)

$shimGui = "@echo off`r`npowershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"%~dp0winoptimizador_gui.ps1`" %*"
[System.IO.File]::WriteAllText((Join-Path $installDir "winoptimizador-gui.cmd"), $shimGui, [System.Text.Encoding]::ASCII)

Write-Host "[3/5] Generando accesos directos..." -ForegroundColor Cyan
$ws = New-Object -ComObject WScript.Shell

# Acceso directo en el Escritorio
$desktopPath = [Environment]::GetFolderPath("Desktop")
$scDesktop = $ws.CreateShortcut((Join-Path $desktopPath "Win-Optimizador Pro.lnk"))
$scDesktop.TargetPath = Join-Path $installDir "WinOptimizador-Grafico.bat"
$scDesktop.WorkingDirectory = $installDir
$scDesktop.Description = "Suite de Mantenimiento y Optimización de Windows"
$scDesktop.IconLocation = "shell32.dll,238"
$scDesktop.Save()
Write-Host "  ✔ Acceso en el Escritorio creado con éxito." -ForegroundColor Green

# Acceso directo en el Menú Inicio
$startMenuDir = Join-Path ([Environment]::GetFolderPath("CommonPrograms")) "Win-Optimizador Pro"
if (-not (Test-Path $startMenuDir)) { New-Item -ItemType Directory -Path $startMenuDir -Force | Out-Null }

$scStartGui = $ws.CreateShortcut((Join-Path $startMenuDir "Win-Optimizador Pro.lnk"))
$scStartGui.TargetPath = Join-Path $installDir "WinOptimizador-Grafico.bat"
$scStartGui.WorkingDirectory = $installDir
$scStartGui.Description = "Suite de Mantenimiento y Optimización de Windows (Modo Gráfico)"
$scStartGui.IconLocation = "shell32.dll,238"
$scStartGui.Save()

$scStartCli = $ws.CreateShortcut((Join-Path $startMenuDir "Win-Optimizador Técnico (Consola).lnk"))
$scStartCli.TargetPath = Join-Path $installDir "WinOptimizador-Tecnico.bat"
$scStartCli.WorkingDirectory = $installDir
$scStartCli.Description = "Suite de Mantenimiento y Diagnóstico Técnico por Terminal TUI"
$scStartCli.IconLocation = "imageres.dll,-109"
$scStartCli.Save()
Write-Host "  ✔ Accesos agregados al Menú Inicio de Windows." -ForegroundColor Green

Write-Host "[4/5] Añadiendo a la variable de entorno PATH del sistema..." -ForegroundColor Cyan
try {
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if ($currentPath -notlike "*$installDir*") {
        $newPath = "$currentPath;$installDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
        Write-Host "  ✔ Comando 'winoptimizador' y 'winoptimizador-gui' registrado globalmente en CMD y PowerShell." -ForegroundColor Green
    } else {
        Write-Host "  ✔ La ruta ya se encuentra en PATH." -ForegroundColor DarkGray
    }
} catch {
    Write-Host "  [!] Aviso: No se pudo modificar el PATH del sistema: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "[5/5] Registrando en Panel de Control (Programas y Características)..." -ForegroundColor Cyan
$regKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\WinOptimizadorPro"
try {
    if (-not (Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
    Set-ItemProperty -Path $regKey -Name "DisplayName" -Value "Win-Optimizador Pro v2.0"
    Set-ItemProperty -Path $regKey -Name "DisplayVersion" -Value "2.0.0"
    Set-ItemProperty -Path $regKey -Name "Publisher" -Value "Luis3223"
    Set-ItemProperty -Path $regKey -Name "InstallLocation" -Value $installDir
    Set-ItemProperty -Path $regKey -Name "UninstallString" -Value "`"$installDir\Desinstalar-WinOptimizador.bat`""
    Set-ItemProperty -Path $regKey -Name "DisplayIcon" -Value "shell32.dll,238"
    Write-Host "  ✔ Registrado correctamente en Aplicaciones instaladas de Windows." -ForegroundColor Green
} catch {
    Write-Host "  [!] Aviso al escribir en registro: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Copiar desinstaladores en el directorio de instalación
$uninstPs1 = Join-Path $sourceDir "uninstall.ps1"
if (Test-Path $uninstPs1) {
    Copy-Item -Path $uninstPs1 -Destination $installDir -Force
}

$uninstBat = Join-Path $sourceDir "Desinstalar-WinOptimizador.bat"
if (Test-Path $uninstBat) {
    Copy-Item -Path $uninstBat -Destination $installDir -Force
}

Write-Host ""
Write-Host "╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
Write-Host "│  🎉 ¡INSTALACIÓN COMPLETADA EXITOSAMENTE!                                │" -ForegroundColor Green
Write-Host "├──────────────────────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
Write-Host "│  • Abre 'Win-Optimizador Pro' directamente desde tu Menú Inicio.         │" -ForegroundColor White
Write-Host "│  • Acceso directo disponible en tu Escritorio.                           │" -ForegroundColor White
Write-Host "│  • Técnicos: Puedes ejecutar 'winoptimizador' en cualquier consola.      │" -ForegroundColor Yellow
Write-Host "╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan
Write-Host ""
