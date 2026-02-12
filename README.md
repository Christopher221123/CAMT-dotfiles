<div align="center">

# 🐧 Arch Linux — Guía Maestra de Instalación Híbrida
### Intel (Sistema) + NVIDIA (Juegos) · BSPWM + Gh0stzk Rice · Paru · Prime Offloading

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![NVIDIA Prime](https://img.shields.io/badge/NVIDIA_Prime-76B900?style=for-the-badge&logo=nvidia&logoColor=white)
![Intel Iris](https://img.shields.io/badge/Intel_Iris-0071C5?style=for-the-badge&logo=intel&logoColor=white)
![BSPWM](https://img.shields.io/badge/BSPWM-2E3440?style=for-the-badge&logo=linux&logoColor=white)
![LightDM](https://img.shields.io/badge/LightDM-4A4A4A?style=for-the-badge&logo=linux&logoColor=white)

---

**Filosofía:** "Intel para la vida, NVIDIA para la guerra".
Estabilidad absoluta, renderizado bajo demanda (On-Demand) y estética premium.

</div>

---

## 📑 Tabla de Contenidos

- [1. 🧱 Fase 0: Requisitos Críticos (Headers & Multilib)](#-fase-0-requisitos-criticos-headers--multilib)
- [2. 🏗️ Fase 1: Sistema Base & Automatización](#-fase-1-sistema-base--automatizacion)
- [3. 🏎️ Fase 2: Gráficos Híbridos (El Fix Definitivo)](#-fase-2-graficos-hibridos-el-fix-definitivo)
- [4. 📦 Fase 3: El Poder de AUR (Paru)](#-fase-3-el-poder-de-aur-paru)
- [5. 🎨 Fase 4: El Rice (Gh0stzk + Picom GLX)](#-fase-4-el-rice-gh0stzk--picom-glx)
- [6. ⚡ Fase 5: Finalización y Energía](#-fase-5-finalizacion-y-energia)

---

## 🧱 Fase 0: Requisitos Críticos (Headers & Multilib)

> [!CAUTION]
> **LEER ANTES DE EMPEZAR:** Si no haces esto, tus graficas NVIDIA **no existirán** y el sistema se congelará.

### 1. Activar Repositorio Multilib
Necesario para Steam y drivers de 32 bits.

1.  Edita `pacman.conf`:
    ```bash
    sudo nano /etc/pacman.conf
    ```
2.  Descomenta (quita el `#`) de estas líneas:
    ```ini
    [multilib]
    Include = /etc/pacman.d/mirrorlist
    ```
3.  Actualiza los repositorios:
    ```bash
    sudo pacman -Syu
    ```

### 2. La Regla de Oro: Linux Headers
Los drivers de NVIDIA necesitan compilarse contra el kernel. Sin los headers, la instalación falla silenciosamente y terminas usando renderizado para CPU (lento y con bugs).

```bash
# Si usas el kernel estándar (linux)
sudo pacman -S linux-headers

# Si usas kernel LTS (linux-lts)
# sudo pacman -S linux-lts-headers
```

---

## 🏗️ Fase 1: Sistema Base & Automatización

Si estás instalando con `archinstall`, guarda tu configuración para replicarla en el futuro.

### � Respaldo de Configuración (archinstall)
Al terminar la instalación, el sistema genera archivos `.json` con todas tus elecciones. Guárdalos antes de reiniciar o salir.

```bash
# Crear directorio de respaldo en tu usuario
mkdir -p /mnt/home/daffodils/Documents/ArchBackups

# Copiar los JSON de configuración
cp /var/log/archinstall/*.json /mnt/home/daffodils/Documents/ArchBackups/
```

---

## 🏎️ Fase 2: Gráficos Híbridos (El Fix Definitivo)

Olvídate de scripts complicados para cambiar de GPU y reiniciar. Usaremos **PRIME Offloading**.
- **Intel:** Maneja el escritorio, videos y navegador. (Siempre activa, ahorra batería).
- **NVIDIA:** Se despierta SOLO cuando vas a jugar o renderizar.

### 1. Limpieza de `mkinitcpio`
El arranque debe ser limpio. No queremos forzar que NVIDIA cargue antes de tiempo.

Edita `/etc/mkinitcpio.conf`:
```bash
MODULES=(i915)
# ¡NO pongas 'nvidia' aquí! Dejemos que el sistema lo cargue dinámicamente.
```
Regenera: `sudo mkinitcpio -P`

### 2. Instalación de Drivers (DKMS)
Instalaremos el driver DKMS para que se recompil automáticamente cuando actualices el kernel.

```bash
# Instala TODO el stack gráfico de una sola vez
sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver \
               nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime
```

### 3. Activar NVIDIA (Compilación)
Para asegurar que el módulo se construya ahora mismo:
```bash
# Reemplaza la versión por la que descargó pacman, ej: 580.126.09
sudo dkms install nvidia/$(pacman -Q nvidia-dkms | awk '{print $2}' | cut -d'-' -f1)
```

> [!IMPORTANT]
> **REINICIA AHORA.**
> `sudo reboot`
>
> Al volver, verifica que tienes los dos proveedores: `xrandr --listproviders` (Debe salir 2).

---

## 📦 Fase 3: El Poder de AUR (Paru)

Reemplazaremos `yay` por `paru` (escrito en Rust, más rápido y moderno).

```bash
# Instalar Paru desde AUR
cd ~
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

---

## 🎨 Fase 4: El Rice (Gh0stzk + Picom GLX)

Ahora que tenemos gráficos funcionales, podemos instalar el entorno visual con aceleración completa.

### 1. Prerequisitos
Instalar dependencias visuales antes del script para evitar errores.
```bash
paru -S ttf-jetbrains-mono-nerd ttf-font-awesome xorg-xinit xorg-server bspwm sxhkd polybar picom dunst rofi
```

### 2. Ejecutar RiceInstaller
```bash
curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller
chmod +x RiceInstaller
./RiceInstaller
```

### 3. Optimización de Picom (GLX)
El instalador pondrá un picom por defecto. Asegúrate de que `~/.config/bspwm/config/picom.conf` use:
```ini
backend = "glx";
vsync = true;
use-damage = true;  # En Intel Híbrido moderno, esto suele ir bien.
                    # Si ves glitches, cámbialo a false.
```

---

## ⚡ Fase 5: Finalización y Energía

### 1. Gestor de Sesión (LightDM)
Evita la pantalla negra por arranque rápido en procesadores i9/i7 modernos.

Editar `/etc/lightdm/lightdm.conf`:
```ini
[LightDM]
logind-check-graphical=true
```
Activar: `sudo systemctl enable lightdm`

### 2. Script de Refresco (120Hz/60Hz)
Cambia la tasa de refresco automáticamente al desconectar el cargador.

**Archivo:** `/usr/local/bin/toggle_refresh_rate.sh`
```bash
#!/bin/bash
export DISPLAY=:0
export XAUTHORITY="/home/daffodils/.Xauthority"

# Detectar estado de batería (Adaptar ADP0 según tu sistema)
if grep -q 1 /sys/class/power_supply/ADP0/online; then
    xrandr --output eDP-1 --mode 1920x1080 --rate 120.00 # O 300.00 si tu pantalla lo soporta
else
    xrandr --output eDP-1 --mode 1920x1080 --rate 60.00
fi
```
Dale permisos: `sudo chmod +x /usr/local/bin/toggle_refresh_rate.sh`

### 3. Regla Udev
Ejecutar el script al conectar/desconectar.
`/etc/udev/rules.d/99-power.rules`:
```
SUBSYSTEM=="power_supply", ACTION=="change", RUN+="/usr/local/bin/toggle_refresh_rate.sh"
```

---

### 🎮 Cómo jugar (Usar la NVIDIA)

Por defecto, todo corre en Intel (fresco y silencioso).
Para jugar, usa `prime-run`:

```bash
# Steam
prime-run steam

# Juegos sueltos
prime-run ./juego.x86_64

# Verificar que funciona
prime-run glxinfo | grep "OpenGL renderer"
# Debe decir: NVIDIA GeForce RTX 3070 Ti...
```

<div align="center">
<sub>� Optimizado para Arch Linux Híbrido - Guía 2026</sub>
</div>
