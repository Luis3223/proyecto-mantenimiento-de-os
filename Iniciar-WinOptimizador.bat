@echo off
:: ==============================================================================
:: Suite Win-Optimizador Pro - Lanzador Maestro
:: Eleva permisos de Administrador y permite elegir el entorno de trabajo
:: ==============================================================================
title Win-Optimizador Pro - Seleccion de Modo

fltmc >nul 2>&1
if errorlevel 1 (
    powershell -Command "Start-Process cmd -ArgumentList '/c \"\"%~f0\"\"' -Verb RunAs"
    exit /b
)

cd /d "%~dp0"
cls
echo ==============================================================================
echo                       WIN-OPTIMIZADOR PRO v2.0
echo             Suite de Mantenimiento y Optimizacion de Windows
echo ==============================================================================
echo.
echo   Elija el modo de interfaz que desea utilizar:
echo.
echo   [1] Modo Tecnico (Terminal TUI Interactiva con Flechas y Teclado)
echo       - Ideal para administradores, soporte tecnico y diagnosticos rapidos.
echo.
echo   [2] Modo Usuario (Interfaz Grafica Visual con Tarjetas y Modo 1-Clic)
echo       - Ideal para cualquier usuario: interfaz moderna, amigable y asistida.
echo.
echo   [3] Instalar en el Equipo (Menu Inicio, Escritorio y Comando Global)
echo       - Instala la aplicacion permanentemente en su sistema Windows.
echo.
echo ==============================================================================
set /p modo="Seleccione (1, 2 o 3, por defecto [2]): "
if "%modo%"=="1" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0winoptimizador.ps1"
) else if "%modo%"=="3" (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0winoptimizador_gui.ps1"
)
