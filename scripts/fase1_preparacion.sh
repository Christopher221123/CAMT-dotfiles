#!/bin/bash
# ============================================================================
#  🏗️ FASE 1: PREPARACIÓN (Post-Archinstall)
# ============================================================================
#  Autor: Christopher Alexis Muzo Trujillo
#  Descripción: Guarda los archivos de configuración de archinstall y
#               configura GRUB para detectar Windows (Dual Boot).
#
#  ⚠️  Ejecutar ANTES de reiniciar tras archinstall.
#      Si estás en el live USB: ejecutar desde /mnt
#      Si ya reiniciaste: ejecutar normalmente.
# ============================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# ── Funciones de UI ──────────────────────────────────────────────────────────
header() {
    echo ""
    echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}  ${BOLD}🏗️  FASE 1: PREPARACIÓN (Post-Archinstall)${NC}                  ${BLUE}║${NC}"
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

# ── Detectar entorno ─────────────────────────────────────────────────────────
detect_environment() {
    step "Detectando entorno de ejecución..."

    if mountpoint -q /mnt 2>/dev/null && [ -d /mnt/home ]; then
        CHROOT_PREFIX="/mnt"
        info "Detectado: Entorno Live USB (archinstall recién terminado)"
        info "Prefijo: ${CHROOT_PREFIX}"
    else
        CHROOT_PREFIX=""
        info "Detectado: Sistema instalado (ya reiniciaste)"
    fi
}

# ── Guardar archivos de archinstall ──────────────────────────────────────────
backup_archinstall_configs() {
    step "Guardando configuración de archinstall..."

    local BACKUP_DIR="${CHROOT_PREFIX}/home/daffodils/Documents/ArchBackups"

    mkdir -p "$BACKUP_DIR"
    success "Directorio creado: $BACKUP_DIR"

    local found=0

    # Buscar en /var/log/archinstall (ubicación principal)
    if ls /var/log/archinstall/*.json 1>/dev/null 2>&1; then
        cp /var/log/archinstall/*.json "$BACKUP_DIR/"
        info "Copiados desde /var/log/archinstall/"
        found=1
    fi

    # Buscar en /tmp (ubicación alternativa)
    if ls /tmp/*.json 1>/dev/null 2>&1; then
        cp /tmp/*.json "$BACKUP_DIR/"
        info "Copiados desde /tmp/"
        found=1
    fi

    if [ "$found" -eq 1 ]; then
        success "Archivos de archinstall guardados correctamente."
        info "Archivos guardados:"
        ls -la "$BACKUP_DIR"/*.json 2>/dev/null | while read -r line; do
            echo "    $line"
        done
    else
        warn "No se encontraron archivos .json de archinstall."
        warn "Esto es normal si ya los guardaste o si no usaste archinstall."
    fi
}

# ── Configurar GRUB para Dual Boot ──────────────────────────────────────────
configure_grub() {
    step "Configurando GRUB para Dual Boot..."

    if [ -n "$CHROOT_PREFIX" ]; then
        warn "Estás en el Live USB. GRUB se configurará después de reiniciar."
        warn "Ejecuta este script de nuevo después de reiniciar en Arch."
        return
    fi

    # Instalar os-prober si no existe
    if ! pacman -Qi os-prober &>/dev/null; then
        info "Instalando os-prober..."
        sudo pacman -S --noconfirm os-prober
        success "os-prober instalado."
    else
        success "os-prober ya está instalado."
    fi

    # Habilitar os-prober en GRUB config
    if grep -q "^#GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
        sudo sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
        success "os-prober habilitado en /etc/default/grub"
    elif ! grep -q "GRUB_DISABLE_OS_PROBER=false" /etc/default/grub; then
        echo "GRUB_DISABLE_OS_PROBER=false" | sudo tee -a /etc/default/grub >/dev/null
        success "os-prober añadido a /etc/default/grub"
    else
        success "os-prober ya está habilitado en GRUB."
    fi

    # Detectar Windows y regenerar GRUB
    info "Buscando sistemas operativos..."
    sudo os-prober
    info "Regenerando configuración de GRUB..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    success "GRUB actualizado correctamente."
}

# ── Main ─────────────────────────────────────────────────────────────────────
header

echo -e "  ${BOLD}Este script realizará:${NC}"
echo "    1. Guardar archivos de configuración de archinstall"
echo "    2. Configurar GRUB para detectar Windows (Dual Boot)"

confirm
detect_environment
backup_archinstall_configs
configure_grub

echo ""
echo -e "  ${GREEN}${BOLD}✅ Fase 1 completada.${NC}"
echo -e "  ${CYAN}Siguiente paso: Reinicia y ejecuta ${BOLD}fase2_drivers.sh${NC}"
echo ""
