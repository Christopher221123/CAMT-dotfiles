<div align="center">

# 🐧 Arch Linux — Guía de Instalación Maestra
### Dual Boot Windows 11 · Intel + NVIDIA · BSPWM + Rice · Steam Ready

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![NVIDIA](https://img.shields.io/badge/NVIDIA-76B900?style=for-the-badge&logo=nvidia&logoColor=white)
![Intel](https://img.shields.io/badge/Intel-0071C5?style=for-the-badge&logo=intel&logoColor=white)
![Steam](https://img.shields.io/badge/Steam-000000?style=for-the-badge&logo=steam&logoColor=white)

---

**Usuario:** Christopher Alexis Muzo Trujillo

**Filosofía:** "Intel para el sistema, NVIDIA para la guerra."
Estabilidad absoluta, renderizado bajo demanda (On-Demand) y estética premium.

</div>

---

## 📑 Tabla de Contenidos

- [1. 🏗️ Fase 1: Preparación (Archinstall / Base)](#-1-fase-1-preparación-archinstall--base)
  - [⚠️ Guía de Reparación de Windows (Dual Boot)](#-guía-de-reparación-de-windows-dual-boot)
- [2. �️ Fase 2: Drivers, Gráficos y Dependencias](#-2-fase-2-drivers-gráficos-y-dependencias)
  - [A. La Regla de Oro (Headers & Multilib)](#a-la-regla-de-oro-headers--multilib)
  - [B. Instalación de Drivers (Intel + NVIDIA Prime)](#b-instalación-de-drivers-intel--nvidia-prime)
  - [C. Dependencias Críticas (Gaming/System)](#c-dependencias-críticas-gamingsystem)
- [3. 📦 Fase 3: Herramientas (Paru)](#-3-fase-3-herramientas-paru)
- [4. 🎨 Fase 4: Entorno de Trabajo (Gh0stzk + Rice)](#-4-fase-4-entorno-de-trabajo-gh0stzk--rice)
- [5. ⚡ Fase 5: Finalización y Energía](#-5-fase-5-finalización-y-energía)

---

## 🏗️ 1. Fase 1: Preparación (Archinstall / Base)

Al usar `archinstall` o manual, vamos a tener siempre en cuenta esto:

- **Orden de SO:** Instalar Arch Linux **siempre primero**. (Si instalamos Windows de primer punto lo que lograremos es que cuando instalemos arch el arranque de windows se rompa).
- **Particionamiento:** `/home` **dentro de la raíz** (`/`). No separar particiones para evitar conflictos de permisos.
- **Bootloader:** GRUB (instalar `os-prober` para detectar Windows después).
- **Perfil:** Minimal / Base (Sin entorno de escritorio aún).

### 💾 Automatización (Guardar Configuración)
Al terminar la instalación con `archinstall`, el sistema genera archivos `.json`. Guárdalos antes de reiniciar:

```bash
mkdir -p /mnt/home/daffodils/Documents/ArchBackups
cp /var/log/archinstall/*.json /mnt/home/daffodils/Documents/ArchBackups/
# O si los guardaste en /tmp:
# cp /tmp/*.json /mnt/home/daffodils/Documents/ArchBackups/
```

---

### ⚠️ Guía de Reparación de Windows (Dual Boot)

**EN CASO DE QUE INSTALASTE PRIMERO WINDOWS O SE ROMPIÓ EL ARRANQUE:**

<details>
<summary>📖 <strong>Click aquí para expandir la guía de reparación paso a paso</strong></summary>

<br>

#### 1. Requisitos Previos

- Un USB con el instalador de Windows (10 u 11).
- Saber que los **números de volumen cambian** en cada reinicio.
- **Controladores IRST:** (Para procesadores Intel 12va Gen o superior, indispensable para ver los discos).

---

#### 2. Acceder a la Consola

1. Conecta el USB y arranca desde él (UEFI).
2. Avanza hasta la selección de disco -> Carga el driver IRST -> Regresa a la pantalla de idioma.
3. Presiona: **SHIFT + F10**
4. Se abrirá `cmd`.

---

#### 3. Identificar las Particiones (Diskpart)

```powershell
diskpart
list vol
```

**Qué buscar:**
| Tipo | Sistema (Fs) | Tamaño | Pista | Acción |
| --- | --- | --- | --- | --- |
| **EFI** | **FAT32** | ~100-500 MB | "Hidden" | Asignar letra **Z** |
| **Windows** | **NTFS** | Gigantes | Disco C: | **Anotar Letra** |

---

#### 4. Asignar Letra a la EFI

```powershell
select vol Num    # <-- ¡Cambia Num por el número de la EFI!
assign letter=Z
exit
```

---

#### 5. El Comando de Reparación

La estructura es: `bcdboot [Origen Windows] /s [Destino EFI] /f UEFI`

Supongamos que tu Windows está en la letra **C**:

```powershell
bcdboot C:\Windows /s Z: /f UEFI
```

✅ **Éxito:** "Boot files successfully created".

---

#### 6. Recuperar GRUB (Linux)

1. Reinicia entrando a tu Arch Linux.
2. Ejecuta:
```bash
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

</details>

---

## 🏎️ 2. Fase 2: Drivers, Gráficos y Dependencias

En esta fase preparamos el terreno para todo: el entorno BSPWM, KDE Plasma (futuro) y Gaming (Steam).

### A. La Regla de Oro (Headers & Multilib)

Sin esto, los drivers de NVIDIA **no existen** y Steam no funciona.

1.  **Activar Multilib:**
    ```bash
    sudo nano /etc/pacman.conf
    # Descomenta las líneas [multilib]
    sudo pacman -Syu
    ```

2.  **Instalar Headers:**
    ```bash
    sudo pacman -S linux-headers
    # Si usas kernel LTS: sudo pacman -S linux-lts-headers
    ```

### B. Instalación de Drivers (Intel + NVIDIA Prime)

Instalaremos TODO el stack gráfico para soporte híbrido y Vulkan (necesario para Steam/Proton).

```bash
sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver \
               nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime \
               vulkan-icd-loader lib32-vulkan-icd-loader
```

1.  **Forzar compilación del módulo NVIDIA:**
    ```bash
    # Reemplaza la versión por la instalada, ej: 580.126.09
    sudo dkms install nvidia/$(pacman -Q nvidia-dkms | awk '{print $2}' | cut -d'-' -f1)
    ```

2.  **Fix Pantalla Negra (mkinitcpio):**
    Editar `/etc/mkinitcpio.conf`:
    ```bash
    # SOLO módulos de Intel. NO pongas 'nvidia' aquí para evitar bloqueos.
    MODULES=(i915)
    ```
    Regenerar: `sudo mkinitcpio -P`

### C. Dependencias Críticas (Gaming/System)

Paquetes necesarios para compilar, audio, bluetooth y utilidades generales.

```bash
sudo pacman -S base-devel git NetworkManager bluez bluez-utils pipewire pipewire-alsa pipewire-pulse \
               alsa-utils brightnessctl playerctl unzip unrar p7zip ntfs-3g
```

> [!IMPORTANT]
> **REINICIA AHORA (`sudo reboot`)** antes de continuar.

---

## 📦 3. Fase 3: Herramientas (Paru)

Reemplazamos `yay` por `paru` (más rápido, escrito en Rust).

```bash
cd ~
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

---

## 🎨 4. Fase 4: Entorno de Trabajo (Gh0stzk + Rice)

### A. Prerequisitos del Rice
Instalamos esto primero para evitar errores visuales.

```bash
paru -S bspwm sxhkd polybar picom dunst rofi thunar feh maim xdotool xclip \
        ttf-jetbrains-mono-nerd ttf-font-awesome
```

### B. Instalar el Rice
```bash
curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller
chmod +x RiceInstaller
./RiceInstaller
```

### C. Optimización Picom (GLX Híbrido)
Asegurar que `~/.config/bspwm/config/picom.conf` use:
```ini
backend = "glx";
vsync = true;
use-damage = false;  # CRITICO para Intel Gen 12+
```

---

## ⚡ 5. Fase 5: Finalización y Energía

### A. LightDM (Login)
Evitar pantalla negra por arranque rápido.
`/etc/lightdm/lightdm.conf`:
```ini
[LightDM]
logind-check-graphical=true
```
Activar: `sudo systemctl enable lightdm`

### B. Script de Energía (120Hz/60Hz)

**Ruta:** `/usr/local/bin/toggle_refresh_rate.sh`

```bash
#!/bin/bash
export DISPLAY=:0
export XAUTHORITY="/home/daffodils/.Xauthority"
# Detectar AC (ajustar ADP0 según tu sistema)
if grep -q 1 /sys/class/power_supply/ADP0/online; then
    xrandr --output eDP-1 --mode 1920x1080 --rate 120.00
else
    xrandr --output eDP-1 --mode 1920x1080 --rate 60.00
fi
```
Permisos: `sudo chmod +x /usr/local/bin/toggle_refresh_rate.sh`

### C. Regla Udev (Activación Automática)
`/etc/udev/rules.d/99-powermanagement.rules`:
```
SUBSYSTEM=="power_supply", ACTION=="change", RUN+="/usr/local/bin/toggle_refresh_rate.sh"
```

---

### 🎮 Notas Finales: Gaming (Steam)

Como instalamos `nvidia-prime` y las dependencias `lib32-nvidia-utils` en la Fase 2, Steam funcionará perfecto.

Para jugar con la dedicada:
```bash
prime-run steam
```

<div align="center">
<sub>🚀 Guía Finalizada - 2026</sub>
</div>
