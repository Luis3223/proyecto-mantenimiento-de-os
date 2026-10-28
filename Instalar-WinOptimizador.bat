@echo off
:: ==============================================================================
:: Win-Optimizador Pro v2.0 - Instalador en 1-Clic
:: Instala la suite en Program Files, crea accesos en Menú Inicio, Escritorio y PATH
:: ==============================================================================
title Instalando Win-Optimizador Pro...

fltmc >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"

echo.
echo Presione cualquier tecla para finalizar...
pause >nul
