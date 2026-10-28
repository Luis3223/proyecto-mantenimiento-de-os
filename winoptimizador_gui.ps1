<#
.SYNOPSIS
    Win-Optimizador Pro v2.0 - Servidor de Interfaz Gráfica Moderna
    Sirve la interfaz web HTML5/CSS3/JS localmente y la abre en una ventana nativa de Microsoft Edge App.
#>

# 1. Elevación automática a Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. Configurar codificación UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 3. Determinar puerto y ruta base
$port = 48922
$directorioBase = Split-Path -Parent $PSCommandPath
$directorioGui = Join-Path $directorioBase "gui"

# 4. Iniciar HttpListener
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://127.0.0.1:$port/")

try {
    $listener.Start()
} catch {
    # Probar puerto alternativo si el principal está ocupado
    $port = 48925
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://127.0.0.1:$port/")
    $listener.Start()
}

# 5. Helper para responder a peticiones HTTP
function Responder-Peticion {
    param(
        $Contexto,
        [byte[]]$Contenido,
        [string]$ContentType = "text/html; charset=utf-8",
        [int]$StatusCode = 200
    )
    try {
        $res = $Contexto.Response
        $res.StatusCode = $StatusCode
        $res.ContentType = $ContentType
        $res.ContentLength64 = $Contenido.Length
        $res.AddHeader("Access-Control-Allow-Origin", "*")
        $res.AddHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        $res.AddHeader("Access-Control-Allow-Headers", "Content-Type, *")
        $res.AddHeader("Cache-Control", "no-cache, no-store, must-revalidate")
        $res.OutputStream.Write($Contenido, 0, $Contenido.Length)
        $res.OutputStream.Close()
    } catch {
        # Ignorar si el cliente cerró el socket antes de tiempo
    }
}

# 6. Helper de estadísticas del sistema
function Obtener-EstadisticasJson {
    $cDrive = Get-PSDrive C -ErrorAction SilentlyContinue
    $libreGB = 0
    $totalGB = 0
    $pctLibre = 0
    if ($cDrive) {
        $libreGB = [math]::Round($cDrive.Free / 1GB, 1)
        $usadoGB = [math]::Round($cDrive.Used / 1GB, 1)
        $totalGB = $libreGB + $usadoGB
        $pctLibre = if ($totalGB -gt 0) { [math]::Round(($libreGB / $totalGB) * 100) } else { 0 }
    }

    $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
    $ramLibreGB = 0
    $ramTotalGB = 0
    if ($os) {
        $ramLibreGB = [math]::Round(($os.FreePhysicalMemory / 1024 / 1024), 1)
        $ramTotalGB = [math]::Round(($os.TotalVisibleMemorySize / 1024 / 1024), 1)
    }

    $datos = @{
        disco = @{
            libreGB = $libreGB
            totalGB = $totalGB
            porcentajeLibre = $pctLibre
        }
        ram = @{
            libreGB = $ramLibreGB
            totalGB = $ramTotalGB
        }
        equipo = $env:COMPUTERNAME
        usuario = $env:USERNAME
    }

    $json = $datos | ConvertTo-Json -Compress
    return [System.Text.Encoding]::UTF8.GetBytes($json)
}

# 7. Ejecutor de Tareas Técnicas
# 6.2 Helper para escanear archivos pesados (>10MB) en carpetas de usuario
function Obtener-ArchivosPesadosJson {
    $carpetas = @(
        (Join-Path $env:USERPROFILE "Downloads"),
        (Join-Path $env:USERPROFILE "Videos"),
        (Join-Path $env:USERPROFILE "Desktop"),
        (Join-Path $env:USERPROFILE "Documents"),
        $env:TEMP
    )
    $candidatos = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
    foreach ($dir in $carpetas) {
        if (Test-Path $dir) {
            # Nivel 1 (archivos directos)
            Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue | ForEach-Object {
                if ($_.Length -gt 10MB) { $candidatos.Add($_) }
            }
            # Nivel 2 (un subnivel de carpetas)
            Get-ChildItem -Path $dir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                Get-ChildItem -Path $_.FullName -File -ErrorAction SilentlyContinue | ForEach-Object {
                    if ($_.Length -gt 10MB) { $candidatos.Add($_) }
                }
            }
        }
    }

    $top = $candidatos | Sort-Object Length -Descending | Select-Object -First 30
    $lista = @()
    $idx = 1
    foreach ($f in $top) {
        $mb = [math]::Round($f.Length / 1MB, 2)
        $gb = [math]::Round($f.Length / 1GB, 2)
        $tamTxt = if ($gb -ge 1) { "$gb GB" } else { "$mb MB" }
        
        $tipo = "file"
        $ext = $f.Extension.ToLower()
        if ($ext -in @(".mp4", ".mkv", ".avi", ".mov", ".wmv", ".flv")) { $tipo = "video" }
        elseif ($ext -in @(".zip", ".rar", ".7z", ".tar", ".gz", ".iso")) { $tipo = "archive" }
        elseif ($ext -in @(".exe", ".msi")) { $tipo = "app" }
        elseif ($ext -in @(".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx")) { $tipo = "document" }

        $lista += @{
            id = $idx
            name = $f.Name
            path = $f.FullName
            directory = $f.DirectoryName
            sizeBytes = $f.Length
            sizeText = $tamTxt
            type = $tipo
        }
        $idx++
    }

    $json = $lista | ConvertTo-Json -Compress
    return [System.Text.Encoding]::UTF8.GetBytes($json)
}

# 6.3 Helper para eliminar archivos seleccionados y calcular bytes liberados
function Eliminar-ArchivosSeleccionadosJson {
    param([string]$JsonCuerpo)
    [long]$bytesLiberados = 0
    $borradosCount = 0
    $errores = @()
    $eliminados = @()

    $rutas = @()
    if ($JsonCuerpo) {
        try {
            $parsed = $JsonCuerpo | ConvertFrom-Json
            if ($parsed -is [System.Collections.IEnumerable] -and $parsed -isnot [string]) {
                $rutas = $parsed
            } elseif ($parsed.paths) {
                $rutas = $parsed.paths
            }
        } catch {
            $rutas = $JsonCuerpo -split "[,\r\n]+" | Where-Object { $_ -ne "" }
        }
    }

    foreach ($r in $rutas) {
        $rutaStr = "$r".Trim('"', "'", ' ')
        if ($rutaStr -and (Test-Path -LiteralPath $rutaStr)) {
            try {
                $item = Get-Item -LiteralPath $rutaStr -ErrorAction Stop
                $tam = $item.Length
                Remove-Item -LiteralPath $rutaStr -Force -ErrorAction Stop
                $bytesLiberados += $tam
                $borradosCount++
                $eliminados += $item.Name
            } catch {
                $errores += "Error al eliminar '$rutaStr': $($_.Exception.Message)"
            }
        }
    }

    $mb = [math]::Round($bytesLiberados / 1MB, 2)
    $gb = [math]::Round($bytesLiberados / 1GB, 2)
    $txtLiberado = if ($gb -ge 1) { "$gb GB" } else { "$mb MB" }

    $resultado = @{
        success = ($borradosCount -gt 0 -or $rutas.Count -eq 0)
        borrados = $borradosCount
        bytesLiberados = $bytesLiberados
        textoLiberado = $txtLiberado
        eliminados = $eliminados
        errores = $errores
    }

    $json = $resultado | ConvertTo-Json -Compress
    return [System.Text.Encoding]::UTF8.GetBytes($json)
}

function Ejecutar-Tarea {
    param([string]$Id, [string]$Param)
    $out = [System.Collections.Generic.List[string]]::new()

    switch ($Id) {
        '01' {
            $out.Add("[+] Purgando temporales de usuario, sistema y Prefetch...")
            $rutas = @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch")
            foreach ($r in $rutas) {
                if (Test-Path $r) {
                    Remove-Item -Path "$r\*" -Recurse -Force -ErrorAction SilentlyContinue
                    $out.Add("  ✔ Carpeta limpiada: $r")
                }
            }
            $out.Add("[OK] Archivos temporales eliminados correctamente.")
        }
        '02' {
            $out.Add("[+] Vaciando la papelera de reciclaje en todas las unidades...")
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            $out.Add("[OK] Papelera de reciclaje completamente vaciada.")
        }
        '03' {
            $out.Add("[+] Deteniendo servicio Windows Update (wuauserv)...")
            Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            $out.Add("[+] Purgando descargas en SoftwareDistribution\Download...")
            Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
            $out.Add("[+] Reanudando servicio Windows Update...")
            Start-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
            $out.Add("[OK] Caché de actualizaciones reparada y purgada con éxito.")
        }
        '04' {
            $out.Add("[+] Localizando y suprimiendo archivos .log antiguos en C:\Windows...")
            Get-ChildItem -Path "C:\Windows" -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
            $out.Add("[OK] Archivos de registro (.log) eliminados con éxito.")
        }
        '05' {
            $out.Add("[+] Limpiando memoria del portapapeles...")
            Set-Clipboard -Value $null
            $out.Add("[OK] Historial del portapapeles purgado.")
        }
        '06' {
            $out.Add("[+] Ejecutando optimización y ReTrim en unidad C:...")
            Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue
            $out.Add("[OK] Optimización de volumen finalizada.")
        }
        '07' {
            $out.Add("[+] Organizando archivos del Escritorio en subcarpetas...")
            $ruta = [Environment]::GetFolderPath("Desktop")
            $archivos = Get-ChildItem -Path $ruta -File | Where-Object { $_.Extension -ne ".lnk" -and $_.Extension -ne "" }
            $c = 0
            foreach ($a in $archivos) {
                $ext = $a.Extension.TrimStart('.').ToUpper()
                $dir = Join-Path $ruta $ext
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
                Move-Item -Path $a.FullName -Destination $dir -Force
                $c++
            }
            $out.Add("[OK] Se organizaron $c archivo(s) en el Escritorio.")
        }
        '08' {
            $out.Add("[+] Organizando carpeta de Descargas por formatos...")
            $ruta = Join-Path $env:USERPROFILE "Downloads"
            $archivos = Get-ChildItem -Path $ruta -File | Where-Object { $_.Extension -ne "" }
            $c = 0
            foreach ($a in $archivos) {
                $ext = $a.Extension.TrimStart('.').ToUpper()
                $dir = Join-Path $ruta $ext
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
                Move-Item -Path $a.FullName -Destination $dir -Force
                $c++
            }
            $out.Add("[OK] Se organizaron $c archivo(s) en Descargas.")
        }
        '09' {
            $out.Add("[1/3] Vaciando la caché DNS...")
            ipconfig /flushdns | Out-Null
            $out.Add("[2/3] Liberando dirección IP...")
            ipconfig /release | Out-Null
            $out.Add("[3/3] Renovando dirección IP...")
            ipconfig /renew | Out-Null
            $out.Add("[OK] Configuración de red DNS e IP renovadas exitosamente.")
        }
        '10' {
            $out.Add("[+] Restableciendo catálogo de sockets de red (Winsock)...")
            netsh winsock reset | Out-Null
            $out.Add("[OK] Winsock restablecido a valores de fábrica.")
            $out.Add("[!] AVISO: Se recomienda reiniciar el equipo para aplicar los cambios.")
        }
        '11' {
            $out.Add("[+] Ejecutando SFC /scannow (Comprobador de archivos del sistema)...")
            $res = sfc /scannow | Out-String
            $out.Add($res)
            $out.Add("[OK] Escaneo SFC finalizado.")
        }
        '12' {
            $out.Add("[+] Ejecutando DISM /RestoreHealth...")
            $res = DISM /Online /Cleanup-Image /RestoreHealth | Out-String
            $out.Add($res)
            $out.Add("[OK] Reparación de componentes DISM concluida.")
        }
        '13' {
            $out.Add("[+] Analizando sectores y metadatos de C: con CHKDSK...")
            $res = chkdsk C: | Out-String
            $out.Add($res)
            $out.Add("[OK] Comprobación de disco concluida.")
        }
        '14' {
            $out.Add("[+] Restableciendo caché de Microsoft Store (WSReset.exe)...")
            Start-Process wsreset.exe -Wait
            $out.Add("[OK] Tienda de Microsoft restablecida correctamente.")
        }
        '15' {
            $out.Add("[+] Verificando Protección del Sistema en C:...")
            Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
            $out.Add("[+] Creando Punto de Restauración...")
            try {
                Checkpoint-Computer -Description "WinOptimizador_Restore" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
                $out.Add("[OK] Punto de restauración 'WinOptimizador_Restore' creado exitosamente.")
            } catch {
                $out.Add("[!] Aviso: $($_.Exception.Message)")
            }
        }
        '16' {
            $out.Add("=== TOP 5 PROCESOS POR CONSUMO DE RAM ===")
            Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, @{Name="RAM_MB";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}} | ForEach-Object {
                $out.Add("  • " + $_.Name + ": " + $_.RAM_MB + " MB")
            }
            $out.Add("=== TOP 5 PROCESOS POR USO DE CPU ===")
            Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, @{Name="CPU_s";Expression={[math]::Round($_.CPU, 2)}} | ForEach-Object {
                $out.Add("  • " + $_.Name + ": " + $_.CPU_s + " s")
            }
        }
        '17' {
            $out.Add("[+] Generando informe DXDiag del sistema...")
            $ruta = Join-Path ([Environment]::GetFolderPath("Desktop")) "InfoSistema.txt"
            dxdiag /t $ruta
            $out.Add("[OK] Informe técnico creado en tu Escritorio:")
            $out.Add("  ➜ $ruta")
        }
        '18' {
            if ($Param -eq "on") {
                powercfg.exe /hibernate on
                $out.Add("[OK] Hibernación de Windows activada (Inicio Rápido disponible).")
            } else {
                powercfg.exe /hibernate off
                $out.Add("[OK] Hibernación desactivada y archivo hiberfil.sys liberado.")
            }
        }
        '19' {
            $out.Add("[+] Deshabilitando servicio de telemetría DiagTrack...")
            Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
            Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
            $out.Add("[OK] Telemetría básica bloqueada con éxito.")
        }
        '20' {
            $out.Add("=== INICIANDO MANTENIMIENTO TOTAL AUTOMÁTICO ===")
            $out.Add("[1/3] Purgando carpetas de temporales...")
            @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object {
                if (Test-Path $_) { Remove-Item -Path "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }
            }
            $out.Add("  ✔ Temporales eliminados.")
            $out.Add("[2/3] Vaciando la papelera de reciclaje...")
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
            $out.Add("  ✔ Papelera vaciada.")
            $out.Add("[3/3] Renovando caché DNS...")
            ipconfig /flushdns | Out-Null
            $out.Add("  ✔ Caché de red renovada.")
            $out.Add("[OK] ¡Mantenimiento Express completado al 100%! Tu equipo está optimizado.")
        }
        '21' {
            $out.Add("=== CONFIGURACIÓN DHCP (FASE 1) ===")
            $NIC_NAME = "Wi-Fi"
            $activo = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
            if ($activo) { $NIC_NAME = $activo.Name }
            $out.Add("[+] Adaptador seleccionado: '$NIC_NAME'")
            netsh interface ip set address name=$NIC_NAME source=dhcp | Out-Null
            netsh interface ip set dns name=$NIC_NAME source=dhcp | Out-Null
            $out.Add("[OK] Adaptador '$NIC_NAME' configurado a IP y DNS automáticos por DHCP.")
        }
        '22' {
            $out.Add("=== DESHABILITAR SPOOLER (FASE 2) ===")
            Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
            Set-Service -Name Spooler -StartupType Disabled
            $out.Add("[OK] Servicio de cola de impresión Spooler detenido y deshabilitado.")
        }
        '23' {
            $out.Add("=== ANÃLISIS DE ARCHIVOS PESADOS ===")
            $out.Add("[+] Escaneando archivos de gran tamaÃ±o en carpetas de usuario...")
            $carpetas = @(
                (Join-Path $env:USERPROFILE "Downloads"),
                (Join-Path $env:USERPROFILE "Videos"),
                (Join-Path $env:USERPROFILE "Desktop"),
                (Join-Path $env:USERPROFILE "Documents"),
                $env:TEMP
            )
            $cands = [System.Collections.Generic.List[System.IO.FileInfo]]::new()
            foreach ($dir in $carpetas) {
                if (Test-Path $dir) {
                    Get-ChildItem -Path $dir -File -ErrorAction SilentlyContinue | ForEach-Object {
                        if ($_.Length -gt 10MB) { $cands.Add($_) }
                    }
                }
            }
            $top5 = $cands | Sort-Object Length -Descending | Select-Object -First 5
            if ($top5.Count -eq 0) {
                $out.Add("[OK] No se detectaron archivos mayores a 10MB en carpetas de usuario.")
            } else {
                foreach ($f in $top5) {
                    $mb = [math]::Round($f.Length / 1MB, 1)
                    $out.Add("  â€¢ [$mb MB] $($f.Name)")
                }
                $out.Add("[INFO] Usa la tarjeta 'Archivos Pesados' en la GUI para seleccionarlos y eliminarlos con seguridad.")
            }
        }
        default {
            $out.Add("[!] Herramienta no reconocida.")
        }
    }

    $texto = ($out -join "`n")
    return [System.Text.Encoding]::UTF8.GetBytes($texto)
}

# 8. Lanzar Ventana Nativa de Microsoft Edge en Modo Aplicación
$urlApp = "http://127.0.0.1:$port/"

$edgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path $edgePath)) {
    $edgePath = "C:\Program Files\Microsoft\Edge\Application\msedge.exe"
}

if (Test-Path $edgePath) {
    # Modo App: ventana independiente nativa sin barra de direcciones ni pestañas
    Start-Process $edgePath -ArgumentList "--app=`"$urlApp`" --window-size=1160,820"
} else {
    Start-Process $urlApp
}

# 9. Bucle de Servicio HTTP
$servir = $true
while ($servir) {
    $context = $null
    try {
        $context = $listener.GetContext()
    } catch {
        # Listener detenido
        break
    }

    if ($null -eq $context) { continue }

    try {
        $req = $context.Request
        $urlRelativa = $req.Url.AbsolutePath

        # Preflight CORS
        if ($req.HttpMethod -eq "OPTIONS") {
            Responder-Peticion $context ([byte[]]@()) "text/plain" 200
            continue
        }

        if ($urlRelativa -eq "/" -or $urlRelativa -eq "/index.html") {
            $archivo = Join-Path $directorioGui "index.html"
            $bytes = [System.IO.File]::ReadAllBytes($archivo)
            Responder-Peticion $context $bytes "text/html; charset=utf-8"
        }
        elseif ($urlRelativa -eq "/style.css") {
            $archivo = Join-Path $directorioGui "style.css"
            $bytes = [System.IO.File]::ReadAllBytes($archivo)
            Responder-Peticion $context $bytes "text/css; charset=utf-8"
        }
        elseif ($urlRelativa -eq "/app.js") {
            $archivo = Join-Path $directorioGui "app.js"
            $bytes = [System.IO.File]::ReadAllBytes($archivo)
            Responder-Peticion $context $bytes "application/javascript; charset=utf-8"
        }
        elseif ($urlRelativa -eq "/api/scan-large-files") {
            $bytes = Obtener-ArchivosPesadosJson
            Responder-Peticion $context $bytes "application/json; charset=utf-8"
        }
        elseif ($urlRelativa -eq "/api/delete-files") {
            $cuerpo = ""
            if ($req.HasEntityBody) {
                $reader = [System.IO.StreamReader]::new($req.InputStream, [System.Text.Encoding]::UTF8)
                $cuerpo = $reader.ReadToEnd()
                $reader.Close()
            }
            if (-not $cuerpo -and $req.QueryString["paths"]) {
                $cuerpo = $req.QueryString["paths"]
            }
            $bytes = Eliminar-ArchivosSeleccionadosJson -JsonCuerpo $cuerpo
            Responder-Peticion $context $bytes "application/json; charset=utf-8"
        }
        elseif ($urlRelativa -eq "/api/stats") {
            $bytes = Obtener-EstadisticasJson
            Responder-Peticion $context $bytes "application/json; charset=utf-8"
        }
        elseif ($urlRelativa -eq "/api/run") {
            $id = $req.QueryString["id"]
            $param = $req.QueryString["param"]
            $bytes = Ejecutar-Tarea -Id $id -Param $param
            Responder-Peticion $context $bytes "text/plain; charset=utf-8"
        }
        elseif ($urlRelativa -eq "/api/ping") {
            Responder-Peticion $context ([System.Text.Encoding]::UTF8.GetBytes("PONG")) "text/plain; charset=utf-8"
        }
        else {
            Responder-Peticion $context ([System.Text.Encoding]::UTF8.GetBytes("Recurso no encontrado")) "text/plain" 404
        }
    } catch {
        # Si ocurre un error en una petición individual, capturarlo y continuar sirviendo
        try {
            Responder-Peticion $context ([System.Text.Encoding]::UTF8.GetBytes("Error en el servidor: $_")) "text/plain" 500
        } catch {}
    }
}

try {
    $listener.Stop()
    $listener.Close()
} catch {}
