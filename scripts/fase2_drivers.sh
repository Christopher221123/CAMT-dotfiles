#!/bin/bash
# ============================================================================
#  🏎️ FASE 2: DRIVERS, GRÁFICOS Y DEPENDENCIAS
# ============================================================================
#  Autor: Christopher Alexis Muzo Trujillo
#  Descripción: Instala headers del kernel, activa multilib, instala drivers
#               Intel + NVIDIA (Prime/Hybrid), y dependencias del sistema.
#
#  Filosofía: "Intel para el sistema, NVIDIA para la guerra."
#
#  ⚠️  Ejecutar después de reiniciar tras Fase 1.
#      Requiere conexión a internet.
#      AL FINAL DE ESTE SCRIPT: ¡REINICIA!
# ============================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Funciones de UI ──────────────────────────────────────────────────────────
header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${BOLD}🏎️  FASE 2: DRIVERS, GRÁFICOS Y DEPENDENCIAS${NC}               ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

info()    { echo -e "  ${CYAN}[INFO]${NC}    $1"; }
success() { echo -e "  ${GREEN}[  OK  ]${NC}  $1"; }
warn()    { echo -e "  ${YELLOW}[ WARN ]${NC}  $1"; }
error()   { echo -e "  ${RED}[ERROR]${NC}   $1"; }
step()    { echo -e "\n  ${BOLD}${BLUE}▶ $1${NC}"; }

confirm() {
    echo ""
    read -rp "  ¿Continuar? [S/n]: " resp
    case "$resp" in
        [nN]*) echo -e "  ${YELLOW}Operación cancelada.${NC}"; exit 0 ;;
        *) ;;
    esac
}

# ── A. Activar Multilib ─────────────────────────────────────────────────────
enable_multilib() {
    step "A. Activando repositorio [multilib]..."

    if grep -q "^\[multilib\]" /etc/pacman.conf; then
        success "[multilib] ya está activado."
    else
        info "Habilitando [multilib] en /etc/pacman.conf..."
        # Descomentar la sección [multilib] y su Include
        sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
        success "[multilib] activado."
    fi

    info "Sincronizando repositorios..."
    sudo pacman -Syu --noconfirm
    success "Repositorios actualizados."
}

# ── B. Instalar Linux Headers ────────────────────────────────────────────────
install_headers() {
    step "B. Instalando Linux Headers..."

    # Detectar kernel activo
    local KERNEL
    KERNEL=$(uname -r)
    info "Kernel detectado: $KERNEL"

    if echo "$KERNEL" | grep -q "lts"; then
        info "Kernel LTS detectado. Instalando linux-lts-headers..."
        sudo pacman -S --noconfirm --needed linux-lts-headers
    else
        info "Kernel estándar detectado. Instalando linux-headers..."
        sudo pacman -S --noconfirm --needed linux-headers
    fi

    success "Headers del kernel instalados."
}

# ── C. Instalar Stack Gráfico (Intel + NVIDIA Prime) ────────────────────────
install_graphics() {
    step "C. Instalando stack gráfico completo (Intel + NVIDIA Prime)..."

    local GPU_PACKAGES=(
        # Intel
        mesa
        lib32-mesa
        vulkan-intel
        lib32-vulkan-intel
        intel-media-driver
        # NVIDIA
        nvidia-dkms
        nvidia-utils
        lib32-nvidia-utils
        nvidia-settings
        nvidia-prime
        # Vulkan loaders (necesario para Steam/Proton)
        vulkan-icd-loader
        lib32-vulkan-icd-loader
    )

    info "Paquetes a instalar:"
    for pkg in "${GPU_PACKAGES[@]}"; do
        echo "    • $pkg"
    done

    echo ""
    sudo pacman -S --noconfirm --needed "${GPU_PACKAGES[@]}"
    success "Stack gráfico instalado."

    # Forzar compilación del módulo NVIDIA
    step "Forzando compilación del módulo NVIDIA (DKMS)..."
    local NVIDIA_VER
    NVIDIA_VER=$(pacman -Q nvidia-dkms | awk '{print $2}' | cut -d'-' -f1)
    info "Versión NVIDIA detectada: $NVIDIA_VER"

    if sudo dkms status | grep -q "nvidia.*$NVIDIA_VER.*installed"; then
        success "Módulo NVIDIA ya compilado para el kernel actual."
    else
        sudo dkms install "nvidia/$NVIDIA_VER" || warn "DKMS ya compilado o error menor. Verificar manualmente."
        success "Módulo NVIDIA DKMS procesado."
    fi
}

# ── D. Fix mkinitcpio (Solo Intel en early load) ────────────────────────────
fix_mkinitcpio() {
    step "D. Configurando mkinitcpio (Solo i915 en MODULES)..."

    local MKINIT="/etc/mkinitcpio.conf"

    # Verificar si i915 ya está configurado
    if grep -q "^MODULES=(.*i915.*)" "$MKINIT"; then
        success "i915 ya está en MODULES."
    else
        info "Añadiendo i915 a MODULES..."
        # Reemplazar MODULES=() con MODULES=(i915) o añadir i915 si hay otros
        sudo sed -i 's/^MODULES=(\(.*\))/MODULES=(i915 \1)/' "$MKINIT"
        # Limpiar dobles espacios
        sudo sed -i 's/^MODULES=(i915 )/MODULES=(i915)/' "$MKINIT"
        success "i915 añadido a MODULES."
    fi

    # Verificar que nvidia NO esté en MODULES (causa bloqueos)
    if grep -q "^MODULES=(.*nvidia.*)" "$MKINIT"; then
        warn "⚠️  'nvidia' detectado en MODULES. Esto puede causar bloqueos."
        warn "Eliminando 'nvidia' de MODULES..."
        sudo sed -i 's/ nvidia//g; s/nvidia //g' "$MKINIT"
        success "'nvidia' eliminado de MODULES."
    fi

    info "Regenerando initramfs..."
    sudo mkinitcpio -P
    success "initramfs regenerado correctamente."
}

# ── E. Dependencias Críticas ─────────────────────────────────────────────────
install_dependencies() {
    step "E. Instalando dependencias críticas del sistema..."

    local SYS_PACKAGES=(
        base-devel
        git
        NetworkManager
        bluez
        bluez-utils
        pipewire
        pipewire-alsa
        pipewire-pulse
        alsa-utils
        brightnessctl
        playerctl
        unzip
        unrar
        p7zip
        ntfs-3g
    )

    sudo pacman -S --noconfirm --needed "${SYS_PACKAGES[@]}"
    success "Dependencias del sistema instaladas."

    # Habilitar servicios
    step "Habilitando servicios esenciales..."
    sudo systemctl enable --now NetworkManager 2>/dev/null || success "NetworkManager ya activo."
    sudo systemctl enable --now bluetooth 2>/dev/null || success "Bluetooth ya activo."
    success "Servicios habilitados."
}

# ── Main ─────────────────────────────────────────────────────────────────────
header

echo -e "  ${BOLD}Este script realizará:${NC}"
echo "    A. Activar repositorio [multilib]"
echo "    B. Instalar Linux Headers"
echo "    C. Instalar drivers Intel + NVIDIA (Prime/Hybrid)"
echo "    D. Configurar mkinitcpio (i915 early load, sin nvidia)"
echo "    E. Instalar dependencias críticas (audio, bluetooth, etc.)"
echo ""
echo -e "  ${YELLOW}${BOLD}⚠️  Al finalizar, DEBES reiniciar el sistema.${NC}"

confirm
enable_multilib
install_headers
install_graphics
fix_mkinitcpio
install_dependencies

echo ""
echo -e "  ${GREEN}${BOLD}✅ Fase 2 completada.${NC}"
echo ""
echo -e "  ${RED}${BOLD}⚠️  ¡REINICIA AHORA!${NC}"
echo -e "  ${CYAN}    sudo reboot${NC}"
echo ""
echo -e "  ${CYAN}Después del reinicio, ejecuta: ${BOLD}fase3_pre_dotfiles.sh${NC}"
echo ""
