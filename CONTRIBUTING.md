# 🤝 Guía de Contribución — Win-Optimizador Pro

¡Gracias por tu interés en colaborar con **Win-Optimizador Pro**! Este proyecto es de código abierto y agradece aportaciones que mejoren la estabilidad, seguridad y experiencia del usuario en Windows.

---

## 🛠️ Reglas y Estándares de Desarrollo

1. **Cero Dependencias Externas:**
   - La suite debe funcionar de forma nativa en cualquier instalación limpia de Windows 10 u 11 sin obligar al usuario a instalar Node.js, Python ni utilidades de terceros.
2. **Codificación de Archivos PowerShell:**
   - Todos los scripts `.ps1` que contengan caracteres especiales o símbolos Unicode (bordes, iconos, tildes) deben guardarse estrictamente en **UTF-8 con BOM** (`UTF-8 Signature`), para evitar errores de sintaxis en el intérprete Windows PowerShell 5.1.
3. **Manejo Seguro de Errores y Confirmaciones:**
   - Toda operación destructiva (como borrado de archivos o deshabilitación de servicios) debe contener manejo de excepciones (`try/catch` o `-ErrorAction SilentlyContinue`) y confirmación previa del usuario cuando aplique.
4. **Sincronía Dual (TUI y GUI):**
   - Si agregas una nueva función o herramienta, debe estar documentada y disponible tanto en el script de consola (`winoptimizador.ps1`) como en el servidor y vista gráfica (`winoptimizador_gui.ps1` y `gui/`).

---

## 🚀 Flujo para Enviar Cambios (Pull Requests)

1. Haz un **Fork** de este repositorio.
2. Crea una rama para tu funcionalidad o corrección:
   ```bash
   git checkout -b feature/nueva-herramienta
   ```
3. Realiza tus cambios y verifica la sintaxis del AST de PowerShell:
   ```powershell
   $errors = $null
   [System.Management.Automation.Language.Parser]::ParseFile("winoptimizador.ps1", [ref]$null, [ref]$errors)
   if ($errors.Count -eq 0) { "Cero errores de sintaxis" }
   ```
4. Haz commit de tus cambios con mensajes claros:
   ```bash
   git commit -m "feat: agregar módulo de comprobación de batería"
   ```
5. Sube tu rama:
   ```bash
   git push origin feature/nueva-herramienta
   ```
6. Abre un **Pull Request** explicando detalladamente la mejora realizada.
