/**
 * Win-Optimizador Pro v2.0 - Lógica de Interfaz y Comunicación
 */

// Catálogo completo de las 22 herramientas
const MODULOS = [
  // --- LIMPIEZA Y ESPACIO (1-8) ---
  {
    id: "01",
    cat: "limpieza",
    catName: "Limpieza",
    icon: "🧹",
    title: "Limpiar Temporales y Prefetch",
    desc: "Elimina archivos residuales en Temp y Prefetch que ralentizan el arranque y ocupan espacio.",
    btnText: "Limpiar Basura"
  },
  {
    id: "02",
    cat: "limpieza",
    catName: "Limpieza",
    icon: "🗑️",
    title: "Vaciar Papelera de Reciclaje",
    desc: "Purga de forma definitiva todos los archivos eliminados de todas las unidades del equipo.",
    btnText: "Vaciar Papelera"
  },
  {
    id: "03",
    cat: "limpieza",
    catName: "Limpieza",
    icon: "🔄",
    title: "Limpiar Caché de Windows Update",
    desc: "Detiene el servicio wuauserv y elimina descargas corruptas para solucionar errores de actualización.",
    btnText: "Purgar Caché"
  },
  {
    id: "04",
    cat: "limpieza",
    catName: "Limpieza",
    icon: "📄",
    title: "Eliminar Archivos de Log (.log)",
    desc: "Localiza y elimina archivos de registro históricos en Windows para recuperar valiosos gigabytes.",
    btnText: "Borrar Logs"
  },
  {
    id: "05",
    cat: "limpieza",
    catName: "Limpieza",
    icon: "📋",
    title: "Limpiar Historial del Portapapeles",
    desc: "Borra textos e imágenes copiados en memoria para proteger tu privacidad e información sensible.",
    btnText: "Borrar Portapapeles"
  },
  {
    id: "06",
    cat: "limpieza",
    catName: "Limpieza",
    icon: "⚡",
    title: "Optimizar y Desfragmentar Disco (C:)",
    desc: "Ejecuta TRIM en discos SSD o desfragmenta unidades mecánicas HDD para máxima velocidad.",
    btnText: "Optimizar Disco"
  },
  {
    id: "07",
    cat: "limpieza",
    catName: "Organización",
    icon: "📂",
    title: "Organizar Escritorio Automáticamente",
    desc: "Clasifica archivos sueltos del Escritorio en carpetas organizadas por formato (.pdf, .exe, etc.).",
    btnText: "Organizar Escritorio"
  },
  {
    id: "08",
    cat: "limpieza",
    catName: "Organización",
    icon: "📥",
    title: "Organizar Carpeta de Descargas",
    desc: "Ordena los ficheros de tu carpeta Descargas en subcarpetas según su extensión automáticamente.",
    btnText: "Organizar Descargas"
  },
  {
    id: "23",
    cat: "limpieza",
    catName: "Limpieza",
    icon: "🔍",
    title: "Analizar y Liberar Archivos Pesados",
    desc: "Detecta qué archivos consumen más espacio (>10MB). Te permite visualizarlos, seleccionarlos y eliminarlos para recuperar almacenamiento.",
    btnText: "Analizar Archivos"
  },

  // --- RED Y CONECTIVIDAD (9, 10, 21) ---
  {
    id: "09",
    cat: "red",
    catName: "Red e Internet",
    icon: "📶",
    title: "Limpiar DNS y Renovar Conexión IP",
    desc: "Vacía la caché de navegación y renueva la dirección IP con tu router para resolver lentitud.",
    btnText: "Renovar Red"
  },
  {
    id: "10",
    cat: "red",
    catName: "Red e Internet",
    icon: "🔄",
    title: "Restablecer Adaptadores (Winsock)",
    desc: "Restaura la configuración de fábrica de los sockets TCP/IP. Corrige bloqueos de conexión.",
    btnText: "Reset Winsock"
  },
  {
    id: "21",
    cat: "red",
    catName: "Red e Internet",
    icon: "⚙️",
    title: "Configurar Red a DHCP Automático",
    desc: "Fase 1: Configura tu adaptador Wi-Fi/Ethernet a recepción dinámica de IP y servidores DNS.",
    btnText: "Configurar DHCP"
  },

  // --- SALUD Y REPARACIÓN (11 - 14) ---
  {
    id: "11",
    cat: "diag",
    catName: "Diagnóstico",
    icon: "🔍",
    title: "Escanear Archivos del Sistema (SFC)",
    desc: "Examina y repara archivos corruptos o dañados de Windows mediante 'sfc /scannow'.",
    btnText: "Escanear SFC"
  },
  {
    id: "12",
    cat: "diag",
    catName: "Diagnóstico",
    icon: "🩺",
    title: "Reparar Imagen de Windows (DISM)",
    desc: "Descarga componentes limpios desde Windows Update para reconstruir la imagen del sistema.",
    btnText: "Reparar DISM"
  },
  {
    id: "13",
    cat: "diag",
    catName: "Diagnóstico",
    icon: "💽",
    title: "Comprobar Errores de Disco (CHKDSK)",
    desc: "Audita la unidad C: en modo seguro para identificar sectores dañados o fallos en NTFS.",
    btnText: "Analizar CHKDSK"
  },
  {
    id: "14",
    cat: "diag",
    catName: "Diagnóstico",
    icon: "🏪",
    title: "Restablecer Tienda de Microsoft (WSReset)",
    desc: "Limpia la caché de Microsoft Store para resolver cierres inesperados o errores de descarga.",
    btnText: "Restablecer Tienda"
  },

  // --- SISTEMA Y PRIVACIDAD (15 - 19, 22) ---
  {
    id: "15",
    cat: "sistema",
    catName: "Seguridad",
    icon: "🛡️",
    title: "Crear Punto de Restauración",
    desc: "Guarda una copia del estado actual del sistema para revertir cualquier problema en el futuro.",
    btnText: "Crear Punto"
  },
  {
    id: "16",
    cat: "sistema",
    catName: "Monitoreo",
    icon: "📊",
    title: "Monitor de Procesos (Top 5 en RAM/CPU)",
    desc: "Lista en la consola los 5 programas que más memoria y procesador consumen en este momento.",
    btnText: "Ver Consumo"
  },
  {
    id: "17",
    cat: "sistema",
    catName: "Diagnóstico",
    icon: "📑",
    title: "Exportar Informe Técnico (DXDiag)",
    desc: "Genera un archivo 'InfoSistema.txt' en tu Escritorio con especificaciones de hardware y drivers.",
    btnText: "Exportar DXDiag"
  },
  {
    id: "18",
    cat: "sistema",
    catName: "Energía",
    icon: "⚡",
    title: "Gestionar Hibernación (On / Off)",
    desc: "Habilita el inicio rápido o desactívala para eliminar hiberfil.sys y ganar varios GB en C:.",
    btnText: "Configurar Hibernación"
  },
  {
    id: "19",
    cat: "sistema",
    catName: "Privacidad",
    icon: "🔒",
    title: "Deshabilitar Telemetría Básica",
    desc: "Detiene y desactiva el servicio de rastreo DiagTrack para mayor privacidad y rendimiento.",
    btnText: "Bloquear Telemetría"
  },
  {
    id: "22",
    cat: "sistema",
    catName: "Servicios",
    icon: "🖨️",
    title: "Deshabilitar Cola de Impresión (Spooler)",
    desc: "Fase 2: Desactiva el servicio Spooler si no utilizas impresoras para ahorrar memoria RAM.",
    btnText: "Desactivar Spooler"
  },

  // --- MANTENIMIENTO TOTAL (20) ---
  {
    id: "20",
    cat: "auto",
    catName: "Automático",
    icon: "🚀",
    title: "Mantenimiento Total (Auto-Ejecución)",
    desc: "Secuencia automatizada en 1 solo paso: purga temporales, vacía papelera y renueva DNS.",
    btnText: "Ejecutar Mantenimiento"
  }
];

// Estado global de la aplicación
let categoriaActual = "all";
let terminoBusqueda = "";
let ejecutandoTarea = false;

// Elementos DOM
const cardsGrid = document.getElementById("cards-grid");
const searchInput = document.getElementById("search-input");
const clearSearchBtn = document.getElementById("clear-search");
const sectionTitle = document.getElementById("section-title");
const sectionDesc = document.getElementById("section-desc");
const resultsCounter = document.getElementById("results-counter");
const heroBanner = document.getElementById("hero-banner");
const navButtons = document.querySelectorAll(".nav-item");

const consoleOutput = document.getElementById("console-output");
const consoleLoader = document.getElementById("console-loader");
const taskBadge = document.getElementById("current-task-badge");
const consoleDrawer = document.getElementById("console-drawer");

// Inicialización
document.addEventListener("DOMContentLoaded", () => {
  renderizarTarjetas();
  configurarEventos();
  obtenerTelemetria();

  // Actualizar telemetría cada 4 segundos
  setInterval(obtenerTelemetria, 4000);
});

// Renderizar tarjetas con filtrado de categoría y búsqueda
function renderizarTarjetas() {
  cardsGrid.innerHTML = "";

  const filtrados = MODULOS.filter(m => {
    // Filtro de categoría
    const pasaCategoria = (categoriaActual === "all") || (m.cat === categoriaActual);
    if (!pasaCategoria) return false;

    // Filtro de búsqueda
    if (!terminoBusqueda) return true;
    const term = terminoBusqueda.toLowerCase();
    return m.title.toLowerCase().includes(term) ||
           m.desc.toLowerCase().includes(term) ||
           m.id.includes(term) ||
           m.catName.toLowerCase().includes(term);
  });

  resultsCounter.textContent = `Mostrando ${filtrados.length} herramienta(s)`;

  // Mostrar u ocultar el Hero Banner si estamos en categoría 'auto' o 'all'
  if (categoriaActual === "auto") {
    heroBanner.style.display = "block";
  } else if (categoriaActual === "all" && !terminoBusqueda) {
    heroBanner.style.display = "block";
  } else {
    heroBanner.style.display = "none";
  }

  if (filtrados.length === 0) {
    cardsGrid.innerHTML = `
      <div style="grid-column: 1 / -1; text-align: center; padding: 40px; color: var(--text-dark);">
        <p style="font-size: 32px; margin-bottom: 8px;">🔍</p>
        <p style="font-size: 15px; color: var(--text-muted); font-weight: 600;">No se encontraron herramientas para "${terminoBusqueda}"</p>
        <p style="font-size: 12px; margin-top: 4px;">Intenta buscar por 'temporales', 'dns', 'disco', 'sfc' o 'ram'.</p>
      </div>
    `;
    return;
  }

  filtrados.forEach(m => {
    const card = document.createElement("div");
    card.className = "card";
    card.id = `card-${m.id}`;

    card.innerHTML = `
      <div>
        <div class="card-top">
          <span class="card-num-badge">#${m.id}</span>
          <div class="card-title-box">
            <h3 class="card-title">${m.icon} ${m.title}</h3>
            <p class="card-desc">${m.desc}</p>
          </div>
        </div>
      </div>
      <div class="card-bottom">
        <span class="card-category-tag">${m.catName}</span>
        <button class="btn-card" data-id="${m.id}" id="btn-action-${m.id}">
          <span>${m.btnText}</span>
          <span class="btn-arrow">→</span>
        </button>
      </div>
    `;

    const btn = card.querySelector(".btn-card");
    btn.addEventListener("click", () => ejecutarModulo(m));

    cardsGrid.appendChild(card);
  });
}

// Configuración de listeners
function configurarEventos() {
  // Navegación Sidebar
  navButtons.forEach(btn => {
    btn.addEventListener("click", () => {
      navButtons.forEach(b => b.classList.remove("active"));
      btn.classList.add("active");

      categoriaActual = btn.getAttribute("data-cat");
      actualizarEncabezadoSeccion(btn);
      renderizarTarjetas();
    });
  });

  // Búsqueda en tiempo real
  searchInput.addEventListener("input", (e) => {
    terminoBusqueda = e.target.value.trim();
    clearSearchBtn.style.display = terminoBusqueda ? "block" : "none";
    renderizarTarjetas();
  });

  clearSearchBtn.addEventListener("click", () => {
    searchInput.value = "";
    terminoBusqueda = "";
    clearSearchBtn.style.display = "none";
    searchInput.focus();
    renderizarTarjetas();
  });

  // Botón Hero 1-Clic
  document.getElementById("btn-run-hero").addEventListener("click", () => {
    const moduloAuto = MODULOS.find(m => m.id === "20");
    if (moduloAuto) ejecutarModulo(moduloAuto);
  });

  // Refresco manual de métricas
  document.getElementById("btn-refresh").addEventListener("click", () => {
    obtenerTelemetria(true);
  });

  // Acciones de consola
  document.getElementById("btn-clear-log").addEventListener("click", () => {
    consoleOutput.innerHTML = `<div class="log-line log-gray">[${obtenerHora()}] Registro limpiado.</div>`;
  });

  document.getElementById("btn-copy-log").addEventListener("click", () => {
    navigator.clipboard.writeText(consoleOutput.innerText).then(() => {
      agregarLog("Registro copiado al portapapeles.", "SUCCESS");
    });
  });

  document.getElementById("btn-toggle-console").addEventListener("click", () => {
    consoleDrawer.classList.toggle("collapsed");
    const isCol = consoleDrawer.classList.contains("collapsed");
    document.getElementById("btn-toggle-console").textContent = isCol ? "🔼" : "🔽";
  });

  // Modal de Hibernación (Opción 18)
  document.getElementById("btn-hib-on").addEventListener("click", () => {
    cerrarModalHibernacion();
    enviarPeticionEjecucion("18", "on");
  });
  document.getElementById("btn-hib-off").addEventListener("click", () => {
    cerrarModalHibernacion();
    enviarPeticionEjecucion("18", "off");
  });
  document.getElementById("btn-hib-cancel").addEventListener("click", cerrarModalHibernacion);

  // Modal Analizador de Archivos Pesados (Opción 23)
  document.getElementById("btn-close-scanner").addEventListener("click", cerrarModalArchivosPesados);
  document.getElementById("btn-scanner-cancel").addEventListener("click", cerrarModalArchivosPesados);
  document.getElementById("btn-rescan-files").addEventListener("click", escanearArchivosPesados);
  document.getElementById("check-select-all").addEventListener("change", (e) => alternarSeleccionarTodos(e.target.checked));
  document.getElementById("btn-delete-selected").addEventListener("click", eliminarArchivosSeleccionados);
}

function actualizarEncabezadoSeccion(btn) {
  const cat = btn.getAttribute("data-cat");
  switch (cat) {
    case "limpieza":
      sectionTitle.textContent = "🧹 Módulos de Limpieza y Rendimiento";
      sectionDesc.textContent = "Purga de temporales, optimización de volumen, vaciado de papelera y ordenación de archivos.";
      break;
    case "red":
      sectionTitle.textContent = "🌐 Red, Conectividad y Adaptadores";
      sectionDesc.textContent = "Diagnóstico de conexión, limpieza DNS, renovación de IP y estandarización a DHCP.";
      break;
    case "diag":
      sectionTitle.textContent = "🩺 Diagnóstico y Salud del Sistema Operativo";
      sectionDesc.textContent = "Reparación de archivos críticos de Windows (SFC, DISM) e integridad de sectores de disco.";
      break;
    case "sistema":
      sectionTitle.textContent = "🛡️ Sistema, Privacidad y Servicios";
      sectionDesc.textContent = "Puntos de restauración, monitor en vivo, informe DXDiag y optimización de servicios de fondo.";
      break;
    case "auto":
      sectionTitle.textContent = "🚀 Modo Rápido (1-Clic)";
      sectionDesc.textContent = "Rutina automatizada especialmente diseñada para usuarios que buscan rapidez sin complicaciones.";
      break;
    default:
      sectionTitle.textContent = "Todos los Módulos de Mantenimiento";
      sectionDesc.textContent = "Explora y ejecuta cualquiera de las 23 herramientas integradas con un solo clic.";
  }
}

// Ejecución de un módulo
function ejecutarModulo(m) {
  if (ejecutandoTarea) {
    agregarLog("Ya hay una tarea en ejecución. Por favor espere a que finalice.", "WARN");
    return;
  }

  // Si es la opción 18 (Hibernación), abrir diálogo personalizado
  if (m.id === "18") {
    abrirModalHibernacion();
    return;
  }

  // Si es la opción 23 (Archivos Pesados), abrir diálogo analizador
  if (m.id === "23") {
    abrirModalArchivosPesados();
    return;
  }

  enviarPeticionEjecucion(m.id);
}

function abrirModalHibernacion() {
  document.getElementById("modal-hibernacion").classList.add("active");
}

function cerrarModalHibernacion() {
  document.getElementById("modal-hibernacion").classList.remove("active");
}

// Estado y funciones del Analizador de Archivos Pesados (Opción 23)
let archivosEncontrados = [];
let rutasSeleccionadas = new Set();

function abrirModalArchivosPesados() {
  const modal = document.getElementById("modal-archivos-pesados");
  modal.classList.add("active");
  document.getElementById("freed-report-banner").style.display = "none";
  escanearArchivosPesados();
}

function cerrarModalArchivosPesados() {
  document.getElementById("modal-archivos-pesados").classList.remove("active");
}

async function escanearArchivosPesados() {
  const loading = document.getElementById("scanner-loading");
  const scrollList = document.getElementById("files-scroll-list");
  const emptyState = document.getElementById("scanner-empty");
  const btnDelete = document.getElementById("btn-delete-selected");
  const checkAll = document.getElementById("check-select-all");
  
  loading.style.display = "flex";
  scrollList.style.display = "none";
  emptyState.style.display = "none";
  btnDelete.disabled = true;
  checkAll.checked = false;
  rutasSeleccionadas.clear();
  actualizarResumenSeleccion();

  try {
    const res = await fetch("/api/scan-large-files");
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    archivosEncontrados = await res.json();
    loading.style.display = "none";

    if (!archivosEncontrados || archivosEncontrados.length === 0) {
      emptyState.style.display = "flex";
      return;
    }

    renderizarListaArchivos();
    scrollList.style.display = "flex";
  } catch (err) {
    loading.style.display = "none";
    agregarLog(`Error al escanear archivos pesados: ${err.message}`, "ERROR");
  }
}

function renderizarListaArchivos() {
  const scrollList = document.getElementById("files-scroll-list");
  scrollList.innerHTML = "";

  archivosEncontrados.forEach(f => {
    const item = document.createElement("div");
    item.className = "file-card-item";
    if (rutasSeleccionadas.has(f.path)) {
      item.classList.add("selected");
    }

    let icono = "📄";
    if (f.type === "video") icono = "🎬";
    else if (f.type === "archive") icono = "📦";
    else if (f.type === "app") icono = "⚙️";
    else if (f.type === "document") icono = "📑";

    const esGB = f.sizeText.includes("GB");

    item.innerHTML = `
      <input type="checkbox" ${rutasSeleccionadas.has(f.path) ? "checked" : ""}>
      <div class="file-icon-badge">${icono}</div>
      <div class="file-info" title="${f.path}">
        <span class="file-name">${f.name}</span>
        <span class="file-path">${f.path}</span>
      </div>
      <span class="file-size-badge ${esGB ? 'gb-size' : ''}">${f.sizeText}</span>
    `;

    const chk = item.querySelector("input[type='checkbox']");

    // Click en la fila alterna selección
    item.addEventListener("click", (e) => {
      if (e.target !== chk) {
        chk.checked = !chk.checked;
      }
      if (chk.checked) {
        rutasSeleccionadas.add(f.path);
        item.classList.add("selected");
      } else {
        rutasSeleccionadas.delete(f.path);
        item.classList.remove("selected");
      }
      actualizarResumenSeleccion();
    });

    scrollList.appendChild(item);
  });
}

function alternarSeleccionarTodos(seleccionar) {
  rutasSeleccionadas.clear();
  if (seleccionar) {
    archivosEncontrados.forEach(f => rutasSeleccionadas.add(f.path));
  }

  // Actualizar checkboxes visualmente
  const scrollList = document.getElementById("files-scroll-list");
  const items = scrollList.querySelectorAll(".file-card-item");
  items.forEach((item, idx) => {
    const f = archivosEncontrados[idx];
    const chk = item.querySelector("input[type='checkbox']");
    if (chk) chk.checked = seleccionar;
    if (seleccionar) {
      item.classList.add("selected");
    } else {
      item.classList.remove("selected");
    }
  });

  actualizarResumenSeleccion();
}

function actualizarResumenSeleccion() {
  const btnDelete = document.getElementById("btn-delete-selected");
  const counter = document.getElementById("selection-counter");
  const checkAll = document.getElementById("check-select-all");
  const count = rutasSeleccionadas.size;

  let totalBytes = 0;
  archivosEncontrados.forEach(f => {
    if (rutasSeleccionadas.has(f.path)) {
      totalBytes += f.sizeBytes;
    }
  });

  const mb = (totalBytes / (1024 * 1024)).toFixed(1);
  const gb = (totalBytes / (1024 * 1024 * 1024)).toFixed(2);
  const txtTam = gb >= 1 ? `${gb} GB` : `${mb} MB`;

  counter.textContent = `${count} seleccionados (${txtTam})`;
  btnDelete.disabled = count === 0;

  if (count === 0) {
    checkAll.checked = false;
    checkAll.indeterminate = false;
  } else if (count === archivosEncontrados.length && archivosEncontrados.length > 0) {
    checkAll.checked = true;
    checkAll.indeterminate = false;
  } else {
    checkAll.checked = false;
    checkAll.indeterminate = true;
  }
}

async function eliminarArchivosSeleccionados() {
  if (rutasSeleccionadas.size === 0) return;

  const count = rutasSeleccionadas.size;
  const confirmar = confirm(`¿Estás seguro de que deseas eliminar permanentemente los ${count} archivo(s) seleccionados?`);
  if (!confirmar) return;

  const btnDelete = document.getElementById("btn-delete-selected");
  btnDelete.disabled = true;
  btnDelete.innerHTML = `<span>⏳ Liberando espacio...</span>`;

  const rutasArray = Array.from(rutasSeleccionadas);
  agregarLog(`--- Liberando espacio en disco (${rutasArray.length} archivos seleccionados) ---`, "INFO");

  try {
    const res = await fetch("/api/delete-files", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(rutasArray)
    });

    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const data = await res.json();

    // Mostrar banner de reporte de almacenamiento liberado
    const banner = document.getElementById("freed-report-banner");
    document.getElementById("freed-report-title").textContent = `🎉 ¡Almacenamiento liberado exitosamente!`;
    document.getElementById("freed-report-desc").textContent = `Se eliminaron ${data.borrados} archivo(s) y se recuperaron ${data.textoLiberado} de espacio en tu disco C:.`;
    banner.style.display = "flex";

    // Registrar en la consola
    agregarLog(`✔ Se eliminaron ${data.borrados} archivo(s). Espacio recuperado en disco: ${data.textoLiberado}`, "SUCCESS");

    // Limpiar selección y re-escanear
    rutasSeleccionadas.clear();
    obtenerTelemetria(true);
    await escanearArchivosPesados();

  } catch (err) {
    agregarLog(`Error al eliminar archivos: ${err.message}`, "ERROR");
  } finally {
    btnDelete.innerHTML = `<span class="btn-icon">🗑️</span> <span id="btn-delete-label">Eliminar Seleccionados</span>`;
  }
}

// Enviar solicitud de ejecución a la API de PowerShell
async function enviarPeticionEjecucion(id, param = "") {
  const m = MODULOS.find(item => item.id === id);
  const btn = document.getElementById(`btn-action-${id}`);

  ejecutandoTarea = true;
  taskBadge.textContent = `Ejecutando: #${id} ${m ? m.title.substring(0, 20) + "..." : ""}`;
  consoleLoader.classList.add("active");

  if (btn) {
    btn.classList.add("running");
    btn.innerHTML = `<span>⏳ Procesando...</span>`;
  }

  // Asegurar que la consola no esté colapsada
  consoleDrawer.classList.remove("collapsed");
  document.getElementById("btn-toggle-console").textContent = "🔽";

  agregarLog(`--- Iniciando Operación #${id}: ${m ? m.title : ''} ---`, "INFO");

  try {
    const respuesta = await fetch(`/api/run?id=${id}&param=${encodeURIComponent(param)}`);

    if (!respuesta.ok) {
      throw new Error(`HTTP Error ${respuesta.status}`);
    }

    const resultado = await respuesta.text();
    
    // Procesar líneas del resultado
    resultado.split("\n").forEach(linea => {
      const limpia = linea.trim();
      if (!limpia) return;
      if (limpia.includes("[OK]") || limpia.includes("SUCCESS") || limpia.includes("✔") || limpia.includes("exito")) {
        agregarLog(limpia, "SUCCESS");
      } else if (limpia.includes("[!] ") || limpia.includes("WARN") || limpia.includes("Aviso")) {
        agregarLog(limpia, "WARN");
      } else if (limpia.includes("[ERROR]") || limpia.includes("Fallo") || limpia.includes("Error")) {
        agregarLog(limpia, "ERROR");
      } else {
        agregarLog(limpia, "INFO");
      }
    });

    agregarLog(`Operación #${id} completada exitosamente.`, "SUCCESS");

    // Actualizar telemetría inmediatamente
    obtenerTelemetria(true);

  } catch (err) {
    agregarLog(`Error de comunicación con el backend: ${err.message}`, "ERROR");
  } finally {
    ejecutandoTarea = false;
    taskBadge.textContent = "Listo";
    consoleLoader.classList.remove("active");

    if (btn) {
      btn.classList.remove("running");
      btn.innerHTML = `<span>${m.btnText}</span> <span class="btn-arrow">→</span>`;
    }
  }
}

// Agregar línea de log en la consola
function agregarLog(texto, tipo = "INFO") {
  const div = document.createElement("div");
  div.className = `log-line log-${tipo.toLowerCase()}`;
  div.textContent = `[${obtenerHora()}] ${texto}`;
  consoleOutput.appendChild(div);
  consoleOutput.scrollTop = consoleOutput.scrollHeight;
}

function obtenerHora() {
  const d = new Date();
  return d.toTimeString().split(" ")[0];
}

// Obtener telemetría en vivo desde la API de PowerShell
async function obtenerTelemetria(mostrarFeedback = false) {
  try {
    const res = await fetch("/api/stats");
    if (!res.ok) return;

    const datos = await res.json();

    // Actualizar Disco C:
    if (datos.disco) {
      document.getElementById("disk-text").textContent = `${datos.disco.libreGB} GB libres (${datos.disco.porcentajeLibre}%)`;
      const fillBar = document.getElementById("disk-bar");
      const pctUsado = 100 - datos.disco.porcentajeLibre;
      fillBar.style.width = `${pctUsado}%`;
    }

    // Actualizar RAM
    if (datos.ram) {
      document.getElementById("ram-text").textContent = `${datos.ram.libreGB} GB / ${datos.ram.totalGB} GB libres`;
      const fillRam = document.getElementById("ram-bar");
      const pctRamUsada = Math.round(((datos.ram.totalGB - datos.ram.libreGB) / datos.ram.totalGB) * 100);
      fillRam.style.width = `${pctRamUsada}%`;
    }

    // Actualizar nombres
    if (datos.equipo) {
      document.getElementById("pc-name").textContent = `PC: ${datos.equipo}`;
    }
    if (datos.usuario) {
      document.getElementById("pc-user").textContent = `Usuario: ${datos.usuario}`;
    }

    if (mostrarFeedback) {
      agregarLog("Métricas de rendimiento actualizadas.", "INFO");
    }

  } catch (e) {
    // Modo offline o reconectando
  }
}
