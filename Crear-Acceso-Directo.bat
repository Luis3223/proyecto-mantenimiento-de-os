@echo off
:: ==============================================================================
:: Creador de Acceso Directo en el Escritorio para Win-Optimizador Pro
:: ==============================================================================
title Creando Acceso Directo...
cd /d "%~dp0"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws = New-Object -ComObject WScript.Shell; $sc = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Win-Optimizador Pro.lnk'); $sc.TargetPath = '%~dp0WinOptimizador-Grafico.bat'; $sc.WorkingDirectory = '%~dp0'; $sc.Description = 'Suite de Mantenimiento y Optimizacion de Windows'; $sc.IconLocation = 'shell32.dll,238'; $sc.Save(); Write-Host '¡Acceso directo creado con éxito en tu Escritorio!' -ForegroundColor Green"

echo.
echo Presione cualquier tecla para finalizar...
pause >nul
