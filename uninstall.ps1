<#
.SYNOPSIS
    Desinstalador Oficial de Win-Optimizador Pro v2.0
    Elimina accesos directos, registros del sistema y desinstala la aplicación.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Clear-Host
Write-Host "╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
Write-Host "│       DESINSTALADOR OFICIAL DE WIN-OPTIMIZADOR PRO v2.0                  │" -ForegroundColor Cyan
Write-Host "╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan
Write-Host ""
Write-Host "[+] Desinstalando Win-Optimizador Pro de su equipo..." -ForegroundColor Cyan

# 1. Eliminar acceso directo del Escritorio
$desktopLnk = Join-Path ([Environment]::GetFolderPath("Desktop")) "Win-Optimizador Pro.lnk"
if (Test-Path $desktopLnk) {
    Remove-Item -Path $desktopLnk -Force -ErrorAction SilentlyContinue
    Write-Host "  ✔ Acceso directo en el Escritorio eliminado." -ForegroundColor Green
}

# 2. Eliminar entrada en Menú Inicio
$startMenuDir = Join-Path ([Environment]::GetFolderPath("CommonPrograms")) "Win-Optimizador Pro"
if (Test-Path $startMenuDir) {
    Remove-Item -Path $startMenuDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "  ✔ Acceso en el Menú Inicio eliminado." -ForegroundColor Green
}

# 3. Eliminar registro de Windows (Apps y características)
$regKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\WinOptimizadorPro"
if (Test-Path $regKey) {
    Remove-Item -Path $regKey -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "  ✔ Registro de desinstalación de Windows purgado." -ForegroundColor Green
}

# 4. Eliminar de PATH del sistema
try {
    $installDir = "C:\Program Files\WinOptimizador"
    $currentPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)
    if ($currentPath -like "*$installDir*") {
        $parts = $currentPath -split ";" | Where-Object { $_ -ne $installDir -and $_ -ne "" }
        $newPath = $parts -join ";"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
        Write-Host "  ✔ Comandos de consola removidos de la variable PATH." -ForegroundColor Green
    }
} catch {}

# 5. Borrado de carpeta de instalación
Write-Host ""
Write-Host "╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
Write-Host "│  🎉 ¡DESINSTALACIÓN COMPLETADA EXITOSAMENTE!                             │" -ForegroundColor Green
Write-Host "╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan

if (Test-Path "C:\Program Files\WinOptimizador") {
    Start-Process cmd.exe -ArgumentList "/c timeout /t 2 /nobreak >nul & rmdir /s /q `"C:\Program Files\WinOptimizador`"" -WindowStyle Hidden
}
