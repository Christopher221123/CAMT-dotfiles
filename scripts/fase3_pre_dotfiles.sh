#!/bin/bash
# ============================================================================
#  🎨 FASE 3 — PRE-DOTFILES: Preparar el entorno ANTES del RiceInstaller
# ============================================================================
#  Autor: Christopher Alexis Muzo Trujillo
#  Descripción: Instala Paru (AUR Helper), dependencias visuales de BSPWM,
#               y aplica fixes preventivos (fzf-tab) para que el
#               RiceInstaller de Gh0stzk funcione sin errores.
#
#  ⚠️  Ejecutar DESPUÉS de reiniciar tras Fase 2.
#      Ejecutar ANTES de correr RiceInstaller.
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
    echo -e "${MAGENTA}║${NC}  ${BOLD}🎨 FASE 3 PRE — PREPARAR ENTORNO PARA DOTFILES${NC}            ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

info()    { echo -e "  ${CYAN}[INFO]${NC}    $1"; }
success() { echo -e "  ${GREEN}[  OK  ]${NC}  $1"; }
warn()    { echo -e "  ${YELLOW}[ WARN ]${NC}  $1"; }
error()   { echo -e "  ${RED}[ERROR]${NC}   $1"; exit 1; }
step()    { echo -e "\n  ${BOLD}${MAGENTA}▶ $1${NC}"; }

confirm() {
    echo ""
    read -rp "  ¿Continuar? [S/n]: " resp
    case "$resp" in
        [nN]*) echo -e "  ${YELLOW}Operación cancelada.${NC}"; exit 0 ;;
        *) ;;
    esac
}

# ── A. Instalar Paru (AUR Helper) ───────────────────────────────────────────
install_paru() {
    step "A. Instalando Paru (AUR Helper)..."

    if command -v paru &>/dev/null; then
        success "Paru ya está instalado: $(paru --version | head -1)"
        return
    fi

    # Asegurarse de tener base-devel y git
    sudo pacman -S --noconfirm --needed base-devel git

    local PARU_DIR="/tmp/paru-build"
    mkdir -p "$PARU_DIR"

    info "Clonando repositorio de Paru..."
    git clone https://aur.archlinux.org/paru.git "$PARU_DIR"

    info "Compilando e instalando Paru..."
    (cd "$PARU_DIR" && makepkg -si --noconfirm)

    # Limpiar
    rm -rf "$PARU_DIR"

    if command -v paru &>/dev/null; then
        success "Paru instalado correctamente: $(paru --version | head -1)"
    else
        error "Paru no se instaló correctamente. Verifica manualmente."
    fi
}

# ── B. Instalar Dependencias Visuales (BSPWM Stack) ─────────────────────────
install_visual_deps() {
    step "B. Instalando dependencias visuales (BSPWM + WM Stack)..."

    local VISUAL_PACKAGES=(
        # Servidor gráfico
        xorg-server
        xorg-xinit
        # Window Manager y herramientas
        bspwm
        sxhkd
        polybar
        picom
        dunst
        rofi
        thunar
        feh
        maim
        xdotool
        xclip
        # Fuentes
        ttf-jetbrains-mono-nerd
        ttf-font-awesome
    )

    info "Paquetes a instalar:"
    for pkg in "${VISUAL_PACKAGES[@]}"; do
        echo "    • $pkg"
    done
    echo ""

    paru -S --noconfirm --needed "${VISUAL_PACKAGES[@]}"
    success "Dependencias visuales instaladas."
}

# ── C. Fix Preventivo para ZSH (fzf-tab) ────────────────────────────────────
fix_fzf_tab() {
    step "C. Aplicando fix preventivo para ZSH (fzf-tab)..."

    local FZF_TAB_DIR="/usr/share/zsh/plugins/fzf-tab-git"

    if [ -d "$FZF_TAB_DIR" ]; then
        success "fzf-tab ya está instalado en $FZF_TAB_DIR"
        return
    fi

    info "Creando directorio de plugins de ZSH..."
    sudo mkdir -p /usr/share/zsh/plugins/

    info "Clonando fzf-tab..."
    sudo git clone https://github.com/Aloxaf/fzf-tab "$FZF_TAB_DIR"

    if [ -d "$FZF_TAB_DIR" ]; then
        success "fzf-tab instalado correctamente."
    else
        warn "Error al clonar fzf-tab. Intenta manualmente."
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────
header

echo -e "  ${BOLD}Este script preparará tu sistema ANTES de instalar los dotfiles:${NC}"
echo ""
echo "    A. Instalar Paru (AUR Helper para paquetes de la comunidad)"
echo "    B. Instalar dependencias visuales (Xorg, BSPWM, Polybar, etc.)"
echo "    C. Fix preventivo para ZSH (clonar fzf-tab)"
echo ""
echo -e "  ${YELLOW}Después de este script, ejecuta el RiceInstaller:${NC}"
echo -e "  ${CYAN}    curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller${NC}"
echo -e "  ${CYAN}    chmod +x RiceInstaller${NC}"
echo -e "  ${CYAN}    ./RiceInstaller${NC}"

confirm
install_paru
install_visual_deps
fix_fzf_tab

echo ""
echo -e "  ${GREEN}${BOLD}✅ Fase 3 PRE completada. El sistema está listo para los dotfiles.${NC}"
echo ""
echo -e "  ${BOLD}Ahora ejecuta el RiceInstaller:${NC}"
echo ""
echo -e "  ${CYAN}    curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller${NC}"
echo -e "  ${CYAN}    chmod +x RiceInstaller${NC}"
echo -e "  ${CYAN}    ./RiceInstaller${NC}"
echo ""
echo -e "  ${CYAN}Después del RiceInstaller, ejecuta: ${BOLD}fase3_post_dotfiles.sh${NC}"
echo ""
