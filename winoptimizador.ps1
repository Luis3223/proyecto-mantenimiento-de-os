<#
.SYNOPSIS
    WinOptimizador Avanzado - 22 Funcionalidades de Mantenimiento y Automatización
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

function Pausa {
    Write-Host "`nPresione cualquier tecla para volver al menu..." -ForegroundColor Yellow
    $null =$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

$salir =$false

while (-not $salir) {
    Clear-Host
    Write-Host "======================================================================" -ForegroundColor Cyan
    Write-Host "             WIN-OPTIMIZADOR PRO - 22 FUNCIONES               " -ForegroundColor White -BackgroundColor Blue
    Write-Host "======================================================================" -ForegroundColor Cyan
    
    Write-Host "`n--- LIMPIEZA Y OPTIMIZACION ---" -ForegroundColor DarkYellow
    Write-Host " 1. Limpiar Temporales y Prefetch      5. Limpiar Historial Portapapeles"
    Write-Host " 2. Vaciar Papelera de Reciclaje       6. Optimizar y Desfragmentar Discos"
    Write-Host " 3. Limpiar Cache de Windows Update    7. Organizar Escritorio Automaticamente"
    Write-Host " 4. Eliminar Archivos de Log (.log)    8. Organizar Carpeta de Descargas"

    Write-Host "`n--- RED Y CONECTIVIDAD ---" -ForegroundColor DarkYellow
    Write-Host " 9. Limpiar DNS y Renovar IP           10. Restablecer Adaptadores (Winsock)"
    
    Write-Host "`n--- DIAGNOSTICO Y REPARACION ---" -ForegroundColor DarkYellow
    Write-Host " 11. Escanear Sistema (SFC /scannow)   13. Comprobar Errores de Disco (CHKDSK)"
    Write-Host " 12. Reparar Imagen de Windows (DISM)  14. Restablecer Tienda de Windows (WSReset)"

    Write-Host "`n--- SISTEMA Y SEGURIDAD ---" -ForegroundColor DarkYellow
    Write-Host " 15. Crear Punto de Restauracion       18. Habilitar/Deshabilitar Hibernacion"
    Write-Host " 16. Mostrar Consumo de RAM y CPU      19. Deshabilitar Telemetria Basica"
    Write-Host " 17. Exportar Info del Sistema (.txt)  20. MANTENIMIENTO TOTAL (Auto-Ejecucion)"

    Write-Host "`n--- AUTOMATIZACION,CONFIGURACION DE RED ---" -ForegroundColor DarkYellow
    Write-Host " 21. Configurar Red a DHCP (Fase 1)    22. Deshabilitar Spooler (Fase 2)"

    Write-Host "`n 23. Salir del Programa" -ForegroundColor Red
    Write-Host "======================================================================" -ForegroundColor Cyan

    $opcion = Read-Host "`nSeleccione una opcion (1-23)"

    switch ($opcion) {
        '1' { 
            Write-Host "`n(+) Limpiando temporales..." -ForegroundColor Cyan
            @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object {
                if (Test-Path $_) { Remove-Item -Path "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }
            }
            Write-Host "(OK) Completado." -ForegroundColor Green; Pausa 
        }
        '2' { 
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "`n(OK) Papelera vaciada." -ForegroundColor Green; Pausa 
        }
        '3' { 
            Write-Host "`n(+) Deteniendo servicio Update y limpiando cache..." -ForegroundColor Cyan
            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
            Start-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            Write-Host "(OK) Cache de actualizaciones limpia." -ForegroundColor Green; Pausa 
        }
        '4' { 
            Write-Host "`n(+) Eliminando archivos .log antiguos..." -ForegroundColor Cyan
            Get-ChildItem -Path "C:\Windows" -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
            Write-Host "(OK) Logs eliminados." -ForegroundColor Green; Pausa 
        }
        '5' { 
            Set-Clipboard -Value $null
            Write-Host "`n(OK) Historial del portapapeles borrado." -ForegroundColor Green; Pausa 
        }
        '6' { 
            Write-Host "`n(+) Optimizando unidad C:..." -ForegroundColor Cyan
            Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue
            Write-Host "(OK) Optimizacion completada." -ForegroundColor Green; Pausa 
        }
        '7' { 
            Write-Host "`n(+) Organizando Escritorio..." -ForegroundColor Cyan
            $rutaEscritorio = [Environment]::GetFolderPath("Desktop")
            Get-ChildItem -Path $rutaEscritorio -File | Where-Object { $_.Extension -ne ".lnk" -and $_.Extension -ne "" } | ForEach-Object {
                $ext = $_.Extension.TrimStart('.')
                $dir = Join-Path $rutaEscritorio$ext
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path$dir | Out-Null }
                Move-Item $_.FullName -Destination$dir -Force
            }
            Write-Host "(OK) Escritorio organizado." -ForegroundColor Green; Pausa 
        }
        '8' { 
            Write-Host "`n(+) Organizando Descargas..." -ForegroundColor Cyan
            $rutaDescargas = Join-Path $env:USERPROFILE "Downloads"
            Get-ChildItem -Path $rutaDescargas -File | Where-Object { $_.Extension -ne "" } | ForEach-Object {
                $ext = $_.Extension.TrimStart('.')
                $dir = Join-Path $rutaDescargas $ext
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
                Move-Item $_.FullName -Destination $dir -Force
            }
            Write-Host "(OK) Descargas organizadas." -ForegroundColor Green; Pausa 
        }
        '9' { 
            ipconfig /flushdns | Out-Null; ipconfig /release | Out-Null; ipconfig /renew | Out-Null
            Write-Host "`n(OK) DNS renovado." -ForegroundColor Green; Pausa 
        }
        '10' { 
            netsh winsock reset | Out-Null
            Write-Host "`n(OK) Winsock restablecido. Se requiere reiniciar el PC." -ForegroundColor Green; Pausa 
        }
        '11' { sfc /scannow; Pausa }
        '12' { DISM /Online /Cleanup-Image /RestoreHealth; Pausa }
        '13' { 
            Write-Host "`n(+) Ejecutando CHKDSK en modo solo lectura..." -ForegroundColor Cyan
            chkdsk C: 
            Pausa 
        }
        '14' { 
            wsreset.exe
            Write-Host "`n(OK) Comando de restablecimiento enviado." -ForegroundColor Green; Pausa 
        }
        '15' { 
            Write-Host "`n(+) Creando Punto de Restauracion..." -ForegroundColor Cyan
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            Checkpoint-Computer -Description "WinOptimizador_Restore" -RestorePointType "MODIFY_SETTINGS"
            Write-Host "(OK) Punto creado." -ForegroundColor Green; Pausa 
        }
        '16' { 
            Write-Host "`n(+) Consumo Top 5 Procesos (RAM):" -ForegroundColor Cyan
            Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, @{Name="RAM(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} | Format-Table -AutoSize
            Pausa 
        }
        '17' { 
            Write-Host "`n(+) Exportando DXDIAG al Escritorio..." -ForegroundColor Cyan
            $ruta = Join-Path ([Environment]::GetFolderPath("Desktop")) "InfoSistema.txt"
            dxdiag /t $ruta
            Write-Host "(OK) Archivo creado en el Escritorio." -ForegroundColor Green; Pausa 
        }
        '18' { 
            Write-Host "`n1. Habilitar Hibernacion`n2. Deshabilitar Hibernacion" -ForegroundColor Cyan
            $hib = Read-Host "Elija (1/2)"
            if ($hib -eq '1') { powercfg.exe /hibernate on; Write-Host "(OK) Activada" }
            if ($hib -eq '2') { powercfg.exe /hibernate off; Write-Host "(OK) Desactivada" }
            Pausa 
        }
        '19' { 
            Write-Host "`n(+) Deshabilitando servicios de seguimiento..." -ForegroundColor Cyan
            Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
            Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "(OK) Telemetria bloqueada." -ForegroundColor Green; Pausa 
        }
        '20' { 
            Write-Host "`n(+) Ejecutando Mantenimiento Total..." -ForegroundColor Yellow
            @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object { if (Test-Path $_) { Remove-Item -Path "$_\*" -Recurse -Force -ErrorAction SilentlyContinue } }
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            ipconfig /flushdns | Out-Null
            Write-Host "(OK) Limpieza temporal, papelera y red completadas." -ForegroundColor Green; Pausa 
        }
        '21' { 
            Write-Host "`n===================================================" -ForegroundColor Cyan
            Write-Host " ESTANDARIZACION DE RED: CAMBIO A DHCP (FASE 1)    " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            $NIC_NAME = "Wi-Fi"
            Write-Host "`n[1/3] Configurando IP dinamica (DHCP)..." -ForegroundColor Yellow
            netsh interface ip set address name=$NIC_NAME source=dhcp | Out-Null
            Write-Host "[2/3] Configurando DNS dinamicos (DHCP)..." -ForegroundColor Yellow
            netsh interface ip set dns name=$NIC_NAME source=dhcp | Out-Null
            Write-Host "[3/3] Verificando configuracion..." -ForegroundColor Yellow
            
            $check = netsh interface ip show config name=$NIC_NAME | Select-String -Pattern "DHCP"
            if ($check) {
                Write-Host "`n[EXITO] La tarjeta $NIC_NAME quedo configurada por DHCP." -ForegroundColor Green
            } else {
                Write-Host "`n[ERROR] No se pudo cambiar la configuracion. Verifique el nombre del adaptador." -ForegroundColor Red
            }
            Pausa 
        }
        '22' { 
            Write-Host "`n===================================================" -ForegroundColor Cyan
            Write-Host " OPTIMIZACION DE SERVICIOS DEL SISTEMA (FASE 2)    " -ForegroundColor Cyan
            Write-Host "===================================================" -ForegroundColor Cyan
            $servicio = "Spooler"
            $estadoInicial = Get-Service -Name $servicio -ErrorAction SilentlyContinue
            if ($estadoInicial) {
                Write-Host "`nServicio Analizado:" $estadoInicial.DisplayName
                Write-Host "Estado Actual:" $estadoInicial.Status -ForegroundColor Yellow
                Write-Host "---------------------------------------------------"
                Write-Host "Ejecutando proceso de optimizacion..." -ForegroundColor Yellow
                Stop-Service -Name $servicio -Force -ErrorAction SilentlyContinue
                Set-Service -Name $servicio -StartupType Disabled
                
                $estadoFinal = Get-Service -Name $servicio
                Write-Host "`nNUEVO ESTADO:" -ForegroundColor Green
                Write-Host "Estado:" $estadoFinal.Status -ForegroundColor Green
                Write-Host "Tipo de Inicio:" $estadoFinal.StartType -ForegroundColor Green
                Write-Host "---------------------------------------------------"
                Write-Host "[OK] Servicio optimizado con exito." -ForegroundColor Green
            } else {
                Write-Host "`n[ERROR] El servicio '$servicio' no fue encontrado en este sistema." -ForegroundColor Red
            }
            Pausa 
        }
        '23' { 
            Write-Host "`nSaliendo de WinOptimizador..." -ForegroundColor Green
            $salir = $true 
        }
        default { 
            Write-Host "`n(!) Opcion no valida." -ForegroundColor Red; Start-Sleep -Seconds 1 
        }
    }
}