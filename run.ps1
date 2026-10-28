<#
.SYNOPSIS
    Win-Optimizador Pro v2.0 - Lanzador e Instalador Remoto en la Nube
    Permite ejecutar la suite o instalarla de forma permanente con un solo comando en PowerShell.
#>
param(
    [ValidateSet("GUI", "TUI", "Install", "Auto")]
    [string]$Modo = "Auto"
)

# 1. Elevar a Administrador si es necesario
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] Solicitando elevacion de permisos de Administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"& { irm https://raw.githubusercontent.com/Luis3223/proyecto-mantenimiento-de-os/main/run.ps1 | iex } -Modo '$Modo'`"" -Verb RunAs
    Exit
}

$repoBase = "https://raw.githubusercontent.com/Luis3223/proyecto-mantenimiento-de-os/main"

# 2. Menú de Selección si se ejecuta en modo Auto
if ($Modo -eq "Auto") {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "       WIN-OPTIMIZADOR PRO v2.0 - LANZADOR REMOTO EN LA NUBE          " -ForegroundColor White -BackgroundColor DarkBlue
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [1] Modo Tecnico   (Terminal TUI Interactiva con Teclas de Flechas)" -ForegroundColor Cyan
    Write-Host "  [2] Modo Usuario   (Ventana Grafica Moderna con Tarjetas y Modo 1-Clic)" -ForegroundColor Green
    Write-Host "  [3] Instalar Suite (Instalacion permanente en Menu Inicio, Escritorio y PATH)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "======================================================================" -ForegroundColor Cyan
    $eleccion = Read-Host "Seleccione una opcion (1, 2 o 3, por defecto [2])"
    if ($eleccion -eq "1") {
        $Modo = "TUI"
    } elseif ($eleccion -eq "3") {
        $Modo = "Install"
    } else {
        $Modo = "GUI"
    }
}

$tempDir = Join-Path $env:TEMP "WinOptimizadorPro"
if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }

if ($Modo -eq "TUI") {
    Write-Host "`n[+] Descargando y preparando Modo Tecnico..." -ForegroundColor Cyan
    $scriptUrl = "$repoBase/winoptimizador.ps1"
    $localFile = Join-Path $tempDir "winoptimizador.ps1"
    Invoke-WebRequest -Uri $scriptUrl -OutFile $localFile -UseBasicParsing
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $localFile
} elseif ($Modo -eq "GUI") {
    Write-Host "`n[+] Descargando y preparando Modo Grafico..." -ForegroundColor Cyan
    $guiDir = Join-Path $tempDir "gui"
    if (-not (Test-Path $guiDir)) { New-Item -ItemType Directory -Path $guiDir -Force | Out-Null }
    
    $scriptUrl = "$repoBase/winoptimizador_gui.ps1"
    $localFile = Join-Path $tempDir "winoptimizador_gui.ps1"
    Invoke-WebRequest -Uri $scriptUrl -OutFile $localFile -UseBasicParsing
    
    Invoke-WebRequest -Uri "$repoBase/gui/index.html" -OutFile (Join-Path $guiDir "index.html") -UseBasicParsing
    Invoke-WebRequest -Uri "$repoBase/gui/style.css" -OutFile (Join-Path $guiDir "style.css") -UseBasicParsing
    Invoke-WebRequest -Uri "$repoBase/gui/app.js" -OutFile (Join-Path $guiDir "app.js") -UseBasicParsing
    
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $localFile
} elseif ($Modo -eq "Install") {
    Write-Host "`n[+] Descargando paquete completo de instalacion..." -ForegroundColor Yellow
    $guiDir = Join-Path $tempDir "gui"
    if (-not (Test-Path $guiDir)) { New-Item -ItemType Directory -Path $guiDir -Force | Out-Null }

    $archivos = @(
        "winoptimizador.ps1",
        "winoptimizador_gui.ps1",
        "install.ps1",
        "Iniciar-WinOptimizador.bat",
        "WinOptimizador-Grafico.bat",
        "WinOptimizador-Tecnico.bat",
        "LICENSE",
        "README.md"
    )

    foreach ($a in $archivos) {
        Invoke-WebRequest -Uri "$repoBase/$a" -OutFile (Join-Path $tempDir $a) -UseBasicParsing
    }
    Invoke-WebRequest -Uri "$repoBase/gui/index.html" -OutFile (Join-Path $guiDir "index.html") -UseBasicParsing
    Invoke-WebRequest -Uri "$repoBase/gui/style.css" -OutFile (Join-Path $guiDir "style.css") -UseBasicParsing
    Invoke-WebRequest -Uri "$repoBase/gui/app.js" -OutFile (Join-Path $guiDir "app.js") -UseBasicParsing

    Write-Host "[+] Ejecutando instalador en el sistema..." -ForegroundColor Green
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $tempDir "install.ps1")
}
