@echo off
:: ==============================================================================
:: Lanzador Rapido para Win-Optimizador Pro
:: Eleva permisos a Administrador y ejecuta winoptimizador.ps1 sin restricciones
:: ==============================================================================
title Lanzador Win-Optimizador Pro

fltmc >nul 2>&1
if errorlevel 1 (
    echo [!] Solicitando permisos de Administrador...
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0winoptimizador.ps1"

pause
