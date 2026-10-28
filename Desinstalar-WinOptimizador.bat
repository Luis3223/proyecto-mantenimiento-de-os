@echo off
:: ==============================================================================
:: Win-Optimizador Pro v2.0 - Desinstalador
:: ==============================================================================
title Desinstalando Win-Optimizador Pro...

fltmc >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -Command @"
`$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not `$isAdmin) { exit }

Write-Host "`n[+] Desinstalando Win-Optimizador Pro..." -ForegroundColor Cyan

# Accesos directos
`$desktopLnk = Join-Path ([Environment]::GetFolderPath('Desktop')) 'Win-Optimizador Pro.lnk'
if (Test-Path `$desktopLnk) { Remove-Item -Path `$desktopLnk -Force -ErrorAction SilentlyContinue }

`$startMenuDir = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'Win-Optimizador Pro'
if (Test-Path `$startMenuDir) { Remove-Item -Path `$startMenuDir -Recurse -Force -ErrorAction SilentlyContinue }

# Registro
`$regKey = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\WinOptimizadorPro'
if (Test-Path `$regKey) { Remove-Item -Path `$regKey -Force -Recurse -ErrorAction SilentlyContinue }

# Quitar de PATH
try {
    `$installDir = 'C:\Program Files\WinOptimizador'
    `$currentPath = [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine)
    if (`$currentPath -like "*`$installDir*") {
        `$parts = `$currentPath -split ';' | Where-Object { `$_ -ne `$installDir -and `$_ -ne '' }
        `$newPath = `$parts -join ';'
        [Environment]::SetEnvironmentVariable('Path', `$newPath, [EnvironmentVariableTarget]::Machine)
    }
} catch {}

Write-Host '[OK] Accesos directos y registros de Windows eliminados.' -ForegroundColor Green
if (Test-Path 'C:\Program Files\WinOptimizador') {
    Start-Process cmd.exe -ArgumentList '/c timeout /t 2 /nobreak >nul & rmdir /s /q `"C:\Program Files\WinOptimizador`"' -WindowStyle Hidden
}
Write-Host '`n¡Desinstalacion completada con exito!' -ForegroundColor Green
"@

echo.
echo Presione cualquier tecla para salir...
pause >nul
