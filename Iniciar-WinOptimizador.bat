@echo off
:: ==============================================================================
:: Lanzador Rapido para Win-Optimizador Pro
:: Eleva permisos a Administrador y ejecuta la Interfaz Grafica (GUI)
:: ==============================================================================
title Lanzador Win-Optimizador Pro

fltmc >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0winoptimizador_gui.ps1"

