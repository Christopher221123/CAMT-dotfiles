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

- [🤖 Instalación Automática (Scripts)](#-instalación-automática-scripts)
- [1. 🏗️ Fase 1: Preparación (Archinstall / Base)](#-1-fase-1-preparación-archinstall--base)
  - [⚠️ Guía de Reparación de Windows (Dual Boot)](#-guía-de-reparación-de-windows-dual-boot)
- [2. 🏎️ Fase 2: Drivers, Gráficos y Dependencias](#-2-fase-2-drivers-gráficos-y-dependencias)
- [3. 🎨 Fase 3: Entorno de Trabajo (Capas)](#-3-fase-3-entorno-de-trabajo-capas)
  - [A. Capa Base: AUR Helper (Paru)](#a-capa-base-aur-helper-paru)
  - [B. Capa de Estabilidad: Prerequisitos y ZSH](#b-capa-de-estabilidad-prerequisitos-y-zsh)
  - [C. Capa Estética: RiceInstaller](#c-capa-estética-riceinstaller)
- [4. ⚡ Fase 4: Finalización y Energía](#-4-fase-4-finalización-y-energía)

---

## 🤖 Instalación Automática (Scripts)

Si no quieres seguir la guía paso a paso de forma manual, puedes usar los **scripts automatizados** que se encuentran en la carpeta `scripts/` de este repositorio. Cada script corresponde a una fase de la guía y ejecuta todos los comandos por ti.

### 📥 Paso 0: Clonar este repositorio

Antes de empezar, clona este repo en tu sistema recién instalado:

```bash
git clone https://github.com/Christopher221123/CAMT-dotfiles.git ~/CAMT-dotfiles
cd ~/CAMT-dotfiles
```

### 🗺️ Orden de ejecución

Ejecuta los scripts en este orden exacto. **Lee las notas de cada paso**, hay reinicios obligatorios entre ellos.

| # | Script | Fase | Descripción |
|---|--------|------|-------------|
| 1 | `scripts/fase1_preparacion.sh` | 🏗️ Fase 1 | Guarda configs de archinstall y configura GRUB para dual boot |
| 2 | `scripts/fase2_drivers.sh` | 🏎️ Fase 2 | Multilib, headers, drivers Intel + NVIDIA, dependencias del sistema |
| 3 | `scripts/fase3_pre_dotfiles.sh` | 🎨 Fase 3 (PRE) | Instala Paru, Xorg, BSPWM, Polybar, Picom, fix fzf-tab |
| — | **RiceInstaller** *(manual)* | 🎨 Fase 3 | Ejecutar el instalador de Gh0stzk manualmente |
| 4 | `scripts/fase3_post_dotfiles.sh` | 🎨 Fase 3 (POST) | Optimiza Picom para gráficos híbridos, verifica dotfiles |
| 5 | `scripts/fase4_finalizacion.sh` | ⚡ Fase 4 | LightDM, script de refresh rate 120Hz/60Hz, regla udev |

### ⚡ Ejecución rápida

```bash
# ── FASE 1: Después de archinstall (antes o después del primer reinicio)
./scripts/fase1_preparacion.sh

# ── FASE 2: Drivers y dependencias
./scripts/fase2_drivers.sh
sudo reboot  # ⚠️ REINICIO OBLIGATORIO

# ── FASE 3 PRE: Preparar entorno para dotfiles
./scripts/fase3_pre_dotfiles.sh

# ── FASE 3: Instalar dotfiles (MANUAL — no se puede automatizar)
curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller
chmod +x RiceInstaller
./RiceInstaller

# ── FASE 3 POST: Optimización post-dotfiles
./scripts/fase3_post_dotfiles.sh

# ── FASE 4: Finalización
./scripts/fase4_finalizacion.sh
sudo reboot  # 🎉 ¡Listo! Reinicia y disfruta
```

> [!NOTE]
> **¿Por qué el RiceInstaller no está automatizado?** El instalador de Gh0stzk es interactivo y requiere que elijas opciones durante la instalación. Por eso se ejecuta manualmente entre los scripts `fase3_pre` y `fase3_post`.

> [!TIP]
> Todos los scripts son **idempotentes**: puedes ejecutarlos varias veces sin romper nada. Si algo falla, corrige el problema y vuelve a ejecutar el mismo script.

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

## 🎨 3. Fase 3: Entorno de Trabajo (Capas)

En esta fase pasamos de la terminal básica a la interfaz gráfica personalizada capa por capa.

### A. Capa Base: AUR Helper (Paru)

Antes de cualquier otra cosa, necesitamos la herramienta para instalar paquetes de la comunidad (AUR), la cual reemplazará a `yay`.

```bash
cd ~
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
```

### B. Capa de Estabilidad: Prerequisitos y ZSH

Para evitar errores visuales o de la terminal (como el famoso error de `fzf-tab`), instalamos esto **antes**.

1.  **Dependencias Visuales:**
    ```bash
    paru -S xorg-server xorg-xinit bspwm sxhkd polybar picom dunst rofi thunar feh maim xdotool xclip \
            ttf-jetbrains-mono-nerd ttf-font-awesome
    ```

2.  **Fix Preventivo para ZSH (Crítico):**
    ```bash
    sudo mkdir -p /usr/share/zsh/plugins/
    sudo git clone https://github.com/Aloxaf/fzf-tab /usr/share/zsh/plugins/fzf-tab-git
    ```

### C. Capa Estética: RiceInstaller

Ahora que el sistema tiene todo lo necesario, el instalador de Gh0stzk funcionará de manera fluida.

1.  **Ejecutar Instalador:**
    ```bash
    curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller
    chmod +x RiceInstaller
    ./RiceInstaller
    ```

2.  **Optimización Picom (GLX Híbrido):**
    Asegurar que `~/.config/bspwm/config/picom.conf` use:
    ```ini
    backend = "glx";
    vsync = true;
    use-damage = false;  # CRITICO para Intel Gen 12+
    ```

---

## ⚡ 4. Fase 4: Finalización y Energía

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
