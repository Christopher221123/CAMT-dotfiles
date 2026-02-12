#!/bin/bash
# ============================================================================
#  🎨 FASE 3 — POST-DOTFILES: Optimización después del RiceInstaller
# ============================================================================
#  Autor: Christopher Alexis Muzo Trujillo
#  Descripción: Aplica optimizaciones y configuraciones necesarias DESPUÉS
#               de que el RiceInstaller de Gh0stzk haya terminado.
#               Principalmente: ajustes de Picom para gráficos híbridos.
#
#  ⚠️  Ejecutar DESPUÉS de que ./RiceInstaller haya terminado.
# ============================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# ── Funciones de UI ──────────────────────────────────────────────────────────
header() {
    echo ""
    echo -e "${MAGENTA}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}  ${BOLD}🎨 FASE 3 POST — OPTIMIZACIÓN POST-DOTFILES${NC}               ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

info()    { echo -e "  ${CYAN}[INFO]${NC}    $1"; }
success() { echo -e "  ${GREEN}[  OK  ]${NC}  $1"; }
warn()    { echo -e "  ${YELLOW}[ WARN ]${NC}  $1"; }
error()   { echo -e "  ${RED}[ERROR]${NC}   $1"; }
step()    { echo -e "\n  ${BOLD}${MAGENTA}▶ $1${NC}"; }

confirm() {
    echo ""
    read -rp "  ¿Continuar? [S/n]: " resp
    case "$resp" in
        [nN]*) echo -e "  ${YELLOW}Operación cancelada.${NC}"; exit 0 ;;
        *) ;;
    esac
}

# ── A. Optimizar Picom para Gráficos Híbridos ───────────────────────────────
optimize_picom() {
    step "A. Optimizando Picom para gráficos híbridos (Intel + NVIDIA)..."

    # Buscar el archivo de configuración de picom
    local PICOM_CONF=""
    local SEARCH_PATHS=(
        "$HOME/.config/bspwm/config/picom.conf"
        "$HOME/.config/picom/picom.conf"
        "$HOME/.config/picom.conf"
        "$HOME/.config/bspwm/picom.conf"
    )

    for path in "${SEARCH_PATHS[@]}"; do
        if [ -f "$path" ]; then
            PICOM_CONF="$path"
            break
        fi
    done

    if [ -z "$PICOM_CONF" ]; then
        warn "No se encontró picom.conf en las rutas conocidas."
        warn "Buscando en todo ~/.config/..."
        PICOM_CONF=$(find "$HOME/.config" -name "picom.conf" -type f 2>/dev/null | head -1)
    fi

    if [ -z "$PICOM_CONF" ]; then
        error "No se encontró ningún archivo picom.conf"
        warn "El RiceInstaller podría no haberse ejecutado aún."
        warn "Ejecuta primero: ./RiceInstaller"
        return 1
    fi

    info "Archivo encontrado: $PICOM_CONF"

    # Crear backup
    local BACKUP="${PICOM_CONF}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$PICOM_CONF" "$BACKUP"
    success "Backup creado: $BACKUP"

    # Aplicar configuraciones óptimas para Intel Gen 12+ con NVIDIA
    info "Aplicando configuraciones GLX híbrido..."

    # Backend = glx
    if grep -q "^backend" "$PICOM_CONF"; then
        sed -i 's/^backend.*/backend = "glx";/' "$PICOM_CONF"
        success 'backend = "glx" configurado.'
    elif grep -q "^#.*backend" "$PICOM_CONF"; then
        sed -i 's/^#.*backend.*/backend = "glx";/' "$PICOM_CONF"
        success 'backend = "glx" configurado (descomentado).'
    else
        echo 'backend = "glx";' >> "$PICOM_CONF"
        success 'backend = "glx" añadido.'
    fi

    # vsync = true
    if grep -q "^vsync" "$PICOM_CONF"; then
        sed -i 's/^vsync.*/vsync = true;/' "$PICOM_CONF"
        success "vsync = true configurado."
    elif grep -q "^#.*vsync" "$PICOM_CONF"; then
        sed -i 's/^#.*vsync.*/vsync = true;/' "$PICOM_CONF"
        success "vsync = true configurado (descomentado)."
    else
        echo "vsync = true;" >> "$PICOM_CONF"
        success "vsync = true añadido."
    fi

    # use-damage = false (CRÍTICO para Intel Gen 12+)
    if grep -q "^use-damage" "$PICOM_CONF"; then
        sed -i 's/^use-damage.*/use-damage = false;/' "$PICOM_CONF"
        success "use-damage = false configurado."
    elif grep -q "^#.*use-damage" "$PICOM_CONF"; then
        sed -i 's/^#.*use-damage.*/use-damage = false;/' "$PICOM_CONF"
        success "use-damage = false configurado (descomentado)."
    else
        echo "use-damage = false;  # CRITICO para Intel Gen 12+" >> "$PICOM_CONF"
        success "use-damage = false añadido."
    fi

    echo ""
    info "Configuración final de Picom:"
    echo -e "    ${CYAN}backend${NC}    = ${GREEN}\"glx\"${NC}"
    echo -e "    ${CYAN}vsync${NC}      = ${GREEN}true${NC}"
    echo -e "    ${CYAN}use-damage${NC} = ${GREEN}false${NC}  ${YELLOW}(CRÍTICO para Intel Gen 12+)${NC}"
}

# ── B. Verificar instalación de dotfiles ─────────────────────────────────────
verify_dotfiles() {
    step "B. Verificando instalación de dotfiles..."

    local CHECK_PATHS=(
        "$HOME/.config/bspwm/bspwmrc"
        "$HOME/.config/sxhkd/sxhkdrc"
    )

    local all_ok=true

    for path in "${CHECK_PATHS[@]}"; do
        if [ -f "$path" ]; then
            success "$(basename "$(dirname "$path")")/$(basename "$path") ✓"
        else
            warn "$(basename "$(dirname "$path")")/$(basename "$path") ✗ (no encontrado)"
            all_ok=false
        fi
    done

    # Verificar que bspwmrc sea ejecutable
    if [ -f "$HOME/.config/bspwm/bspwmrc" ]; then
        if [ -x "$HOME/.config/bspwm/bspwmrc" ]; then
            success "bspwmrc tiene permisos de ejecución ✓"
        else
            warn "bspwmrc NO tiene permisos de ejecución. Arreglando..."
            chmod +x "$HOME/.config/bspwm/bspwmrc"
            success "Permisos de ejecución añadidos a bspwmrc."
        fi
    fi

    if [ "$all_ok" = true ]; then
        success "Todos los archivos de dotfiles verificados."
    else
        warn "Algunos archivos no se encontraron. Verifica la instalación del Rice."
    fi
}

# ── C. Aplicar dotfiles personalizados del repo CAMT ─────────────────────────
apply_camt_dotfiles() {
    step "C. Verificando dotfiles personalizados del repositorio CAMT..."

    local CAMT_DIR
    CAMT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

    if [ -d "$CAMT_DIR" ]; then
        info "Repositorio CAMT-dotfiles detectado en: $CAMT_DIR"
        info "Si tienes configuraciones personalizadas en este repo,"
        info "puedes copiarlas manualmente a ~/.config/"
        success "Verificación completada."
    else
        warn "No se encontró el directorio del repositorio CAMT-dotfiles."
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────
header

echo -e "  ${BOLD}Este script optimiza tu sistema DESPUÉS de instalar los dotfiles:${NC}"
echo ""
echo "    A. Optimizar Picom para gráficos híbridos (GLX + Intel Gen 12+)"
echo "    B. Verificar que los dotfiles se instalaron correctamente"
echo "    C. Verificar repo CAMT-dotfiles para configs personalizadas"
echo ""
echo -e "  ${YELLOW}⚠️  Asegúrate de haber ejecutado RiceInstaller antes.${NC}"

confirm
optimize_picom
verify_dotfiles
apply_camt_dotfiles

echo ""
echo -e "  ${GREEN}${BOLD}✅ Fase 3 POST completada. Dotfiles optimizados.${NC}"
echo ""
echo -e "  ${CYAN}Siguiente paso: Ejecuta ${BOLD}fase4_finalizacion.sh${NC}"
echo ""
