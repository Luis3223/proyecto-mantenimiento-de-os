<#
.SYNOPSIS
    Win-Optimizador Pro - Interfaz Grafica (GUI con Windows Forms)
    22 Funcionalidades integradas con visualizacion moderna y consola interactiva en tiempo real.
#>

# 1. Elevacion automatica a Administrador si no se tienen permisos
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# 2. Cargar ensamblados de Windows Forms y GDI Drawing
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# 3. Definicion de la Ventana Principal (Form)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Win-Optimizador Pro - Suite de Mantenimiento y Rendimiento"
$form.Size = New-Object System.Drawing.Size(1020, 720)
$form.MinimumSize = New-Object System.Drawing.Size(950, 650)
$form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
$form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")
$form.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#F8FAFC")
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Regular)

# Paleta de Colores
$colorHeader    = [System.Drawing.ColorTranslator]::FromHtml("#1E293B")
$colorCard      = [System.Drawing.ColorTranslator]::FromHtml("#1E293B")
$colorBtn       = [System.Drawing.ColorTranslator]::FromHtml("#2563EB")
$colorBtnSuccess= [System.Drawing.ColorTranslator]::FromHtml("#059669")
$colorBtnWarn   = [System.Drawing.ColorTranslator]::FromHtml("#D97706")
$colorBtnDanger = [System.Drawing.ColorTranslator]::FromHtml("#DC2626")
$colorBtnPurple = [System.Drawing.ColorTranslator]::FromHtml("#7C3AED")
$colorLogBg     = [System.Drawing.ColorTranslator]::FromHtml("#020617")
$colorLogText   = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")

# 4. Panel Superior (Header)
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$headerPanel.Height = 80
$headerPanel.BackColor = $colorHeader

$lblTitulo = New-Object System.Windows.Forms.Label
$lblTitulo.Text = "WIN-OPTIMIZADOR PRO"
$lblTitulo.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$lblTitulo.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#38BDF8")
$lblTitulo.Location = New-Object System.Drawing.Point(20, 12)
$lblTitulo.AutoSize = $true
$headerPanel.Controls.Add($lblTitulo)

$lblSubtitulo = New-Object System.Windows.Forms.Label
$lblSubtitulo.Text = "Suite de 22 Modulos de Mantenimiento, Reparacion y Aceleracion de Windows"
$lblSubtitulo.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$lblSubtitulo.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#94A3B8")
$lblSubtitulo.Location = New-Object System.Drawing.Point(22, 45)
$lblSubtitulo.AutoSize = $true
$headerPanel.Controls.Add($lblSubtitulo)

$badgeAdmin = New-Object System.Windows.Forms.Label
$badgeAdmin.Text = "[OK] Modo Administrador Activo"
$badgeAdmin.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$badgeAdmin.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#34D399")
$badgeAdmin.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#064E3B")
$badgeAdmin.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$badgeAdmin.Location = New-Object System.Drawing.Point(760, 24)
$badgeAdmin.Size = New-Object System.Drawing.Size(220, 32)
$badgeAdmin.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$headerPanel.Controls.Add($badgeAdmin)

$form.Controls.Add($headerPanel)

# 5. Panel Inferior (Consola de Logs y Barra de Progreso)
$bottomPanel = New-Object System.Windows.Forms.Panel
$bottomPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
$bottomPanel.Height = 220
$bottomPanel.BackColor = $colorCard

$logHeaderPanel = New-Object System.Windows.Forms.Panel
$logHeaderPanel.Dock = [System.Windows.Forms.DockStyle]::Top
$logHeaderPanel.Height = 35
$logHeaderPanel.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")

$lblLog = New-Object System.Windows.Forms.Label
$lblLog.Text = "Consola de Ejecucion en Tiempo Real:"
$lblLog.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$lblLog.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#E2E8F0")
$lblLog.Location = New-Object System.Drawing.Point(15, 8)
$lblLog.AutoSize = $true
$logHeaderPanel.Controls.Add($lblLog)

$btnLimpiarLog = New-Object System.Windows.Forms.Button
$btnLimpiarLog.Text = "Limpiar Consola"
$btnLimpiarLog.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Regular)
$btnLimpiarLog.ForeColor = [System.Drawing.Color]::White
$btnLimpiarLog.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#475569")
$btnLimpiarLog.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnLimpiarLog.FlatAppearance.BorderSize = 0
$btnLimpiarLog.Size = New-Object System.Drawing.Size(120, 24)
$btnLimpiarLog.Location = New-Object System.Drawing.Point(860, 5)
$btnLimpiarLog.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right
$logHeaderPanel.Controls.Add($btnLimpiarLog)

$bottomPanel.Controls.Add($logHeaderPanel)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Dock = [System.Windows.Forms.DockStyle]::Top
$progressBar.Height = 6
$progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Blocks
$progressBar.Value = 0
$bottomPanel.Controls.Add($progressBar)

$txtLog = New-Object System.Windows.Forms.RichTextBox
$txtLog.Dock = [System.Windows.Forms.DockStyle]::Fill
$txtLog.BackColor = $colorLogBg
$txtLog.ForeColor = $colorLogText
$txtLog.Font = New-Object System.Drawing.Font("Consolas", 9.5)
$txtLog.ReadOnly = $true
$txtLog.BorderStyle = [System.Windows.Forms.BorderStyle]::None
$bottomPanel.Controls.Add($txtLog)

$form.Controls.Add($bottomPanel)

# Funcion para registrar mensajes en la consola visual
function Log-Msg {
    param (
        [string]$Mensaje,
        [string]$Tipo = "INFO"
    )
    $timestamp = (Get-Date).ToString("HH:mm:ss")
    $color = switch ($Tipo) {
        "SUCCESS" { [System.Drawing.ColorTranslator]::FromHtml("#34D399") }
        "WARN"    { [System.Drawing.ColorTranslator]::FromHtml("#FBBF24") }
        "ERROR"   { [System.Drawing.ColorTranslator]::FromHtml("#F87171") }
        default   { [System.Drawing.ColorTranslator]::FromHtml("#38BDF8") }
    }

    $txtLog.SelectionStart = $txtLog.TextLength
    $txtLog.SelectionLength = 0
    $txtLog.SelectionColor = [System.Drawing.ColorTranslator]::FromHtml("#64748B")
    $txtLog.AppendText("[$timestamp] ")

    $txtLog.SelectionColor = $color
    $txtLog.AppendText("[$Tipo] $Mensaje`n")
    $txtLog.ScrollToCaret()
    [System.Windows.Forms.Application]::DoEvents()
}

$btnLimpiarLog.Add_Click({
    $txtLog.Clear()
    Log-Msg "Registro de consola reiniciado." "INFO"
})

# Funcion Wrapper para ejecutar acciones con animacion de progreso
function Run-Task {
    param (
        [string]$NombreTarea,
        [scriptblock]$Accion
    )
    $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Marquee
    $progressBar.MarqueeAnimationSpeed = 30
    Log-Msg "Iniciando: $NombreTarea..." "INFO"
    [System.Windows.Forms.Application]::DoEvents()

    try {
        & $Accion
        Log-Msg "Finalizado con exito: $NombreTarea" "SUCCESS"
    } catch {
        Log-Msg "Error en '$NombreTarea': $_" "ERROR"
    } finally {
        $progressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Blocks
        $progressBar.Value = 0
        [System.Windows.Forms.Application]::DoEvents()
    }
}

# 6. Panel Central con Pestanas (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = [System.Windows.Forms.DockStyle]::Fill
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

function Crear-Boton {
    param(
        [string]$Texto,
        [int]$X,
        [int]$Y,
        [int]$Ancho = 420,
        [int]$Alto = 48,
        [System.Drawing.Color]$ColorBoton = $colorBtn,
        [scriptblock]$OnClick
    )
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $Texto
    $btn.Location = New-Object System.Drawing.Point($X, $Y)
    $btn.Size = New-Object System.Drawing.Size($Ancho, $Alto)
    $btn.BackColor = $ColorBoton
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btn.FlatAppearance.BorderSize = 0
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    if ($OnClick) { $btn.Add_Click($OnClick) }
    return $btn
}

# ----------------- PESTANA 1: ACCESO RAPIDO -----------------
$tabRapido = New-Object System.Windows.Forms.TabPage
$tabRapido.Text = "  Acceso Rapido  "
$tabRapido.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")

$lblDescRapida = New-Object System.Windows.Forms.Label
$lblDescRapida.Text = "Operaciones de mantenimiento frecuentes en 1 clic:"
$lblDescRapida.Location = New-Object System.Drawing.Point(30, 20)
$lblDescRapida.AutoSize = $true
$lblDescRapida.ForeColor = [System.Drawing.ColorTranslator]::FromHtml("#94A3B8")
$tabRapido.Controls.Add($lblDescRapida)

# Boton 20: Mantenimiento Total
$btnTotal = Crear-Boton ">> Mantenimiento Total (Express)" 30 55 420 54 $colorBtnSuccess {
    Run-Task "Mantenimiento Total (Auto-Ejecucion)" {
        Log-Msg "Purgando temporales y prefetch..." "INFO"
        @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object {
            if (Test-Path $_) { Remove-Item -Path "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }
        }
        Log-Msg "Vaciando papelera..." "INFO"
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Log-Msg "Vaciando cache DNS..." "INFO"
        ipconfig /flushdns | Out-Null
    }
}
$tabRapido.Controls.Add($btnTotal)

# Boton 1: Limpiar Temporales y Prefetch
$btnTemp = Crear-Boton "Limpiar Temporales y Prefetch" 30 120 420 48 $colorBtn {
    Run-Task "Limpieza de Temporales y Prefetch" {
        @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object {
            if (Test-Path $_) {
                Remove-Item -Path "$_\*" -Recurse -Force -ErrorAction SilentlyContinue
                Log-Msg "Limpia carpeta: $_" "SUCCESS"
            }
        }
    }
}
$tabRapido.Controls.Add($btnTemp)

# Boton 2: Vaciar Papelera
$btnPapelera = Crear-Boton "Vaciar Papelera de Reciclaje" 30 180 420 48 $colorBtn {
    Run-Task "Vaciado de Papelera" {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }
}
$tabRapido.Controls.Add($btnPapelera)

# Boton 16: Monitor Top RAM/CPU
$btnRam = Crear-Boton "Top 5 Procesos con Mayor Consumo RAM" 480 55 420 54 $colorBtnPurple {
    Run-Task "Consulta de Procesos en RAM" {
        $top = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, @{Name="RAM_MB";Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
        foreach ($p in $top) {
            Log-Msg "Proceso: $($p.Name) -> $($p.RAM_MB) MB" "INFO"
        }
    }
}
$tabRapido.Controls.Add($btnRam)

# Boton 9: Limpiar DNS
$btnDnsRapido = Crear-Boton "Limpiar DNS y Renovar IP" 480 120 420 48 $colorBtn {
    Run-Task "Renovacion de Pila de Red" {
        ipconfig /flushdns | Out-Null
        Log-Msg "Flush DNS completado." "SUCCESS"
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
        Log-Msg "IP renovada con exito." "SUCCESS"
    }
}
$tabRapido.Controls.Add($btnDnsRapido)

# Boton 15: Punto de Restauracion
$btnRestoreRapido = Crear-Boton "Crear Punto de Restauracion" 480 180 420 48 $colorBtnWarn {
    Run-Task "Punto de Restauracion del Sistema" {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "WinOptimizador_Restore" -RestorePointType "MODIFY_SETTINGS"
    }
}
$tabRapido.Controls.Add($btnRestoreRapido)

$tabControl.Controls.Add($tabRapido)

# ----------------- PESTANA 2: LIMPIEZA & ARCHIVOS -----------------
$tabLimpieza = New-Object System.Windows.Forms.TabPage
$tabLimpieza.Text = "  Limpieza y Archivos  "
$tabLimpieza.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")

# Boton 3: Cache Windows Update
$btnUpd = Crear-Boton "Limpiar Cache de Windows Update" 30 30 420 48 $colorBtn {
    Run-Task "Cache de Windows Update" {
        Log-Msg "Deteniendo servicio de actualizacion wuauserv..." "INFO"
        Stop-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name wuauserv -Force -ErrorAction SilentlyContinue
    }
}
$tabLimpieza.Controls.Add($btnUpd)

# Boton 4: Logs
$btnLogs = Crear-Boton "Eliminar Archivos de Log (.log)" 30 90 420 48 $colorBtn {
    Run-Task "Eliminacion de Logs Antiguos" {
        Get-ChildItem -Path "C:\Windows" -Filter "*.log" -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }
}
$tabLimpieza.Controls.Add($btnLogs)

# Boton 5: Portapapeles
$btnClip = Crear-Boton "Limpiar Historial de Portapapeles" 30 150 420 48 $colorBtn {
    Run-Task "Vaciado del Portapapeles" {
        Set-Clipboard -Value $null
    }
}
$tabLimpieza.Controls.Add($btnClip)

# Boton 6: Defrag/ReTrim
$btnTrim = Crear-Boton "Optimizar Volumen C: (ReTrim SSD/HDD)" 30 210 420 48 $colorBtn {
    Run-Task "Optimizacion de Volumen C:" {
        Optimize-Volume -DriveLetter C -ReTrim -Verbose -ErrorAction SilentlyContinue
    }
}
$tabLimpieza.Controls.Add($btnTrim)

# Boton 7: Organizar Escritorio
$btnOrgDesk = Crear-Boton "Organizar Escritorio por Extensiones" 480 30 420 48 $colorBtn {
    Run-Task "Organizar Archivos del Escritorio" {
        $rutaEscritorio = [Environment]::GetFolderPath("Desktop")
        $archivos = Get-ChildItem -Path $rutaEscritorio -File | Where-Object { $_.Extension -ne ".lnk" -and $_.Extension -ne "" }
        foreach ($arch in $archivos) {
            $ext = $arch.Extension.TrimStart('.')
            $dir = Join-Path $rutaEscritorio $ext
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
            Move-Item $arch.FullName -Destination $dir -Force
            Log-Msg "Movido '$($arch.Name)' a carpeta '$ext'" "INFO"
        }
    }
}
$tabLimpieza.Controls.Add($btnOrgDesk)

# Boton 8: Organizar Descargas
$btnOrgDown = Crear-Boton "Organizar Carpeta Descargas" 480 90 420 48 $colorBtn {
    Run-Task "Organizar Archivos de Descargas" {
        $rutaDescargas = Join-Path $env:USERPROFILE "Downloads"
        $archivos = Get-ChildItem -Path $rutaDescargas -File | Where-Object { $_.Extension -ne "" }
        foreach ($arch in $archivos) {
            $ext = $arch.Extension.TrimStart('.')
            $dir = Join-Path $rutaDescargas $ext
            if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
            Move-Item $arch.FullName -Destination $dir -Force
            Log-Msg "Movido '$($arch.Name)' a carpeta '$ext'" "INFO"
        }
    }
}
$tabLimpieza.Controls.Add($btnOrgDown)

$tabControl.Controls.Add($tabLimpieza)

# ----------------- PESTANA 3: RED & CONECTIVIDAD -----------------
$tabRed = New-Object System.Windows.Forms.TabPage
$tabRed.Text = "  Red y Conectividad  "
$tabRed.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")

# Boton 9: DNS / IP
$btnDns = Crear-Boton "Limpiar DNS y Renovar IP" 30 30 420 48 $colorBtn {
    Run-Task "Flush DNS y Renovacion IP" {
        ipconfig /flushdns | Out-Null
        ipconfig /release | Out-Null
        ipconfig /renew | Out-Null
    }
}
$tabRed.Controls.Add($btnDns)

# Boton 10: Winsock Reset
$btnWinsock = Crear-Boton "Restablecer Winsock (Requiere Reinicio)" 30 90 420 48 $colorBtnWarn {
    Run-Task "Restablecimiento de Winsock" {
        netsh winsock reset | Out-Null
        Log-Msg "Winsock restablecido. Se recomienda reiniciar el equipo." "WARN"
    }
}
$tabRed.Controls.Add($btnWinsock)

# Boton 21: DHCP Wi-Fi (Fase 1)
$btnDhcp = Crear-Boton "Configurar Wi-Fi a DHCP Dinamico" 30 150 420 48 $colorBtn {
    Run-Task "Estandarizacion DHCP en Wi-Fi" {
        $NIC = "Wi-Fi"
        netsh interface ip set address name=$NIC source=dhcp | Out-Null
        netsh interface ip set dns name=$NIC source=dhcp | Out-Null
        $check = netsh interface ip show config name=$NIC | Select-String -Pattern "DHCP"
        if ($check) {
            Log-Msg "Tarjeta $NIC configurada a DHCP con exito." "SUCCESS"
        } else {
            Log-Msg "No se pudo cambiar. Verifique si la tarjeta se llama '$NIC'." "WARN"
        }
    }
}
$tabRed.Controls.Add($btnDhcp)

$tabControl.Controls.Add($tabRed)

# ----------------- PESTANA 4: DIAGNOSTICO & SALUD -----------------
$tabDiag = New-Object System.Windows.Forms.TabPage
$tabDiag.Text = "  Diagnostico y Reparacion  "
$tabDiag.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")

# Boton 11: SFC
$btnSfc = Crear-Boton "Escanear Sistema (SFC /scannow)" 30 30 420 48 $colorBtn {
    Run-Task "Auditoria de Archivos de Sistema (SFC)" {
        Log-Msg "Iniciando sfc /scannow (este proceso puede tardar)..." "INFO"
        sfc /scannow
    }
}
$tabDiag.Controls.Add($btnSfc)

# Boton 12: DISM
$btnDism = Crear-Boton "Reparar Imagen de Windows (DISM)" 30 90 420 48 $colorBtn {
    Run-Task "Reparacion de Imagen con DISM" {
        Log-Msg "Iniciando DISM RestoreHealth..." "INFO"
        DISM /Online /Cleanup-Image /RestoreHealth
    }
}
$tabDiag.Controls.Add($btnDism)

# Boton 13: CHKDSK
$btnChkdsk = Crear-Boton "Comprobar Errores de Disco (CHKDSK)" 30 150 420 48 $colorBtn {
    Run-Task "Comprobacion de Disco CHKDSK C:" {
        chkdsk C:
    }
}
$tabDiag.Controls.Add($btnChkdsk)

# Boton 14: WSReset
$btnWsReset = Crear-Boton "Restablecer Microsoft Store (WSReset)" 480 30 420 48 $colorBtn {
    Run-Task "Restablecimiento de Microsoft Store (wsreset)" {
        wsreset.exe
    }
}
$tabDiag.Controls.Add($btnWsReset)

# Boton 17: DXDIAG
$btnDxdiag = Crear-Boton "Exportar Info del Sistema (DxDiag)" 480 90 420 48 $colorBtn {
    Run-Task "Exportacion de Reporte DxDiag" {
        $ruta = Join-Path ([Environment]::GetFolderPath("Desktop")) "InfoSistema.txt"
        dxdiag /t $ruta
        Log-Msg "Reporte generado en: $ruta" "SUCCESS"
    }
}
$tabDiag.Controls.Add($btnDxdiag)

$tabControl.Controls.Add($tabDiag)

# ----------------- PESTANA 5: SISTEMA & SERVICIOS -----------------
$tabSys = New-Object System.Windows.Forms.TabPage
$tabSys.Text = "  Sistema y Servicios  "
$tabSys.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#0F172A")

# Boton 18: Hibernacion Activar/Desactivar
$btnHibOn = Crear-Boton "Habilitar Hibernacion" 30 30 200 48 $colorBtnSuccess {
    Run-Task "Habilitar Hibernacion" {
        powercfg.exe /hibernate on
    }
}
$tabSys.Controls.Add($btnHibOn)

$btnHibOff = Crear-Boton "Deshabilitar Hibernacion" 240 30 210 48 $colorBtnDanger {
    Run-Task "Deshabilitar Hibernacion (Libera hiberfil.sys)" {
        powercfg.exe /hibernate off
    }
}
$tabSys.Controls.Add($btnHibOff)

# Boton 19: Telemetria
$btnTelem = Crear-Boton "Deshabilitar Telemetria Basica (DiagTrack)" 30 90 420 48 $colorBtnWarn {
    Run-Task "Deshabilitacion de Telemetria" {
        Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
        Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
$tabSys.Controls.Add($btnTelem)

# Boton 22: Spooler
$btnSpooler = Crear-Boton "Deshabilitar Spooler de Impresion" 30 150 420 48 $colorBtnDanger {
    Run-Task "Desactivacion de Cola de Impresion" {
        Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue
        Set-Service -Name Spooler -StartupType Disabled -ErrorAction SilentlyContinue
    }
}
$tabSys.Controls.Add($btnSpooler)

# Boton 15: Punto Restauracion
$btnRestore = Crear-Boton "Crear Punto de Restauracion" 480 30 420 48 $colorBtn {
    Run-Task "Creando Punto de Restauracion" {
        Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "WinOptimizador_Restore" -RestorePointType "MODIFY_SETTINGS"
    }
}
$tabSys.Controls.Add($btnRestore)

$tabControl.Controls.Add($tabSys)

$form.Controls.Add($tabControl)

# 7. Saludo inicial al cargar el Form
$form.Add_Shown({
    Log-Msg "Win-Optimizador Pro (GUI) iniciado correctamente." "SUCCESS"
    Log-Msg "Seleccione una pestana y presione cualquier boton para ejecutar una tarea." "INFO"
    Log-Msg "Equipo: $env:COMPUTERNAME | Usuario: $env:USERNAME" "INFO"
})

# 8. Mostrar la Ventana
[void]$form.ShowDialog()
