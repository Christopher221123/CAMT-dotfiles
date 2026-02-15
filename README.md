<div align="center">

# 🐧 Arch Linux — Guía de Instalación Maestra
### Dual Boot Windows 11 · Intel + NVIDIA (Supergfxctl) · BSPWM + Rice · KDE Plasma · Steam Ready

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![NVIDIA](https://img.shields.io/badge/NVIDIA-76B900?style=for-the-badge&logo=nvidia&logoColor=white)
![Intel](https://img.shields.io/badge/Intel-0071C5?style=for-the-badge&logo=intel&logoColor=white)
![BSPWM](https://img.shields.io/badge/BSPWM-2E3440?style=for-the-badge&logo=linux&logoColor=white)
![LightDM](https://img.shields.io/badge/LightDM-4A4A4A?style=for-the-badge&logo=linux&logoColor=white)
![KDE Plasma](https://img.shields.io/badge/KDE_Plasma-1D99F3?style=for-the-badge&logo=kde&logoColor=white)
![Steam](https://img.shields.io/badge/Steam-000000?style=for-the-badge&logo=steam&logoColor=white)

---

**Usuario:** Christopher Alexis Muzo Trujillo

**Filosofía:** Cada GUI es para un propósito específico.
</div>

---

## 📑 Tabla de Contenidos

- [1. 🏗️ Fase 1: Preparación (Archinstall / Base)](#-1-fase-1-preparación-archinstall--base)
  - [💾 Automatización (Guardar Configuración)](#-automatización-guardar-configuración)
  - [⚠️ Guía de Reparación de Windows (Dual Boot)](#️-guía-de-reparación-de-windows-dual-boot)
- [2. 🏎️ Fase 2: Drivers, Gráficos y Dependencias](#️-2-fase-2-drivers-gráficos-y-dependencias)
  - [A. La Regla de Oro (Headers & Multilib)](#a-la-regla-de-oro-headers--multilib)
  - [B. Instalación de Drivers (Intel + NVIDIA Hybrid)](#b-instalación-de-drivers-intel--nvidia-hybrid)
  - [C. Fix de Pantalla Negra (Early KMS + NVIDIA DRM)](#c-fix-de-pantalla-negra-early-kms--nvidia-drm)
  - [D. Dependencias Críticas (Gaming/System)](#d-dependencias-críticas-gamingsystem)
- [3. 🎨 Fase 3: Entorno de Trabajo (Capas)](#-3-fase-3-entorno-de-trabajo-capas)
  - [A. Capa Base: AUR Helper (Paru)](#a-capa-base-aur-helper-paru)
  - [B. Capa de Estabilidad: Prerequisitos y ZSH](#b-capa-de-estabilidad-prerequisitos-y-zsh)
  - [C. Capa Estética: RiceInstaller](#c-capa-estética-riceinstaller)
  - [D. Capa Funcional: KDE Plasma (Minimal)](#d-capa-funcional-kde-plasma-minimal)
- [4. ⚡ Fase 4: Configuración Avanzada — GPU Inteligente y Pantalla](#-4-fase-4-configuración-avanzada--gpu-inteligente-y-pantalla)
  - [A. Supergfxctl — Gestión de GPU por Sesión](#a-supergfxctl--gestión-de-gpu-por-sesión)
  - [B. Cambio Manual de Modo GPU](#b-cambio-manual-de-modo-gpu)
  - [C. Auditoría de Identificadores](#c-auditoría-de-identificadores)
  - [D. El Script de Refresh Rate](#d-el-script-de-refresh-rate)
  - [E. El Gatillo (udev)](#e-el-gatillo-udev)
  - [F. Auto-inicio del Refresh Rate en BSPWM](#f-auto-inicio-del-refresh-rate-en-bspwm)
- [5. 🔧 Fase 5: Post-Instalación y Ajustes (BSPWM)](#-5-fase-5-post-instalación-y-ajustes-bspwm)
  - [A. Corrección del Icono de Red (Wi-Fi)](#a-corrección-del-icono-de-red-wi-fi)
  - [B. Verificación de Variables de Hardware (system.ini)](#b-verificación-de-variables-de-hardware-systemini)
  - [C. Corrección de Picom (use-damage)](#c-corrección-de-picom-use-damage)
  - [D. Eliminación del Módulo de Música (mplayer)](#d-eliminación-del-módulo-de-música-mplayer)
  - [E. Sincronización de Temas GTK](#e-sincronización-de-temas-gtk)
  - [F. Grupos de Usuario y Permisos](#f-grupos-de-usuario-y-permisos)
- [6. 🖥️ Fase 6: Soporte ASUS (Kernel g14 + asusctl + supergfxctl)](#️-6-fase-6-soporte-asus-kernel-g14--asusctl--supergfxctl)
  - [A. Agregar Repositorio g14](#a-agregar-repositorio-g14)
  - [B. Importar y Firmar Llave GPG](#b-importar-y-firmar-llave-gpg)
  - [C. Instalar Kernel g14 y Herramientas ASUS (incluye supergfxctl)](#c-instalar-kernel-g14-y-herramientas-asus-incluye-supergfxctl)
  - [D. Post-Instalación (GRUB + Demonios)](#d-post-instalación-grub--demonios)
- [🎮 Notas Finales: Gaming (Steam)](#-notas-finales-gaming-steam)

---

## 🏗️ 1. Fase 1: Preparación (Archinstall / Base)

Al usar `archinstall` o instalación manual, vamos a tener siempre en cuenta esto:

- **Orden de SO:** Instalar Arch Linux **siempre primero**. (Si instalamos Windows de primer punto lo que lograremos es que cuando instalemos arch el arranque de windows se rompa).

- **Particionamiento:** `/home` **dentro de la raíz** (`/`). No separar particiones para evitar conflictos de permisos y espacio.

- **Bootloader:** GRUB (instalar `os-prober` para detectar Windows después).

- **Perfil:** Minimal / Base (Sin entorno de escritorio aún).

- **Paquetes adicionales:**
  - `firefox` — Para buscar soluciones si algo falla.
  - `os-prober` — Para el Dual Boot.
  - `ntfs-3g` — Para que Arch pueda leer/escribir en tu partición de Windows.
  - `git` y `base-devel` — Para instalar `yay` y tus dotfiles.
  - `nano` — Editor de texto.
  - `lightdm`, `lightdm-gtk-greeter`, `lightdm-gtk-greeter-settings` — Display Manager.

### 💾 Automatización (Guardar Configuración)

Al terminar la instalación con `archinstall`, el sistema genera archivos `.json`. Guárdalos antes de reiniciar.

> [!NOTE]
> La carpeta por defecto es `/tmp`. Si tus archivos están en otra ruta, ajusta el comando `cp` acorde.

```bash
mkdir -p /mnt/home/daffodils/Documents/ArchBackups

cp /tmp/*.json /mnt/home/daffodils/Documents/ArchBackups/
```

---

### ⚠️ Guía de Reparación de Windows (Dual Boot)

<details>
<summary>📖 <strong>Click aquí EN CASO DE QUE INSTALASTE PRIMERO WINDOWS O SE ROMPIÓ EL ARRANQUE de Windows por culpa de Arch:</strong></summary>

<br>

#### 1. Requisitos Previos

- Un USB con el instalador de Windows (10 u 11).
- Saber que los **números de volumen cambian** en cada reinicio (no confiar en memoria).
- **Para mi laptop en especifico tener los controladores IRST** (Para que pueda reconocer los discos ya que en mi procesador i9 12va generacion hay ese problema)

---

#### 2. Acceder a la Consola

1. Conecta el USB y arranca el PC desde él (UEFI).
2. Avanzamos hasta llegar al punto de seleccion de disco.
3. Instalamos el IRST y regresamos hasta la pantalla de seleccion de idioma.
4. En la primera pantalla (selección de idioma), presiona:

   > **SHIFT + F10**

5. Se abrirá una ventana negra (`cmd`).

---

#### 3. Identificar las Particiones (Diskpart)

Aquí es donde debes tener cuidado. No mires los números, **mira los tamaños y formatos**.

Ejecuta estos comandos en orden:

```powershell
diskpart
list vol
```

##### 🔍 Qué buscar en la lista:

| **Tipo de Partición** | **Sistema de Archivos (Fs)** | **Tamaño (aprox.)** | **Pista Visual** | **Acción** |
| --- | --- | --- | --- | --- |
| **EFI (Arranque)** | **FAT32** | 100 MB - 1024 MB | Suele decir "Hidden" | Asignaremos letra **Z** |
| **Windows** | **NTFS** | Gigantes (ej. 476 GB) | Es tu disco principal | **Anotar su letra actual** |
| *CD-ROM/USB* | *CDFS / exFAT* | *Pequeños o 4GB+* | *Dice "Removable" o DVD* | *IGNORAR* ❌ |

---

#### 4. Asignar Letra a la EFI

```powershell
select vol Num    # <-- ¡Cambia el Num por el número que veas en ESE momento en la parte EFI!
assign letter=Z
exit
```

> *(El `exit` te saca de diskpart pero deja la ventana negra abierta).*

---

#### 5. El Comando de Reparación

La estructura del comando es: `Copia desde [Windows] hacia [Z:]`

Mira qué letra tiene tu partición **NTFS Gigante** (Windows).

- Si es la letra **C**, el comando es `C:\Windows`
- Si es la letra **D**, el comando es `D:\Windows`
- Si es la letra **G**, el comando es `G:\Windows`

**Ejecuta el comando final:**

```powershell
bcdboot X:\Windows /s Z: /f UEFI
```

> *(Sustituye la **X** por la letra de tu partición de Windows).*

✅ **Éxito:** Debe decir *"Boot files successfully created"*.

❌ **Error:** Si dice *"Failure..."*, revisa que no estés apuntando al CD-ROM o al USB por error.

---

#### 6. Recuperar el Menú de Linux (GRUB)

1. Reinicia y selecciona Arch Linux.
2. Inicia sesión en tu Arch Linux / Distro.
3. Abre la terminal y actualiza el GRUB para que detecte el Windows arreglado:

```bash
# Paso 1: Habilitar el detector de otros sistemas
sudo os-prober

# Paso 2: Regenerar el archivo de configuración
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

</details>

---

## 🏎️ 2. Fase 2: Drivers, Gráficos y Dependencias

En esta fase preparamos el terreno para todo: el entorno BSPWM, KDE Plasma (futuro) y Gaming (Steam).

### A. La Regla de Oro (Headers & Multilib)

Sin esto, los drivers de NVIDIA **no existen** y Steam no funciona.

1. **Activar Multilib:**
    ```bash
    sudo nano /etc/pacman.conf
    # Descomenta las líneas [multilib]
    sudo pacman -Syu
    ```

2. **Instalar Headers:**
    ```bash
    sudo pacman -S linux-headers
    # Si usas kernel LTS: sudo pacman -S linux-lts-headers
    ```

### B. Instalación de Drivers (Intel + NVIDIA Hybrid)

Instalaremos TODO el stack gráfico para soporte híbrido y Vulkan (necesario para Steam/Proton).

> [!NOTE]
> Usamos `nvidia-open-dkms` en lugar de `nvidia-dkms` por compatibilidad con el kernel g14. **No instalamos `nvidia-prime`** — la gestión de GPU se hace con `supergfxctl` (se instala en la Fase 6).

```bash
sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver \
               nvidia-open-dkms nvidia-utils lib32-nvidia-utils nvidia-settings \
               vulkan-icd-loader lib32-vulkan-icd-loader
```

1. **Forzar compilación del módulo NVIDIA:**
    ```bash
    # Reemplaza la versión por la instalada, ej: 590.48.01
    sudo dkms install nvidia/$(pacman -Q nvidia-open-dkms | awk '{print $2}' | cut -d'-' -f1)
    ```

### C. Fix de Pantalla Negra (Early KMS + NVIDIA DRM)

Para que los modos Hybrid y Dedicated funcionen correctamente (sin pantalla negra en LightDM), necesitamos **dos** configuraciones:

#### C.1. Módulos en mkinitcpio

Editar `/etc/mkinitcpio.conf`:

1. Abre el archivo con:

   ```bash
   sudo nano /etc/mkinitcpio.conf
   ```

2. Busca la línea que dice `MODULES=()` y cámbiala para que quede **exactamente así:**

   > **❌ Antes (original):**
   > ```
   > MODULES=()
   > ```
   >
   > **✅ Después (como debe quedar):**
   > ```
   > MODULES=(i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm)
   > ```

   > [!WARNING]
   > **Todos los módulos son necesarios.** `i915` es para Intel, los módulos `nvidia*` permiten que la GPU dedicada se inicialice correctamente en modo Hybrid/Dedicated. Sin ellos, LightDM muestra pantalla negra.

3. Guarda y sal (`Ctrl+O`, `Enter`, `Ctrl+X`).

4. Regenerar el initramfs:

   ```bash
   sudo mkinitcpio -P
   ```

#### C.2. Parámetro del Kernel (NVIDIA DRM Modesetting)

Editar `/etc/default/grub`:

1. Abre el archivo:

   ```bash
   sudo nano /etc/default/grub
   ```

2. Busca la línea `GRUB_CMDLINE_LINUX_DEFAULT` y añade `nvidia_drm.modeset=1`:

   > **❌ Antes:**
   > ```
   > GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"
   > ```
   >
   > **✅ Después:**
   > ```
   > GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1"
   > ```

3. Regenerar GRUB:

   ```bash
   sudo grub-mkconfig -o /boot/grub/grub.cfg
   ```

> [!IMPORTANT]
> Sin `nvidia_drm.modeset=1`, el servidor gráfico no puede usar NVIDIA para DRM (Direct Rendering Manager). Esto causa pantalla negra en LightDM cuando supergfxctl está en modo Hybrid o Dedicated.

### D. Dependencias Críticas (Gaming/System)

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

1. **Dependencias Visuales:**
    ```bash
    paru -S xorg-server xorg-xinit bspwm sxhkd polybar picom dunst rofi thunar feh maim xdotool xclip \
            ttf-jetbrains-mono-nerd ttf-font-awesome
    ```

2. **Fix Preventivo para ZSH (Crítico):**
    ```bash
    sudo mkdir -p /usr/share/zsh/plugins/
    sudo git clone https://github.com/Aloxaf/fzf-tab /usr/share/zsh/plugins/fzf-tab-git
    ```

### C. Capa Estética: RiceInstaller

Ahora que el sistema tiene todo lo necesario, el instalador de Gh0stzk funcionará de manera fluida.

1. **Ejecutar Instalador:**
    ```bash
    curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller
    chmod +x RiceInstaller
    ./RiceInstaller
    ```

2. **Optimización Picom (GLX Híbrido):**
    Asegurar que `~/.config/bspwm/config/picom.conf` use:
    ```ini
    backend = "glx";
    vsync = true;
    use-damage = false;  # CRITICO para Intel Gen 12+
    ```

### D. Capa Funcional: KDE Plasma (Minimal)

Instalación mínima de KDE Plasma para tener un entorno de escritorio completo como alternativa a BSPWM. Solo los componentes esenciales, sin bloatware.

```bash
sudo pacman -S plasma-desktop plasma-nm plasma-pa powerdevil kde-gtk-config bluedevil
```

| Paquete | Propósito |
| --- | --- |
| `plasma-desktop` | El shell base de KDE Plasma |
| `plasma-nm` | Applet de NetworkManager para la bandeja |
| `plasma-pa` | Control de volumen PulseAudio/PipeWire |
| `powerdevil` | Gestión de energía y brillo |
| `kde-gtk-config` | Integración de temas GTK dentro de KDE |
| `bluedevil` | Gestión de Bluetooth |

> [!NOTE]
> KDE Plasma se selecciona desde LightDM al iniciar sesión. BSPWM y Plasma coexisten sin conflictos — cada GUI para su propósito.

---

## ⚡ 4. Fase 4: Configuración Avanzada — GPU Inteligente y Pantalla

Aquí configuramos el sistema para que sea inteligente con la GPU y la pantalla. La clave es **supergfxctl**: en BSPWM apagamos la GPU dedicada (modo integrado) y en KDE Plasma la dejamos disponible (modo híbrido). Además, los hercios cambian automáticamente según la fuente de energía.

### A. Supergfxctl — Gestión de GPU por Sesión

> [!NOTE]
> `supergfxctl` se instala en la **Fase 6** junto con el kernel g14 y las herramientas ASUS. Si aún no has pasado por la Fase 6, hazlo primero.

**Supergfxctl** es una herramienta de gestión de gráficos del ecosistema [asus-linux.org](http://asus-linux.org/), diseñada para laptops híbridas. Opera bajo un modelo cliente-servidor:

| Componente | Función |
| --- | --- |
| `supergfxd` (demonio) | Servicio en Rust que interactúa con el Kernel vía sysfs/ACPI para controlar la GPU |
| `supergfxctl` (CLI) | Interfaz de línea de comandos que se comunica con el demonio por D-Bus |

**Modos de operación relevantes para nuestro setup:**

| Modo | Acción | GPU Dedicada | Uso |
| --- | --- | --- | --- |
| `Integrated` | Descarga drivers de la GPU dedicada | **Apagada** — bus PCIe desconectado | BSPWM (ahorro máximo) |
| `Hybrid` | Mantiene ambos drivers cargados | En reposo (D3), se activa bajo demanda | KDE Plasma (uso estándar + gaming) |
| `Dedicated` | Configura todo para usar la dedicada | **Activa** — maneja todo el renderizado | Gaming intensivo |

> [!IMPORTANT]
> A diferencia de EnvyControl u Optimus-Manager, supergfxctl **no modifica archivos en `/etc/X11/xorg.conf.d/`**. Esto reduce drásticamente el riesgo de pantalla negra tras actualizaciones. Además, no permite cambiar a modo integrado si detecta aplicaciones usando la GPU dedicada.

**Comandos esenciales:**

```bash
# Ver modo actual
supergfxctl -g

# Listar modos soportados por tu hardware
supergfxctl -s

# Cambiar modo (requiere REINICIO DEL SISTEMA para aplicarse)
supergfxctl -m integrated
supergfxctl -m hybrid
supergfxctl -m dedicated

# Ver estado detallado
supergfxctl --status
```

> [!IMPORTANT]
> Para cambiar entre modos GPU solo necesitas **cerrar sesión (log out)**, no reiniciar. supergfxctl gestiona todo automáticamente, incluyendo el blacklist de módulos nvidia en `/etc/modprobe.d/supergfxd.conf`.

---

### B. Cambio Manual de Modo GPU

El cambio de modo GPU se hace manualmente desde la terminal. Solo requiere **cerrar sesión** para que se aplique.

**Flujo de uso:**

```
  ┌────────────────────────────────────────────────────────┐
  │                 CAMBIO DE MODO GPU                     │
  ├────────────────────────────────────────────────────────┤
  │                                                        │
  │  1. Abres terminal → supergfxctl -g (ver modo actual)  │
  │  2. supergfxctl -m integrated  (o hybrid, o dedicated) │
  │  3. Cierras sesión (log out desde LightDM)             │
  │  4. Inicias sesión → modo nuevo aplicado ✅             │
  │                                                        │
  └────────────────────────────────────────────────────────┘
```

**Ejemplo práctico — pasar de Hybrid a Integrated:**

```bash
# 1. Ver modo actual
supergfxctl -g
# → Hybrid

# 2. Cambiar a Integrated (GPU dedicada se apagará)
supergfxctl -m Integrated

# 3. Cerrar sesión (log out) y volver a iniciar
#    Al regresar, la GPU dedicada estará apagada
```

**Ejemplo práctico — pasar de Integrated a Hybrid:**

```bash
# 1. Ver modo actual
supergfxctl -g
# → Integrated

# 2. Cambiar a Hybrid (GPU dedicada disponible bajo demanda)
supergfxctl -m Hybrid

# 3. Cerrar sesión (log out) y volver a iniciar
#    Al regresar, nvidia-smi mostrará la GPU
```

> [!TIP]
> **Recomendación de uso:**
> - **BSPWM** → Usa `Integrated` para máximo ahorro de batería
> - **KDE Plasma** → Usa `Hybrid` para tener la GPU disponible bajo demanda
> - **Gaming intensivo** → Usa `AsusMuxDgpu` si necesitas todo el rendimiento de la GPU dedicada

---

### C. Auditoría de Identificadores

Antes de activar el script de refresh rate (especialmente tras una reinstalación o cambio de modo de GPU), verifica estos datos:

1. **Monitor ID:** Ejecuta `xrandr | grep " connected"`. (Ejemplo actual: `eDP-1`).
2. **Cargador ID:** Ejecuta `ls /sys/class/power_supply/`. (Ejemplo: `ADP0`).
3. **Usuario:** Tu nombre de usuario actual (Ejemplo: `daffodils`).
4. **Modo GPU:** Ejecuta `supergfxctl -g` para verificar el modo actual.

> [!NOTE]
> El identificador del monitor puede cambiar según el modo de GPU activo. En modo `Integrated`, la pantalla suele ser `eDP-1`. En modo `Hybrid` o `Dedicated`, podría ser `eDP-1` también, pero es bueno verificar.

---

### D. El Script de Refresh Rate

**Ruta:** `/usr/local/bin/toggle_refresh_rate.sh`

```bash
#!/bin/bash

# ==========================================
# SECCIÓN DE IDENTIDAD (Ajustar según Auditoría)
# ==========================================
USER_NAME="daffodils"
MONITOR_ID="eDP-1"
AC_ID="ADP0"
# ==========================================

# Variables de entorno
export DISPLAY=:0
export XAUTHORITY="/home/$USER_NAME/.Xauthority"
AC_PATH="/sys/class/power_supply/$AC_ID/online"

# Lógica de conmutación
if [ -f "$AC_PATH" ]; then
    AC_STATUS=$(cat "$AC_PATH")
    if [ "$AC_STATUS" -eq 1 ]; then
        # Conectado -> 300Hz
        xrandr --output "$MONITOR_ID" --mode 1920x1080 --rate 300.00
    else
        # Batería -> 60Hz
        xrandr --output "$MONITOR_ID" --mode 1920x1080 --rate 60.00
    fi
fi
```

**Después de crear el archivo, dale los permisos necesarios:**

```bash
sudo chown daffodils:daffodils /usr/local/bin/toggle_refresh_rate.sh
sudo chmod +x /usr/local/bin/toggle_refresh_rate.sh
```

> [!IMPORTANT]
> Sin estos permisos el script **no se ejecutará**. Si reinstalaste el sistema, recuerda correr estos dos comandos de nuevo.

---

### E. El Gatillo (udev)

Para que el Kernel "detone" el script de refresh rate solo cuando sea necesario.

**Ruta:** `/etc/udev/rules.d/99-powermanagement.rules`

```
SUBSYSTEM=="power_supply", ACTION=="change", RUN+="/usr/local/bin/toggle_refresh_rate.sh"
```

**Activar la regla sin reiniciar:**

```bash
sudo udevadm control --reload-rules && sudo udevadm trigger
```

> [!TIP]
> Este comando recarga las reglas de udev en caliente. Si no lo ejecutas, la regla no se activará hasta el próximo reinicio.

---

### F. Auto-inicio del Refresh Rate en BSPWM

En los dotfiles de Gh0stzk, el archivo que controla qué se abre al iniciar es el `bspwmrc`.

1. Edita el archivo:

    ```bash
    nano ~/.config/bspwm/bspwmrc
    ```

2. Añade esta línea al final:

    ```bash
    # Forzar detección de hercios al iniciar sesión
    /usr/local/bin/toggle_refresh_rate.sh &
    ```

---

## 🔧 5. Fase 5: Post-Instalación y Ajustes (BSPWM)

Pasos esenciales para la integridad del sistema tras la instalación del Rice de Gh0stzk. Aquí corregimos las variables de hardware de la Polybar, arreglamos picom y unificamos la estética.

### A. Corrección del Icono de Red (Wi-Fi)

El script de autoconfiguración del Rice probablemente detectó la interfaz de Ethernet pero no la inalámbrica. Hay que indicarle manualmente a la Polybar qué tarjeta observar.

1. **Identifica tu interfaz Wi-Fi:**

    ```bash
    nmcli device
    ```

    Busca el nombre bajo la columna `DEVICE` que diga `wifi` (en este equipo es `wlo1`).

2. **Edita el archivo de variables del sistema:**

    ```bash
    nano ~/.config/bspwm/config/system.ini
    ```

3. **Actualiza la variable de red:**

    Busca la línea `sys_network_interface` y cambia el valor por el nombre que encontraste:

    ```ini
    sys_network_interface = wlo1
    ```

> [!TIP]
> Si quieres que se vean ambas interfaces (Ethernet + Wi-Fi), puedes crear una segunda variable como `sys_network_interface2`, pero esto requiere añadir un módulo extra a la barra.

---

### B. Verificación de Variables de Hardware (system.ini)

Además de la red, verifica que la batería, adaptador y tarjeta gráfica sean correctos para que los iconos de energía y brillo funcionen.

1. **Identifica tus dispositivos de energía y backlight:**

    ```bash
    ls /sys/class/power_supply/
    ls /sys/class/backlight/
    ```

2. **Ajusta las variables en `system.ini`:**

    ```bash
    nano ~/.config/bspwm/config/system.ini
    ```

    Asegúrate de que **todas** las variables coincidan con tu hardware real:

    ```ini
    sys_adapter = ADP0
    sys_battery = BAT0
    sys_graphics_card = intel_backlight
    sys_network_interface = wlo1
    ```

> [!WARNING]
> El Rice auto-detecta `sys_graphics_card` como `nvidia_0` si tienes drivers NVIDIA instalados, pero el backlight real del sistema es `intel_backlight`. Si no corriges esto, el módulo de brillo de la Polybar **no funcionará**.

---

### C. Corrección de Picom (use-damage)

Para procesadores Intel de 12va generación en adelante, es **crítico** desactivar `use-damage` en picom para evitar artefactos gráficos.

1. **Edita el archivo de picom:**

    ```bash
    nano ~/.config/bspwm/config/picom.conf
    ```

2. **Busca y modifica la línea `use-damage`:**

    > **❌ Antes:**
    > ```
    > use-damage = true;
    > ```
    >
    > **✅ Después:**
    > ```
    > use-damage = false;
    > ```

3. **Verifica también que el backend sea GLX:**

    ```ini
    backend = "glx";
    vsync = true;
    ```

---

### D. Eliminación del Módulo de Música (mplayer)

El Rice incluye un módulo `[module/mplayer]` en la Polybar que abre el reproductor de música (NCMPCPP). Si no lo usas, aparece como un cuadro vacío en la barra. Para eliminarlo hay que borrarlo de **dos archivos** en cada Rice.

> [!NOTE]
> Los Rices `andrea` y `z0mbi3` usan EWW en vez de Polybar, por lo que no tienen este módulo y no necesitan este paso.

1. **Elimina la definición del módulo en `modules.ini`:**

    ```bash
    nano ~/.config/bspwm/rices/NOMBRE_DEL_RICE/modules.ini
    ```

    Busca y borra toda la sección `[module/mplayer]` (suele verse así):

    ```ini
    [module/mplayer]
    type = custom/text
    label = ""
    ...
    click-left = OpenApps --player
    click-right = OpenApps --music
    ```

2. **Elimina la referencia en la barra en `config.ini`:**

    ```bash
    nano ~/.config/bspwm/rices/NOMBRE_DEL_RICE/config.ini
    ```

    Busca las líneas `modules-left`, `modules-center` o `modules-right` y elimina la palabra `mplayer`:

    ```ini
    # Antes:
    modules-left = launcher sep bi bspwm bd sep usercard mplayer power

    # Después:
    modules-left = launcher sep bi bspwm bd sep usercard power
    ```

3. **Repite para cada Rice.** Hay que hacerlo en los 16 Rices que usan Polybar: `aline`, `brenda`, `cristina`, `cynthia`, `daniela`, `emilia`, `h4ck3r`, `isabel`, `jan`, `karla`, `marisol`, `melissa`, `pamela`, `silvia`, `varinka`, `yael`.

> [!TIP]
> Los módulos `mpd` y `mpd_control` (que muestran la canción en reproducción y los controles) **no se tocan**. Según la documentación del Rice, estos solo se hacen visibles cuando se reproduce una canción por primera vez. Si nunca usas MPD, simplemente no aparecerán.



---

### E. Sincronización de Temas GTK

Para que aplicaciones como Thunar o Engrampa no se vean fuera de lugar con el Rice.

1. Abre la herramienta de configuración de apariencia (`lxappearance` o KDE Settings si tienes Plasma instalado).

2. Asegúrate de que estos elementos coincidan con los del Rice de Gh0stzk:

    | Elemento | Valor recomendado |
    | --- | --- |
    | **Tema GTK** | El que aplique el Rice activo |
    | **Iconos** | Candy / BeautyLine |
    | **Cursor** | El cursor del Rice activo |

> [!NOTE]
> Esto unifica la estética entre BSPWM y las aplicaciones GTK que uses, evitando que se vean con el tema genérico del sistema.

---

### F. Grupos de Usuario y Permisos

Asegúrate de tener acceso total al hardware sin depender siempre de `sudo` para tareas comunes.

```bash
sudo usermod -aG video,audio,render,storage $USER
```

> [!IMPORTANT]
> Esto es vital para que la Polybar pueda leer la información del brillo y el sonido sin errores. **Cierra sesión y vuelve a entrar** para que los cambios surtan efecto.

---

## 🖥️ 6. Fase 6: Soporte ASUS (Kernel g14 + asusctl + supergfxctl)

Para laptops ASUS (especialmente las series ROG, TUF, Zephyrus), el repositorio de la comunidad **Asus-Linux** provee un kernel optimizado, herramientas de control de hardware y **supergfxctl** para gestión inteligente de GPU.

> [!IMPORTANT]
> Esta fase es **CRÍTICA** porque aquí se instala `supergfxctl`, la herramienta que reemplaza a EnvyControl/nvidia-prime para la gestión de GPU. Sin ella, la Fase 4 no funcionará.

### A. Agregar Repositorio g14

Edita el archivo de configuración de pacman:

```bash
sudo nano /etc/pacman.conf
```

Al **final** del archivo, agrega estas líneas:

```ini
[g14]
Server = https://arch.asus-linux.org
```

---

### B. Importar y Firmar Llave GPG

Para que pacman acepte los paquetes firmados del repositorio g14:

```bash
# Recibir la llave en tu llavero local
sudo pacman-key --recv-keys 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35

# Firmar la llave localmente (esto le dice al sistema que tú confías en ella)
sudo pacman-key --lsign-key 8F654886F17D497FEFE3DB448B15A6B0E9A3FA35
```

---

### C. Instalar Kernel g14 y Herramientas ASUS (incluye supergfxctl)

```bash
# Sincronizar la base de datos de paquetes
sudo pacman -Sy

# Instalar el kernel optimizado, herramientas ASUS y gestión de GPU
sudo pacman -S linux-g14 linux-g14-headers asusctl supergfxctl rog-control-center
```

| Paquete | Propósito |
| --- | --- |
| `linux-g14` | Kernel con parches específicos para hardware ASUS |
| `linux-g14-headers` | Headers del kernel g14 (necesarios para DKMS/NVIDIA) |
| `asusctl` | Control de funciones ASUS (LEDs, perfiles de rendimiento, carga de batería) |
| `supergfxctl` | **Gestión inteligente de GPU** (integrated/hybrid/dedicated/vfio) |
| `rog-control-center` | Interfaz gráfica para `asusctl` y `supergfxctl` |

---

### D. Post-Instalación (GRUB + Demonios)

Después de instalar el kernel g14, hay que regenerar GRUB y activar **ambos** demonios:

```bash
# Regenerar el GRUB para que detecte el nuevo kernel
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Activar el demonio de ASUS (controla LEDs, perfiles, etc.)
sudo systemctl enable --now asusd

# Activar el demonio de GPU (OBLIGATORIO para supergfxctl)
sudo systemctl enable --now supergfxd
```

**Verificar que todo funciona:**

```bash
# Verificar kernel
uname -r
# Esperado: algo como 6.18.7-arch1-1.2-g14

# Verificar demonio de GPU activo
systemctl is-active supergfxd
# Esperado: active

# Ver modo GPU actual
supergfxctl -g

# Listar modos soportados
supergfxctl -s
```

> [!IMPORTANT]
> **Reinicia el sistema** tras estos pasos para arrancar con el nuevo kernel g14. El demonio `supergfxd` debe estar activo para que `supergfxctl` funcione.

> [!NOTE]
> Si también tienes el kernel estándar `linux` instalado, ambos coexistirán en GRUB. El kernel g14 debería ser la primera opción de arranque por defecto.

---

## 🎮 Notas Finales: Gaming (Steam)

Con `supergfxctl` y las dependencias `lib32-nvidia-utils` de la Fase 2, Steam funcionará perfecto.

**Para jugar (recomendaciones por sesión):**

| Sesión | Paso previo | Lanzar Steam |
| --- | --- | --- |
| **KDE Plasma (Hybrid)** | Ya estás en modo Hybrid, la GPU se activa automáticamente | `steam` (normal) |
| **BSPWM (Integrated)** | Cambiar a modo Hybrid primero | `supergfxctl -m Hybrid` → cerrar sesión → `steam` |
| **BSPWM (Hybrid)** | Si ya estás en Hybrid | `steam` (normal) |

> [!TIP]
> Si estás en BSPWM con modo Integrated y quieres jugar:
> ```bash
> # 1. Cambiar a Hybrid
> supergfxctl -m Hybrid
> # 2. Cerrar sesión (log out) y volver a entrar
> # 3. Lanzar Steam normalmente
> steam
> # 4. Cuando termines de jugar, puedes volver a Integrated:
> supergfxctl -m Integrated
> # 5. Cerrar sesión y volver a entrar
> ```

<div align="center">
<sub>🚀 Guía Finalizada - 2026</sub>
</div>
