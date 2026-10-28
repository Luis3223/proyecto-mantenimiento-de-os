@echo off
:: ==============================================================================
:: Win-Optimizador Pro - Modo Gráfico para Todo Usuario
:: Abre directamente la interfaz visual moderna sin pantallas negras de fondo
:: ==============================================================================
title Win-Optimizador Pro

fltmc >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0winoptimizador_gui.ps1"
