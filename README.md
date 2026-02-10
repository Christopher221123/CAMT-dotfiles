**Usuario:** Christopher Alexis Muzo Trujillo

**Filosofía:** Arch primero, minimalismo absoluto, gráficos bajo demanda. 

---

## 🏗️ 1. Fase de Preparación (Archinstall / Base)

Al usar `archinstall` o manual, vamos a tener siempre en cuenta esto:

- **Orden de SO:** Instalar Arch Linux **siempre primero**. (Si instalamos Windows de primer punto lo que lograremos es que cuando instalemos arch el arranque de windows se rompa).
    - **EN CASO DE QUE INSTALASTE PRIMERO WINDOWS**
        
        ### 1. Requisitos Previos
        
        - Un USB con el instalador de Windows (10 u 11).
        - Saber que los **números de volumen cambian** en cada reinicio (no confiar en memoria).
        - **Para mi laptop en especifico tener los controladores IRST** (Para que pueda reconocer los discos ya que en mi procesador i9 12va generacion hay ese problema)
        
        ---
        
        ### 2. Acceder a la Consola
        
        1. Conecta el USB y arranca el PC desde él (UEFI).
        2. Avanzamos hasta llegar al punto de seleccion de disco
        3. Instalamos el IRST y regresamos  hasta la pantalla de seleccion de idioma
        4. En la primera pantalla (selección de idioma), presiona:
            
            > **SHIFT + F10**
            > 
        5. Se abrirá una ventana negra (`cmd`).
        
        ---
        
        ### 3. Identificar las Particiones (Diskpart)
        
        Aquí es donde debes tener cuidado. No mires los números, **mira los tamaños y formatos**.
        
        Ejecuta estos comandos en orden:
        
        PowerShell
        
        `diskpart
        list vol`
        
        ### 🔍 Qué buscar en la lista:
        
        | **Tipo de Partición** | **Sistema de Archivos (Fs)** | **Tamaño (aprox.)** | **Pista Visual** | **Acción** |
        | --- | --- | --- | --- | --- |
        | **EFI (Arranque)** | **FAT32** | 100 MB - 1024 MB | Suele decir "Hidden" | Asignaremos letra **Z** |
        | **Windows** | **NTFS** | Gigantes (ej. 476 GB) | Es tu disco principal | **Anotar su letra actual** |
        | *CD-ROM/USB* | *CDFS / exFAT* | *Pequeños o 4GB+* | *Dice "Removable" o DVD* | *IGNORAR* ❌ |
        
        ---
        
        ## 4. Asignar Letra a la EFI
        
        PowerShell
        
        `select vol Num    <-- ¡Cambia el Num por el número que veas en ESE momento en la parte EFI!
        assign letter=Z
        exit`
        
        *(El `exit` te saca de diskpart pero deja la ventana negra abierta).*
        
        ---
        
        ## 5. El Comando de Reparación
        
        La estructura del comando es: `Copia desde [Windows] hacia [Z:]`
        
        Mira qué letra tiene tu partición **NTFS Gigante** (Windows).
        
        - Si es la letra **C**, el comando es `C:\Windows`
        - Si es la letra **D**, el comando es `D:\Windows`
        - Si es la letra **G**, el comando es `G:\Windows`
        
        **Ejecuta el comando final:**
        
        PowerShell
        
        `bcdboot X:\Windows /s Z: /f UEFI`
        
        *(Sustituye la **X** por la letra de tu partición de Windows).*
        
        ✅ **Éxito:** Debe decir *"Boot files successfully created"*.
        
        ❌ **Error:** Si dice *"Failure..."*, revisa que no estés apuntando al CD-ROM o al USB por error.
        
        ---
        
        ## 6. Recuperar el Menú de Linux (GRUB)
        
        1. Reinicia y entra a la seleccionamos Arch Linux.
        2. Inicia sesión en tu Arch Linux / Distro.
        3. Abre la terminal y actualiza el GRUB para que detecte el Windows arreglado:
        
        Bash
        
        `# Paso 1: Habilitar el detector de otros sistemas
        sudo os-prober
        
        # Paso 2: Regenerar el archivo de configuración
        sudo grub-mkconfig -o /boot/grub/grub.cfg`
        
- **Particionamiento:** `/home` **dentro de la raíz** (`/`). No separar particiones para evitar conflictos de permisos y espacio.
- **Bootloader:** GRUB (instalar `os-prober` para detectar Windows después).
- **Perfil:** Minimal / Base (Sin entorno de escritorio aún).
- **Paquetes adicionales**
    - `firefox` (Para buscar soluciones si algo falla).
    - `os-prober` (Para el Dual Boot).
    - `ntfs-3g` (Para que Arch pueda leer/escribir en tu partición de Windows).
    - `git` y `base-devel` (Para instalar `yay` y tus dotfiles).
    - `nano`  Editor de texto

---

## 🏎️ 2. Drivers y Gráficos (Intel + NVIDIA)

Instalacion de los controladores graficos para el correcto funcionamiento

### Instalacion de Drivers

Instalamos todos los drivers para evitar el error de dependencias de 32 bits:

Bash

### Fix de Pantalla Negra (Early KMS)

Editar `/etc/mkinitcpio.conf`:

1. En la línea `MODULES=()` agregar: `intel_agp i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm`.
2. Regenerar: `sudo mkinitcpio -P`.

---

## 🎨 3. Entorno de Trabajo (Gh0stzk + BSPWM)

En esta fase pasamos de la terminal básica a la interfaz gráfica personalizada. Seguiremos un orden de "Capas": primero la base, luego el ayudante de AUR, y al final la estética.

### A. Capa Base: Video y AUR Helper (`yay`)

Antes de cualquier otra cosa, necesitamos el servidor de video y la herramienta para instalar paquetes de la comunidad.

1. **Instalar base de video:**Bash
    
    `sudo pacman -S xorg-server xorg-xinit xorg-xrandr`
    
2. **Instalar `yay` (Indispensable para el Rice):**Bash
    
    `cd ~
    sudo pacman -S --needed base-devel git
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si`
    

---

### B. Capa de Estabilidad: Pre-requisitos del Rice

Para evitar errores como el de `fzf-tab` (ZSH) o iconos rotos, instalamos los componentes críticos **antes** de correr el script de Gh0stzk.

1. **Dependencias Core:**Bash
    
    `sudo pacman -S bspwm sxhkd polybar picom dunst rofi thunar feh maim xdotool xclip`
    
2. **Dependencias de temas:**Bash
    
    `sudo pacman -S ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-font-awesome`
    
3. **Fix preventivo para ZSH :**Bash
    
    `sudo mkdir -p /usr/share/zsh/plugins/
    sudo git clone https://github.com/Aloxaf/fzf-tab /usr/share/zsh/plugins/fzf-tab-git`
    

---

### C. Capa Estética: Ejecución del RiceInstaller

Ahora que el sistema tiene todo lo necesario, el instalador de Gh0stzk funcionará de manera fluida.

Bash

`# Descargar el instalador oficial
curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller

# Dar permisos y ejecutar
chmod +x RiceInstaller
./RiceInstaller`

`#`Instalar EnvyControl 
yay -S envycontrol

---

## 🖥️ 4. Gestor de Inicio de Sesión (LightDM)

### A. Instalación de Componentes

`sudo pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings`

### B. Configuración Crítica para Hardware Moderno

Como tu laptop tiene un **i9 de 12va generación** y gráficos híbridos, el sistema arranca tan rápido que LightDM puede intentar abrirse antes de que los drivers de video estén listos. Para evitar una pantalla negra, haz este ajuste:

1. **Editar el archivo de configuración:**Bash
    
    `sudo nano /etc/lightdm/lightdm.conf`
    
2. Busca la sección `[LightDM]` (está casi al principio).
3. Descomenta (quita el `#`) o añade la siguiente línea:
`logind-check-graphical=true`
4. Guarda y sal (`Ctrl+O`, `Enter`, `Ctrl+X`).

### C. Activación del Servicio

Este paso es el que le dice a Arch que, al encender, debe lanzar la interfaz gráfica automáticamente.

Bash

`sudo systemctl enable lightdm`

---

## 5. Configuración Avanzada: Energía y Pantalla (BSPWM)

Aquí es donde configuramos que el sistema sea inteligente y cambie los hercios según si estás conectado a la corriente o usando la batería.

### A. Script de Control de Hercios (Auto-Refresh)

Crearemos un script que detecte el estado del cargador. En tu laptop i9 con pantalla de 300Hz, esto ahorrará muchísima batería.

1. **Crear el script:** `nano ~/.config/bspwm/scripts/power_profile.sh`
2. **Pegar el siguiente código:**

Bash

`#!/bin/bash

# Identificar pantalla (usualmente eDP-1)
MONITOR=$(xrandr | grep " connected" | cut -d' ' -f1)

while true; do
    # Verificar si el cargador está conectado (1 = AC, 0 = Batería)
    AC_STATUS=$(cat /sys/class/power_supply/AC/online)

    if [ "$AC_STATUS" -eq 1 ]; then
        # MODO CORRIENTE: 300Hz
        xrandr --output "$MONITOR" --mode 1920x1080 --rate 300.00
    else
        # MODO BATERÍA: 60Hz
        xrandr --output "$MONITOR" --mode 1920x1080 --rate 60.00
    fi
    
    # Esperar 5 segundos antes de volver a verificar
    sleep 5
done`

1. **Dar permisos de ejecución:**

Bash

`chmod +x ~/.config/bspwm/scripts/power_profile.sh`

---

### B. Integración en BSPWM

Para que esto funcione apenas entres a tu entorno de Gh0stzk:

1. **Editar bspwmrc:** `nano ~/.config/bspwm/bspwmrc`
2. **Añadir la ejecución al final del archivo:**

Bash

`# Control de energía y tasa de refresco automática
~/.config/bspwm/scripts/power_profile.sh &`

---

### C. Desactivar Módulos Innecesarios (Limpieza)

Como quieres mantener el tema por defecto pero más limpio:

1. **Polybar (Quitar MPD y WiFi fix):**
    - Edita tu `config.ini` de la Polybar.
    - En `modules-right` (o donde esté), borra la palabra `mpd`.
    - Busca la sección `[module/wlan]` y asegúrate de que el nombre de la interfaz coincida con el de tu comando `ip link` (ej. `wlan0` o `wlp2s0`).
2. **Apagar servicios de música:**

Bash

`systemctl --user stop mpd
systemctl --user disable mpd`