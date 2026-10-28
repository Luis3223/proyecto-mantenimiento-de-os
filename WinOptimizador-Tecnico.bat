@echo off
:: ==============================================================================
:: Win-Optimizador Pro - Modo Técnico (Terminal TUI)
:: Abre directamente la suite interactiva de terminal con controles de teclado
:: ==============================================================================
title Win-Optimizador Pro - Modo Tecnico

fltmc >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0winoptimizador.ps1"
