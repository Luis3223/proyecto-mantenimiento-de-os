<#
.SYNOPSIS
    WinOptimizador Pro v2.0 - Suite de Mantenimiento y Rendimiento
    Interfaz Interactiva TUI (Terminal User Interface) con soporte de teclado,
    pestañas categorizadas, monitor del sistema en vivo y ejecución visual.
#>

# 1. Elevación automática a Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. Configuración de Codificación y Título de Consola
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try { $Host.UI.RawUI.WindowTitle = "⚡ Win-Optimizador Pro v2.0 - Suite Interactiva" } catch {}

# 3. Función de Pausa estilizada
function Pausa {
    Write-Host ""
    Write-Host " ╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkGray
    Write-Host " │  ✔ Presione cualquier tecla para regresar al menú interactivo...         │" -ForegroundColor Yellow
    Write-Host " ╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkGray
    try {
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } catch {
        Read-Host
    }
}

# 4. Helper para obtener estado de Disco y Memoria en vivo
function Obtener-TelemetriaSistema {
    $infoDisco = "Disco C: N/D"
    $cDrive = Get-PSDrive C -ErrorAction SilentlyContinue
    if ($cDrive) {
        $libreGB = [math]::Round($cDrive.Free / 1GB, 1)
        $usadoGB = [math]::Round($cDrive.Used / 1GB, 1)
        $totalGB = $libreGB + $usadoGB
        $pct = if ($totalGB -gt 0) { [math]::Round(($libreGB / $totalGB) * 100) } else { 0 }
        $infoDisco = "C: ${libreGB}GB libres (${pct}%)"
    }

    $infoRAM = "RAM: N/D"
    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    if ($os) {
        $ramLibreMB = [math]::Round($os.FreePhysicalMemory / 1024, 0)
        $ramTotalMB = [math]::Round($os.TotalVisibleMemorySize / 1024, 0)
        $ramLibreGB = [math]::Round($ramLibreMB / 1024, 1)
        $ramTotalGB = [math]::Round($ramTotalMB / 1024, 1)
        $infoRAM = "RAM: ${ramLibreGB}GB / ${ramTotalGB}GB libres"
    }

    return @{
        Disco  = $infoDisco
        RAM    = $infoRAM
        Equipo = $env:COMPUTERNAME
        User   = $env:USERNAME
    }
}

# 5. Definición de Pestañas y Opciones con Descripción
$categorias = @(
    @{ Id = 0; Titulo = "🧹 Limpieza"; Desc = "Liberación de espacio, temporales y optimización de disco" },
    @{ Id = 1; Titulo = "🌐 Redes"; Desc = "Diagnóstico, renovación de DNS/IP y configuración DHCP" },
    @{ Id = 2; Titulo = "🩺 Diagnóstico"; Desc = "Reparación de imagen, archivos del sistema e integridad de disco" },
    @{ Id = 3; Titulo = "🛡️ Sistema"; Desc = "Puntos de restauración, monitor de recursos y telemetría" },
    @{ Id = 4; Titulo = "⚡ Automático"; Desc = "Rutinas automatizadas de mantenimiento en un solo clic" }
)

# Catálogo completo de las 22 opciones
$catalogoOpciones = @{
    0 = @(
        @{ Num = "01"; Titulo = "Limpiar Temporales y Prefetch"; Desc = "Elimina archivos temporales de usuario, sistema y caché de arranque Prefetch." },
        @{ Num = "02"; Titulo = "Vaciar Papelera de Reciclaje"; Desc = "Purga de forma definitiva los archivos eliminados de todas las unidades." },
        @{ Num = "03"; Titulo = "Limpiar Caché de Windows Update"; Desc = "Detiene wuauserv y elimina descargas residuales dañadas de actualizaciones." },
        @{ Num = "04"; Titulo = "Eliminar Archivos de Log (.log)"; Desc = "Localiza y suprime archivos de registro antiguos que consumen espacio en disco." },
        @{ Num = "05"; Titulo = "Limpiar Historial del Portapapeles"; Desc = "Borra todo el contenido temporal guardado en el portapapeles de Windows." },
        @{ Num = "06"; Titulo = "Optimizar y Desfragmentar Discos (C:)"; Desc = "Ejecuta TRIM en discos SSD o desfragmentación organizada en discos duros HDD." },
        @{ Num = "07"; Titulo = "Organizar Escritorio Automáticamente"; Desc = "Clasifica y mueve archivos sueltos del Escritorio en carpetas por extensión." },
        @{ Num = "08"; Titulo = "Organizar Carpeta de Descargas"; Desc = "Agrupa y organiza los archivos de Descargas en carpetas según su formato." },
        @{ Num = "23"; Titulo = "Analizar y Liberar Archivos Pesados"; Desc = "Detecta qué archivos consumen más espacio en tu disco y te permite seleccionar y borrar." }
    )
    1 = @(
        @{ Num = "09"; Titulo = "Limpiar DNS y Renovar IP"; Desc = "Vacía la caché de resolución de nombres DNS y renueva la concesión IP del equipo." },
        @{ Num = "10"; Titulo = "Restablecer Adaptadores (Winsock)"; Desc = "Restaura el catálogo de sockets de red TCP/IP a sus valores predeterminados." },
        @{ Num = "21"; Titulo = "Configurar Red a DHCP Automático"; Desc = "Fase 1: Configura el adaptador a direccionamiento dinámico de IP y DNS." }
    )
    2 = @(
        @{ Num = "11"; Titulo = "Escanear Integridad (SFC /scannow)"; Desc = "Examina y repara archivos críticos dañados del sistema operativo Windows." },
        @{ Num = "12"; Titulo = "Reparar Imagen de Windows (DISM)"; Desc = "Descarga y reconstruye componentes corruptos de la imagen con RestoreHealth." },
        @{ Num = "13"; Titulo = "Comprobar Errores de Disco (CHKDSK C:)"; Desc = "Analiza el sistema de archivos NTFS en busca de inconsistencias o sectores malos." },
        @{ Num = "14"; Titulo = "Restablecer Tienda de Windows (WSReset)"; Desc = "Limpia la caché de Microsoft Store sin desinstalar aplicaciones ni compras." }
    )
    3 = @(
        @{ Num = "15"; Titulo = "Crear Punto de Restauración"; Desc = "Genera un punto de control del sistema para revertir fallos o cambios futuros." },
        @{ Num = "16"; Titulo = "Monitor de Consumo RAM y CPU (Top 5)"; Desc = "Muestra en tiempo real los 5 procesos que mayor impacto generan en el sistema." },
        @{ Num = "17"; Titulo = "Exportar Informe del Sistema (DXDiag)"; Desc = "Genera un archivo de diagnóstico técnico completo 'InfoSistema.txt' en el Escritorio." },
        @{ Num = "18"; Titulo = "Gestionar Hibernación (Activar/Desactivar)"; Desc = "Permite habilitar o deshabilitar hiberfil.sys para recuperar varios GB en C:." },
        @{ Num = "19"; Titulo = "Deshabilitar Telemetría Básica"; Desc = "Detiene y desactiva el servicio en segundo plano DiagTrack de Microsoft." },
        @{ Num = "22"; Titulo = "Deshabilitar Spooler de Impresión"; Desc = "Fase 2: Detiene y deshabilita la cola de impresión si no usas impresoras." }
    )
    4 = @(
        @{ Num = "20"; Titulo = "Mantenimiento Total (Auto-Ejecución)"; Desc = "Rutina completa: purga de temporales, vaciado de papelera y reseteo de DNS en 1 clic." },
        @{ Num = "00"; Titulo = "Salir de Win-Optimizador"; Desc = "Cierra la suite de mantenimiento de manera segura." }
    )
}

# 6. Ejecución de Funciones Técnicas
function Ejecutar-Opcion {
    param([string]$Numero)

    Clear-Host
    Write-Host ""
    Write-Host " ╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
    Write-Host " │  ⚡ WIN-OPTIMIZADOR PRO  •  EJECUTANDO OPERACIÓN #$Numero".PadRight(75) + "│" -ForegroundColor Cyan
    Write-Host " ╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan

    try { [Console]::CursorVisible = $true } catch {}

    switch ($Numero) {
        '01' {
            Write-Host "`n[+] Limpiando temporales y archivos Prefetch..." -ForegroundColor Cyan
            $rutas = @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch")
            foreach ($ruta in $rutas) {
                if (Test-Path $ruta) {
                    Remove-Item -Path "$ruta\*" -Recurse -Force -ErrorAction SilentlyContinue
                    Write-Host "  ✔ Purgado: $ruta" -ForegroundColor Green
                }
            }
            Write-Host "`n[OK] Temporales y Prefetch eliminados correctamente." -ForegroundColor Green
            Pausa
        }
        '02' {
            Write-Host "`n[+] Vaciando la Papelera de Reciclaje..." -ForegroundColor Cyan
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "`n[OK] Papelera de reciclaje vaciada completamente." -ForegroundColor Green
            Pausa
        }
        '03' {
            Write-Host "`n[+] Deteniendo servicio de Windows Update (wuauserv)..." -ForegroundColor Cyan
            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Eliminando descargas residuales en SoftwareDistribution\Download..." -ForegroundColor Cyan
            Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Reiniciando servicio de Windows Update..." -ForegroundColor Cyan
            Start-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            Write-Host "`n[OK] Caché de actualizaciones limpia y servicio restablecido." -ForegroundColor Green
            Pausa
        }
        '04' {
            Write-Host "`n[+] Buscando y eliminando archivos .log en C:\Windows..." -ForegroundColor Cyan
            Get-ChildItem -Path "C:\Windows" -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
            Write-Host "`n[OK] Archivos de registro (.log) eliminados con éxito." -ForegroundColor Green
            Pausa
        }
        '05' {
            Write-Host "`n[+] Purgando datos del portapapeles..." -ForegroundColor Cyan
            Set-Clipboard -Value $null
            Write-Host "`n[OK] Historial del portapapeles borrado." -ForegroundColor Green
            Pausa
        }
        '06' {
            Write-Host "`n[+] Ejecutando optimización y ReTrim en la unidad C:..." -ForegroundColor Cyan
            Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue
            Write-Host "`n[OK] Optimización de volumen completada." -ForegroundColor Green
            Pausa
        }
        '07' {
            Write-Host "`n[+] Organizando archivos del Escritorio en carpetas..." -ForegroundColor Cyan
            $rutaEscritorio = [Environment]::GetFolderPath("Desktop")
            $archivos = Get-ChildItem -Path $rutaEscritorio -File | Where-Object { $_.Extension -ne ".lnk" -and $_.Extension -ne "" }
            $count = 0
            foreach ($a in $archivos) {
                $ext = $a.Extension.TrimStart('.').ToUpper()
                $dir = Join-Path $rutaEscritorio $ext
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
                Move-Item -Path $a.FullName -Destination $dir -Force
                Write-Host "  ➜ Movido '$($a.Name)' a '$ext'" -ForegroundColor Gray
                $count++
            }
            Write-Host "`n[OK] Se organizaron $count archivo(s) en el Escritorio." -ForegroundColor Green
            Pausa
        }
        '08' {
            Write-Host "`n[+] Organizando archivos de la carpeta Descargas..." -ForegroundColor Cyan
            $rutaDescargas = Join-Path $env:USERPROFILE "Downloads"
            $archivos = Get-ChildItem -Path $rutaDescargas -File | Where-Object { $_.Extension -ne "" }
            $count = 0
            foreach ($a in $archivos) {
                $ext = $a.Extension.TrimStart('.').ToUpper()
                $dir = Join-Path $rutaDescargas $ext
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
                Move-Item -Path $a.FullName -Destination $dir -Force
                Write-Host "  ➜ Movido '$($a.Name)' a '$ext'" -ForegroundColor Gray
                $count++
            }
            Write-Host "`n[OK] Se organizaron $count archivo(s) en Descargas." -ForegroundColor Green
            Pausa
        }
        '09' {
            Write-Host "`n[1/3] Vaciando caché de resolución DNS..." -ForegroundColor Cyan
            ipconfig /flushdns
            Write-Host "`n[2/3] Liberando concesión IP..." -ForegroundColor Cyan
            ipconfig /release
            Write-Host "`n[3/3] Renovando dirección IP por DHCP..." -ForegroundColor Cyan
            ipconfig /renew
            Write-Host "`n[OK] Red DNS e IP renovadas con éxito." -ForegroundColor Green
            Pausa
        }
        '10' {
            Write-Host "`n[+] Restableciendo catálogo Winsock y pila TCP/IP..." -ForegroundColor Cyan
            netsh winsock reset
            Write-Host "`n[OK] Winsock restablecido exitosamente." -ForegroundColor Green
            Write-Host "[!] AVISO: Se recomienda reiniciar el equipo para completar los cambios." -ForegroundColor Yellow
            Pausa
        }
        '11' {
            Write-Host "`n[+] Iniciando Comprobador de Archivos de Sistema (SFC /scannow)..." -ForegroundColor Cyan
            Write-Host "    (Este análisis puede tomar varios minutos. Por favor espere)`n" -ForegroundColor DarkGray
            sfc /scannow
            Write-Host "`n[OK] Escaneo de SFC finalizado." -ForegroundColor Green
            Pausa
        }
        '12' {
            Write-Host "`n[+] Ejecutando DISM /Online /Cleanup-Image /RestoreHealth..." -ForegroundColor Cyan
            Write-Host "    (Conectando con Windows Update para reparar la imagen del sistema)`n" -ForegroundColor DarkGray
            DISM /Online /Cleanup-Image /RestoreHealth
            Write-Host "`n[OK] Proceso de reparación de imagen DISM concluido." -ForegroundColor Green
            Pausa
        }
        '13' {
            Write-Host "`n[+] Ejecutando CHKDSK en unidad C: (Modo Diagnóstico)...`n" -ForegroundColor Cyan
            chkdsk C:
            Write-Host "`n[OK] Comprobación de integridad de disco finalizada." -ForegroundColor Green
            Pausa
        }
        '14' {
            Write-Host "`n[+] Restableciendo caché de Microsoft Store (WSReset.exe)..." -ForegroundColor Cyan
            wsreset.exe
            Write-Host "`n[OK] Comando de restablecimiento de Microsoft Store enviado." -ForegroundColor Green
            Pausa
        }
        '15' {
            Write-Host "`n[+] Verificando Protección del Sistema en unidad C:..." -ForegroundColor Cyan
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            Write-Host "[+] Creando Punto de Restauración..." -ForegroundColor Cyan
            try {
                Checkpoint-Computer -Description "WinOptimizador_Restore" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
                Write-Host "`n[OK] Punto de restauración 'WinOptimizador_Restore' creado exitosamente." -ForegroundColor Green
            } catch {
                Write-Host "`n[!] Aviso: $($_.Exception.Message)" -ForegroundColor Yellow
                Write-Host "    (Windows suele restringir la creación de puntos a 1 cada 24 horas)." -ForegroundColor DarkGray
            }
            Pausa
        }
        '16' {
            Write-Host "`n==========================================================================" -ForegroundColor Cyan
            Write-Host "   MONITOR: TOP 5 PROCESOS POR CONSUMO DE RECURSOS                       " -ForegroundColor White -BackgroundColor DarkBlue
            Write-Host "==========================================================================" -ForegroundColor Cyan
            
            Write-Host "`n[+] Top 5 Procesos con mayor consumo de Memoria RAM:" -ForegroundColor Yellow
            Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, @{Name="RAM(MB)";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}, Id | Format-Table -AutoSize
            
            Write-Host "[+] Top 5 Procesos con mayor tiempo de CPU:" -ForegroundColor Yellow
            Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, @{Name="CPU(s)";Expression={[math]::Round($_.CPU, 2)}}, Id | Format-Table -AutoSize
            Pausa
        }
        '17' {
            Write-Host "`n[+] Exportando informe de diagnóstico DXDiag al Escritorio..." -ForegroundColor Cyan
            $ruta = Join-Path ([Environment]::GetFolderPath("Desktop")) "InfoSistema.txt"
            dxdiag /t $ruta
            Write-Host "`n[OK] Informe técnico generado con éxito:" -ForegroundColor Green
            Write-Host "    $ruta" -ForegroundColor Yellow
            Pausa
        }
        '18' {
            Write-Host "`n[?] Gestión del archivo de hibernación (hiberfil.sys):" -ForegroundColor Cyan
            Write-Host "   1. Habilitar Hibernación  (Habilita Inicio Rápido)" -ForegroundColor White
            Write-Host "   2. Deshabilitar Hibernación (Libera varios GB en C:)" -ForegroundColor White
            Write-Host "   3. Volver al menú" -ForegroundColor DarkGray
            $op = Read-Host "`nElija una opción (1/2/3)"
            if ($op -eq '1') {
                powercfg.exe /hibernate on
                Write-Host "`n[OK] Hibernación activada." -ForegroundColor Green
            } elseif ($op -eq '2') {
                powercfg.exe /hibernate off
                Write-Host "`n[OK] Hibernación desactivada y espacio liberado." -ForegroundColor Green
            }
            Pausa
        }
        '19' {
            Write-Host "`n[+] Deteniendo servicio de telemetría DiagTrack..." -ForegroundColor Cyan
            Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
            Write-Host "[+] Configurando servicio DiagTrack a 'Deshabilitado'..." -ForegroundColor Cyan
            Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
            Write-Host "`n[OK] Telemetría básica de Windows bloqueada." -ForegroundColor Green
            Pausa
        }
        '20' {
            Write-Host "`n==========================================================================" -ForegroundColor Cyan
            Write-Host "   RUTINA DE MANTENIMIENTO TOTAL AUTOMATIZADO                            " -ForegroundColor White -BackgroundColor DarkBlue
            Write-Host "==========================================================================" -ForegroundColor Cyan
            
            Write-Host "`n[1/3] Limpiando carpetas de temporales y Prefetch..." -ForegroundColor Yellow
            @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object {
                if (Test-Path $_) { Remove-Item -Path "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }
            }
            Write-Host "  ✔ Temporales purgados." -ForegroundColor Green
            
            Write-Host "`n[2/3] Vaciando la papelera de reciclaje..." -ForegroundColor Yellow
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            Write-Host "  ✔ Papelera vaciada." -ForegroundColor Green
            
            Write-Host "`n[3/3] Renovando caché DNS..." -ForegroundColor Yellow
            ipconfig /flushdns | Out-Null
            Write-Host "  ✔ Caché DNS limpia." -ForegroundColor Green
            
            Write-Host "`n[OK] ¡Mantenimiento Total finalizado con éxito!" -ForegroundColor Green
            Pausa
        }
        '21' {
            Write-Host "`n==========================================================================" -ForegroundColor Cyan
            Write-Host "   ESTANDARIZACIÓN DE RED: CAMBIO A DHCP (FASE 1)                        " -ForegroundColor White -BackgroundColor DarkBlue
            Write-Host "==========================================================================" -ForegroundColor Cyan
            
            $NIC_NAME = "Wi-Fi"
            $adaptadores = Get-NetAdapter -ErrorAction SilentlyContinue
            $activo = $adaptadores | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
            if ($activo) { $NIC_NAME = $activo.Name }

            Write-Host "`n[1/3] Configurando IP dinámica por DHCP en '$NIC_NAME'..." -ForegroundColor Yellow
            netsh interface ip set address name=$NIC_NAME source=dhcp | Out-Null
            Write-Host "[2/3] Configurando DNS dinámicos por DHCP en '$NIC_NAME'..." -ForegroundColor Yellow
            netsh interface ip set dns name=$NIC_NAME source=dhcp | Out-Null
            Write-Host "[3/3] Verificando estado..." -ForegroundColor Yellow

            $check = netsh interface ip show config name=$NIC_NAME | Select-String -Pattern "DHCP"
            if ($check) {
                Write-Host "`n[EXITO] La tarjeta '$NIC_NAME' quedó configurada por DHCP correctamente." -ForegroundColor Green
            } else {
                Write-Host "`n[ERROR] No se pudo verificar la configuración en '$NIC_NAME'." -ForegroundColor Red
            }
            Pausa
        }
        '22' {
            Write-Host "`n==========================================================================" -ForegroundColor Cyan
            Write-Host "   OPTIMIZACIÓN DE SERVICIOS: SPOOLER DE IMPRESIÓN (FASE 2)              " -ForegroundColor White -BackgroundColor DarkBlue
            Write-Host "==========================================================================" -ForegroundColor Cyan

            $servicio = "Spooler"
            $estadoInicial = Get-Service -Name $servicio -ErrorAction SilentlyContinue
            if ($estadoInicial) {
                Write-Host "`nServicio Analizado: $($estadoInicial.DisplayName)"
                Write-Host "Estado Actual:      $($estadoInicial.Status)" -ForegroundColor Yellow
                Write-Host "Tipo de Inicio:     $($estadoInicial.StartType)" -ForegroundColor Yellow
                Write-Host "--------------------------------------------------------------------------"
                Write-Host "Deteniendo servicio y deshabilitando inicio automático..." -ForegroundColor Cyan
                Stop-Service -Name $servicio -Force -ErrorAction SilentlyContinue
                Set-Service -Name $servicio -StartupType Disabled
                
                $estadoFinal = Get-Service -Name $servicio
                Write-Host "`nNUEVO ESTADO:" -ForegroundColor Green
                Write-Host "  Estado:         $($estadoFinal.Status)" -ForegroundColor Green
                Write-Host "  Tipo de Inicio: $($estadoFinal.StartType)" -ForegroundColor Green
                Write-Host "--------------------------------------------------------------------------"
                Write-Host "[OK] Servicio Spooler optimizado con éxito." -ForegroundColor Green
            } else {
                Write-Host "`n[ERROR] El servicio '$servicio' no fue encontrado en este sistema." -ForegroundColor Red
            }
            Pausa
        }
        '23' {
            Write-Host "`n[+] Escaneando carpetas de usuario en busca de archivos pesados (> 10 MB)..." -ForegroundColor Cyan
            Write-Host "    (Escaneando Descargas, Videos, Escritorio, Documentos y Temporales)`n" -ForegroundColor DarkGray

            $rutas = @(
                (Join-Path $env:USERPROFILE 'Downloads'),
                (Join-Path $env:USERPROFILE 'Videos'),
                ([Environment]::GetFolderPath('Desktop')),
                (Join-Path $env:USERPROFILE 'Documents'),
                $env:TEMP
            )

            $archivosEncontrados = @()
            foreach ($r in $rutas) {
                if (Test-Path $r) {
                    $archivosEncontrados += Get-ChildItem -Path $r -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 10MB }
                    Get-ChildItem -Path $r -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '^\.' -and $_.Name -ne 'node_modules' } | ForEach-Object {
                        $archivosEncontrados += Get-ChildItem -Path $_.FullName -File -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 10MB }
                    }
                }
            }

            $topArchivos = $archivosEncontrados | Sort-Object Length -Descending | Select-Object -First 15

            if (-not $topArchivos -or $topArchivos.Count -eq 0) {
                Write-Host "[OK] ¡Excelente! No se encontraron archivos pesados mayores a 10 MB en las carpetas escaneadas." -ForegroundColor Green
                Pausa
                return $true
            }

            Write-Host " ╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
            Write-Host " │  TOP ARCHIVOS QUE MÁS ESPACIO OCUPAN EN TU EQUIPO                        │" -ForegroundColor Cyan
            Write-Host " ╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan
            Write-Host ""

            for ($i = 0; $i -lt $topArchivos.Count; $i++) {
                $f = $topArchivos[$i]
                $mb = [math]::Round($f.Length / 1MB, 2)
                $gb = [math]::Round($f.Length / 1GB, 2)
                $tamTxt = if ($gb -ge 1) { "$gb GB" } else { "$mb MB" }
                $idxStr = ($i + 1).ToString().PadLeft(2, '0')

                Write-Host " [$idxStr] " -NoNewline -ForegroundColor Green
                Write-Host "$tamTxt".PadRight(11) -NoNewline -ForegroundColor Yellow
                Write-Host "$($f.Name)" -ForegroundColor White
                Write-Host "      ➜ Ubicación: $($f.FullName)" -ForegroundColor DarkGray
            }

            Write-Host ""
            Write-Host " ──────────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
            Write-Host " Ingrese los números de los archivos que desea ELIMINAR separados por coma" -ForegroundColor Cyan
            Write-Host " (Ejemplo: 1, 3  •  Escriba 'T' para todos  •  Presione [Enter] o '0' para cancelar)" -ForegroundColor DarkYellow
            $seleccion = Read-Host "`nSeleccione archivos a eliminar"

            if (-not $seleccion -or $seleccion -eq '0') {
                Write-Host "`n[!] Operación cancelada. No se eliminó ningún archivo." -ForegroundColor Yellow
                Pausa
                return $true
            }

            $indicesAEliminar = @()
            if ($seleccion.ToUpper() -eq 'T') {
                for ($i = 0; $i -lt $topArchivos.Count; $i++) { $indicesAEliminar += $i }
            } else {
                $partes = $seleccion.Split(',')
                foreach ($p in $partes) {
                    $numVal = 0
                    if ([int]::TryParse($p.Trim(), [ref]$numVal)) {
                        $idx = $numVal - 1
                        if ($idx -ge 0 -and $idx -lt $topArchivos.Count) {
                            $indicesAEliminar += $idx
                        }
                    }
                }
            }

            if ($indicesAEliminar.Count -eq 0) {
                Write-Host "`n[!] No seleccionó ningún número válido." -ForegroundColor Yellow
                Pausa
                return $true
            }

            Write-Host "`n[?] ¿Está seguro de eliminar de forma permanente estos $($indicesAEliminar.Count) archivo(s)? (S/N): " -NoNewline -ForegroundColor Red
            $confirma = Read-Host
            if ($confirma.ToUpper() -ne 'S') {
                Write-Host "`n[!] Operación cancelada por el usuario." -ForegroundColor Yellow
                Pausa
                return $true
            }

            [long]$bytesLiberados = 0
            $borradosCount = 0

            Write-Host "`n[+] Eliminando archivos seleccionados..." -ForegroundColor Cyan
            foreach ($idx in $indicesAEliminar) {
                $f = $topArchivos[$idx]
                try {
                    $tam = $f.Length
                    Remove-Item -Path $f.FullName -Force -ErrorAction Stop
                    $bytesLiberados += $tam
                    $borradosCount++
                    Write-Host "  ✔ Eliminado: $($f.Name)" -ForegroundColor Green
                } catch {
                    Write-Host "  ✖ Error al eliminar '$($f.Name)': $($_.Exception.Message)" -ForegroundColor Red
                }
            }

            $mbLiberados = [math]::Round($bytesLiberados / 1MB, 2)
            $gbLiberados = [math]::Round($bytesLiberados / 1GB, 2)
            $txtLiberado = if ($gbLiberados -ge 1) { "$gbLiberados GB" } else { "$mbLiberados MB" }

            Write-Host ""
            Write-Host " ╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
            Write-Host " │  🎉 ¡REPORTE DE ALMACENAMIENTO LIBERADO!                                 │" -ForegroundColor Green
            Write-Host " ├──────────────────────────────────────────────────────────────────────────┤" -ForegroundColor DarkCyan
            Write-Host " │  Se eliminaron exitosamente: $borradosCount archivo(s)".PadRight(75) + "│" -ForegroundColor White
            Write-Host " │  Espacio recuperado en disco C: $txtLiberado".PadRight(75) + "│" -ForegroundColor Yellow
            Write-Host " ╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan

            Pausa
        }
        '00' {
            Write-Host "`nSaliendo de Win-Optimizador Pro..." -ForegroundColor Cyan
            return $false
        }
    }
    return $true
}

# 7. Renderizador de Pantalla Principal (TUI)
function Dibujar-TUI {
    param(
        [int]$CategoriaIndex,
        [int]$OpcionIndex,
        [hashtable]$Telemetria
    )

    try {
        [Console]::SetCursorPosition(0, 0)
    } catch {
        Clear-Host
    }

    # Ancho estándar fijo de tarjeta: 76 caracteres internos + 2 bordes = 78 total
    Write-Host " ╭──────────────────────────────────────────────────────────────────────────╮" -ForegroundColor DarkCyan
    
    # Línea 1 Header
    $lineaHeader = " │  ⚡ WIN-OPTIMIZADOR PRO v2.0  •  Suite Integral de Mantenimiento         │"
    Write-Host " │" -NoNewline -ForegroundColor DarkCyan
    Write-Host "  ⚡ WIN-OPTIMIZADOR PRO v2.0 " -NoNewline -ForegroundColor Cyan
    Write-Host "•  Suite Integral de Mantenimiento         " -NoNewline -ForegroundColor White
    Write-Host "│" -ForegroundColor DarkCyan

    # Línea 2 Telemetría en vivo
    $adminTag = "🛡️ Admin: OK"
    $txtDisco = $Telemetria.Disco
    $txtRAM   = $Telemetria.RAM
    $subInfo  = " $adminTag │ $txtDisco │ $txtRAM"
    Write-Host " │" -NoNewline -ForegroundColor DarkCyan
    Write-Host "  $adminTag" -NoNewline -ForegroundColor Green
    Write-Host " │ " -NoNewline -ForegroundColor DarkGray
    Write-Host "$txtDisco" -NoNewline -ForegroundColor Yellow
    Write-Host " │ " -NoNewline -ForegroundColor DarkGray
    Write-Host "$($txtRAM.PadRight(38))" -NoNewline -ForegroundColor Cyan
    Write-Host "│" -ForegroundColor DarkCyan

    Write-Host " ╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan

    # Barra de Pestañas
    Write-Host ""
    Write-Host " " -NoNewline
    for ($i = 0; $i -lt $categorias.Count; $i++) {
        $cat = $categorias[$i]
        if ($i -eq $CategoriaIndex) {
            Write-Host " [$($cat.Titulo)] " -NoNewline -ForegroundColor Black -BackgroundColor Cyan
        } else {
            Write-Host "  $($cat.Titulo)  " -NoNewline -ForegroundColor DarkGray
        }
    }
    Write-Host ""
    Write-Host ""

    # Caja de Opciones de la Pestaña Activa
    $opcionesActuales = $catalogoOpciones[$CategoriaIndex]
    Write-Host " ╭─ Seleccione con [↑/↓] y confirme con [Enter] ───────────────────────────╮" -ForegroundColor DarkCyan

    for ($i = 0; $i -lt $opcionesActuales.Count; $i++) {
        $opc = $opcionesActuales[$i]
        $textoLinea = " $($opc.Num). $($opc.Titulo)"
        
        if ($i -eq $OpcionIndex) {
            # Elemento seleccionado resaltado
            Write-Host " │" -NoNewline -ForegroundColor DarkCyan
            Write-Host " ❯ " -NoNewline -ForegroundColor Green
            Write-Host "$($textoLinea.PadRight(69))" -NoNewline -ForegroundColor White -BackgroundColor DarkBlue
            Write-Host "│" -ForegroundColor DarkCyan
        } else {
            # Elemento normal
            Write-Host " │" -NoNewline -ForegroundColor DarkCyan
            Write-Host "   " -NoNewline
            Write-Host "$($textoLinea.PadRight(69))" -NoNewline -ForegroundColor Gray
            Write-Host "│" -ForegroundColor DarkCyan
        }
    }

    # Rellenar líneas vacías para altura fija consistente si la categoría tiene pocas opciones
    $lineasRestantes = 8 - $opcionesActuales.Count
    for ($k = 0; $k -lt $lineasRestantes; $k++) {
        Write-Host " │                                                                          │" -ForegroundColor DarkCyan
    }

    Write-Host " ╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkCyan

    # Panel de Descripción Informativa de la Opción Seleccionada
    $opcSeleccionada = $opcionesActuales[$OpcionIndex]
    $descTexto = " ℹ️  $($opcSeleccionada.Desc)"
    if ($descTexto.Length -gt 72) { $descTexto = $descTexto.Substring(0, 69) + "..." }
    
    Write-Host " ╭─ Detalle de la función ──────────────────────────────────────────────────╮" -ForegroundColor DarkGray
    Write-Host " │" -NoNewline -ForegroundColor DarkGray
    Write-Host "$($descTexto.PadRight(74))" -NoNewline -ForegroundColor DarkYellow
    Write-Host "│" -ForegroundColor DarkGray
    Write-Host " ╰──────────────────────────────────────────────────────────────────────────╯" -ForegroundColor DarkGray

    # Barra de Atajos y Navegación
    Write-Host "   [↑/↓] Mover  •  [←/→ o Tab] Pestañas  •  [Enter] Ejecutar  •  [Q] Salir  " -ForegroundColor DarkCyan
}

# 8. Bucle Principal de Control por Teclado
function Iniciar-WinOptimizadorTUI {
    $catIdx = 0
    $opcIdx = 0
    $ejecutando = $true

    # Ocultar cursor durante el menú
    try { [Console]::CursorVisible = $false } catch {}

    Clear-Host
    $telemetria = Obtener-TelemetriaSistema

    while ($ejecutando) {
        $opciones = $catalogoOpciones[$catIdx]
        if ($opcIdx -ge $opciones.Count) { $opcIdx = 0 }

        Dibujar-TUI -CategoriaIndex $catIdx -OpcionIndex $opcIdx -Telemetria $telemetria

        $tecla = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $vk = $tecla.VirtualKeyCode
        $char = $tecla.Character

        switch ($vk) {
            38 { # Flecha Arriba
                if ($opcIdx -gt 0) {
                    $opcIdx--
                } else {
                    $opcIdx = $opciones.Count - 1
                }
            }
            40 { # Flecha Abajo
                if ($opcIdx -lt ($opciones.Count - 1)) {
                    $opcIdx++
                } else {
                    $opcIdx = 0
                }
            }
            37 { # Flecha Izquierda
                if ($catIdx -gt 0) {
                    $catIdx--
                } else {
                    $catIdx = $categorias.Count - 1
                }
                $opcIdx = 0
                Clear-Host
            }
            39 { # Flecha Derecha
                if ($catIdx -lt ($categorias.Count - 1)) {
                    $catIdx++
                } else {
                    $catIdx = 0
                }
                $opcIdx = 0
                Clear-Host
            }
            9 { # Tabulador
                if ($catIdx -lt ($categorias.Count - 1)) {
                    $catIdx++
                } else {
                    $catIdx = 0
                }
                $opcIdx = 0
                Clear-Host
            }
            13 { # Tecla Enter
                $opcElegida = $opciones[$opcIdx].Num
                $continuar = Ejecutar-Opcion -Numero $opcElegida
                if (-not $continuar) {
                    $ejecutando = $false
                } else {
                    # Actualizar telemetría tras la ejecución (por si liberó disco)
                    $telemetria = Obtener-TelemetriaSistema
                    Clear-Host
                }
            }
            27 { # Tecla Esc
                $ejecutando = $false
            }
            default {
                # Tecla Q para salir
                if ($char -eq 'q' -or $char -eq 'Q') {
                    $ejecutando = $false
                }
            }
        }
    }

    # Restaurar consola
    try { [Console]::CursorVisible = $true } catch {}
    Clear-Host
    Write-Host "`n¡Gracias por utilizar Win-Optimizador Pro! Hasta pronto.`n" -ForegroundColor Green
}

# Iniciar Suite TUI
Iniciar-WinOptimizadorTUI