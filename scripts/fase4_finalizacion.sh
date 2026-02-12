#!/bin/bash
# ============================================================================
#  ⚡ FASE 4: FINALIZACIÓN Y ENERGÍA
# ============================================================================
#  Autor: Christopher Alexis Muzo Trujillo
#  Descripción: Configura LightDM, crea el script de cambio de refresh rate
#               automático (120Hz AC / 60Hz Batería), y la regla udev.
#
#  ⚠️  Ejecutar después de Fase 3 POST.
#      Este es el ÚLTIMO script. Después de esto: ¡reinicia y disfruta!
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
    echo -e "${YELLOW}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║${NC}  ${BOLD}⚡ FASE 4: FINALIZACIÓN Y ENERGÍA${NC}                          ${YELLOW}║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

info()    { echo -e "  ${CYAN}[INFO]${NC}    $1"; }
success() { echo -e "  ${GREEN}[  OK  ]${NC}  $1"; }
warn()    { echo -e "  ${YELLOW}[ WARN ]${NC}  $1"; }
error()   { echo -e "  ${RED}[ERROR]${NC}   $1"; }
step()    { echo -e "\n  ${BOLD}${YELLOW}▶ $1${NC}"; }

confirm() {
    echo ""
    read -rp "  ¿Continuar? [S/n]: " resp
    case "$resp" in
        [nN]*) echo -e "  ${YELLOW}Operación cancelada.${NC}"; exit 0 ;;
        *) ;;
    esac
}

# ── A. Configurar LightDM ───────────────────────────────────────────────────
configure_lightdm() {
    step "A. Configurando LightDM (Display Manager)..."

    local LIGHTDM_CONF="/etc/lightdm/lightdm.conf"

    # Verificar si LightDM está instalado
    if ! pacman -Qi lightdm &>/dev/null; then
        info "LightDM no está instalado. Instalando..."
        sudo pacman -S --noconfirm --needed lightdm lightdm-gtk-greeter
        success "LightDM instalado."
    else
        success "LightDM ya está instalado."
    fi

    # Configurar logind-check-graphical
    if [ -f "$LIGHTDM_CONF" ]; then
        if grep -q "logind-check-graphical=true" "$LIGHTDM_CONF"; then
            success "logind-check-graphical ya está configurado."
        else
            # Añadir bajo [LightDM]
            if grep -q "^\[LightDM\]" "$LIGHTDM_CONF"; then
                sudo sed -i '/^\[LightDM\]/a logind-check-graphical=true' "$LIGHTDM_CONF"
            else
                echo -e "[LightDM]\nlogind-check-graphical=true" | sudo tee -a "$LIGHTDM_CONF" >/dev/null
            fi
            success "logind-check-graphical=true configurado."
            info "Esto evita pantalla negra por arranque rápido."
        fi
    else
        warn "Archivo $LIGHTDM_CONF no encontrado."
        warn "Creando configuración mínima..."
        sudo mkdir -p /etc/lightdm
        echo -e "[LightDM]\nlogind-check-graphical=true" | sudo tee "$LIGHTDM_CONF" >/dev/null
        success "Configuración de LightDM creada."
    fi

    # Habilitar servicio
    info "Habilitando servicio LightDM..."
    sudo systemctl enable lightdm 2>/dev/null || true
    success "LightDM habilitado para inicio automático."
}

# ── B. Crear Script de Refresh Rate Automático ───────────────────────────────
create_refresh_rate_script() {
    step "B. Creando script de refresh rate automático (120Hz/60Hz)..."

    local SCRIPT_PATH="/usr/local/bin/toggle_refresh_rate.sh"

    info "Detectando fuente de energía..."

    # Detectar nombre del adaptador AC
    local AC_ADAPTER=""
    for adapter in /sys/class/power_supply/*/type; do
        if [ "$(cat "$adapter" 2>/dev/null)" = "Mains" ]; then
            AC_ADAPTER=$(basename "$(dirname "$adapter")")
            break
        fi
    done

    if [ -z "$AC_ADAPTER" ]; then
        AC_ADAPTER="ADP0"  # Fallback
        warn "No se detectó adaptador AC. Usando valor por defecto: $AC_ADAPTER"
    else
        success "Adaptador AC detectado: $AC_ADAPTER"
    fi

    # Detectar salida de pantalla
    local DISPLAY_OUTPUT=""
    if command -v xrandr &>/dev/null && [ -n "${DISPLAY:-}" ]; then
        DISPLAY_OUTPUT=$(xrandr --query 2>/dev/null | grep " connected" | head -1 | awk '{print $1}')
    fi

    if [ -z "$DISPLAY_OUTPUT" ]; then
        DISPLAY_OUTPUT="eDP-1"  # Fallback común para laptops
        info "Usando salida de pantalla por defecto: $DISPLAY_OUTPUT"
    else
        success "Salida de pantalla detectada: $DISPLAY_OUTPUT"
    fi

    # Crear el script
    sudo tee "$SCRIPT_PATH" > /dev/null << SCRIPT_EOF
#!/bin/bash
export DISPLAY=:0
export XAUTHORITY="/home/daffodils/.Xauthority"

# Detectar AC (adaptador: $AC_ADAPTER)
if grep -q 1 /sys/class/power_supply/${AC_ADAPTER}/online; then
    xrandr --output ${DISPLAY_OUTPUT} --mode 1920x1080 --rate 120.00
else
    xrandr --output ${DISPLAY_OUTPUT} --mode 1920x1080 --rate 60.00
fi
SCRIPT_EOF

    sudo chmod +x "$SCRIPT_PATH"
    success "Script creado: $SCRIPT_PATH"
    info "  AC conectado  → 120Hz"
    info "  Batería       → 60Hz"
}

# ── C. Crear Regla Udev ─────────────────────────────────────────────────────
create_udev_rule() {
    step "C. Creando regla udev para cambio automático de refresh rate..."

    local UDEV_RULE="/etc/udev/rules.d/99-powermanagement.rules"
    local RULE_CONTENT='SUBSYSTEM=="power_supply", ACTION=="change", RUN+="/usr/local/bin/toggle_refresh_rate.sh"'

    if [ -f "$UDEV_RULE" ] && grep -q "toggle_refresh_rate" "$UDEV_RULE"; then
        success "Regla udev ya existe."
    else
        echo "$RULE_CONTENT" | sudo tee "$UDEV_RULE" > /dev/null
        success "Regla udev creada: $UDEV_RULE"
    fi

    # Recargar reglas udev
    info "Recargando reglas udev..."
    sudo udevadm control --reload-rules
    success "Reglas udev recargadas."
}

# ── D. Resumen de Gaming ────────────────────────────────────────────────────
gaming_summary() {
    step "D. Resumen de configuración de Gaming..."

    echo ""
    info "Steam y gaming están listos gracias a la Fase 2."
    info ""
    info "Para jugar con la GPU NVIDIA dedicada:"
    echo ""
    echo -e "    ${CYAN}${BOLD}prime-run steam${NC}"
    echo ""
    info "Paquetes instalados para gaming:"
    echo "    • nvidia-prime (renderizado bajo demanda)"
    echo "    • lib32-nvidia-utils (soporte 32-bit para Steam)"
    echo "    • vulkan-icd-loader + lib32 (Proton/DXVK)"
    echo ""
}

# ── Main ─────────────────────────────────────────────────────────────────────
header

echo -e "  ${BOLD}Este script finalizará la configuración del sistema:${NC}"
echo ""
echo "    A. Configurar LightDM (evitar pantalla negra al inicio)"
echo "    B. Crear script de refresh rate automático (120Hz/60Hz)"
echo "    C. Crear regla udev para cambio automático con AC/Batería"
echo "    D. Resumen de configuración de gaming"
echo ""
echo -e "  ${GREEN}${BOLD}🎉 ¡Este es el último script! Después de esto, reinicia y disfruta.${NC}"

confirm
configure_lightdm
create_refresh_rate_script
create_udev_rule
gaming_summary

echo ""
echo -e "  ${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "  ${GREEN}║${NC}  ${BOLD}🎉 ¡INSTALACIÓN COMPLETA!${NC}                                   ${GREEN}║${NC}"
echo -e "  ${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "  ${GREEN}║${NC}  Tu sistema Arch Linux con BSPWM + Rice está listo.          ${GREEN}║${NC}"
echo -e "  ${GREEN}║${NC}  Intel para el sistema, NVIDIA para la guerra. 🐧            ${GREEN}║${NC}"
echo -e "  ${GREEN}║${NC}                                                              ${GREEN}║${NC}"
echo -e "  ${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${RED}${BOLD}→ sudo reboot${NC}"
echo ""
