<div align="center">

# 🐧 Arch Linux — Guía de Instalación Completa

### Dual Boot con Windows · Intel + NVIDIA · BSPWM + Gh0stzk Rice

![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)
![NVIDIA](https://img.shields.io/badge/NVIDIA-76B900?style=for-the-badge&logo=nvidia&logoColor=white)
![Intel](https://img.shields.io/badge/Intel-0071C5?style=for-the-badge&logo=intel&logoColor=white)
![BSPWM](https://img.shields.io/badge/BSPWM-2E3440?style=for-the-badge&logo=linux&logoColor=white)
![KDE](https://img.shields.io/badge/KDE_Plasma-1D99F3?style=for-the-badge&logo=kde&logoColor=white)
![Steam](https://img.shields.io/badge/Steam-000000?style=for-the-badge&logo=steam&logoColor=white)

---

**Usuario:** Christopher Alexis Muzo Trujillo

**Filosofía:** Arch primero, minimalismo absoluto, gráficos bajo demanda.

</div>

---

## 📑 Tabla de Contenidos

- [1. 🏗️ Fase de Preparación (Archinstall / Base)](#-1-fase-de-preparación-archinstall--base)
  - [⚠️ En caso de que instalaste primero Windows](#️-en-caso-de-que-instalaste-primero-windows)
- [2. 🏎️ Drivers y Gráficos (Intel + NVIDIA)](#️-2-drivers-y-gráficos-intel--nvidia)
- [3. 🎨 Entorno de Trabajo (Gh0stzk + BSPWM)](#-3-entorno-de-trabajo-gh0stzk--bspwm)
- [4. 🛠️ Capa de Utilidad (KDE Plasma Minimal)](#️-4-capa-de-utilidad-kde-plasma-minimal)
- [5. 🎮 Gaming y Aplicaciones Especiales](#-5-gaming-y-aplicaciones-especiales)
- [6. 🧹 Limpieza y Auditoría (Post-Instalación)](#-6-limpieza-y-auditoría-post-instalación)
- [7. 🧪 Pruebas de Verificación](#-7-pruebas-de-verificación)

---

## 🏗️ 1. Fase de Preparación (Archinstall / Base)

Al usar `archinstall` o manual, vamos a tener siempre en cuenta esto:

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

---

### ⚠️ En caso de que instalaste primero Windows

<details>
<summary>📖 <strong>Click aquí para expandir la guía de reparación de arranque Windows + Linux</strong></summary>

<br>

#### 1. Requisitos Previos

- Un USB con el instalador de Windows (10 u 11).
- Saber que los **números de volumen cambian** en cada reinicio (no confiar en memoria).
- **Para mi laptop en especifico tener los controladores IRST** (Para que pueda reconocer los discos ya que en mi procesador i9 12va generacion hay ese problema).

---

#### 2. Acceder a la Consola

1. Conecta el USB y arranca el PC desde él (UEFI).
2. Avanzamos hasta llegar al punto de selección de disco.
3. Instalamos el IRST y regresamos hasta la pantalla de selección de idioma.
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

1. Reinicia y entra a la seleccionamos Arch Linux.
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

## 🏎️ 2. Drivers y Gráficos (Intel + NVIDIA)

Instalación de los controladores gráficos para el correcto funcionamiento.

### 📦 Instalación de Drivers

Instalamos todos los drivers para evitar el error de dependencias de 32 bits:

```bash
sudo pacman -Syu
sudo pacman -S mesa lib32-mesa vulkan-intel lib32-vulkan-intel intel-media-driver nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime
```

### 🖥️ Fix de Pantalla Negra (Early KMS)

Editar `/etc/mkinitcpio.conf`:

1. En la línea `MODULES=()` agregar:

   ```
   intel_agp i915 nvidia nvidia_modeset nvidia_uvm nvidia_drm
   ```

2. Regenerar:

   ```bash
   sudo mkinitcpio -P
   ```

---

## 🎨 3. Entorno de Trabajo (Gh0stzk + BSPWM)

En esta fase pasamos de la terminal básica a la interfaz gráfica personalizada. Seguiremos un orden de "Capas": primero la base, luego el ayudante de AUR, y al final la estética.

### A. Capa Base: Video y AUR Helper (`yay`)

Antes de cualquier otra cosa, necesitamos el servidor de video y la herramienta para instalar paquetes de la comunidad.

1. **Instalar base de video:**

   ```bash
   sudo pacman -S xorg-server xorg-xinit xorg-xrandr
   ```

2. **Instalar `yay` (Indispensable para el Rice):**

   ```bash
   cd ~
   sudo pacman -S --needed base-devel git
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   ```

---

### B. Capa de Estabilidad: Pre-requisitos del Rice

Para evitar errores como el de `fzf-tab` (ZSH) o iconos rotos, instalamos los componentes críticos **antes** de correr el script de Gh0stzk.

1. **Dependencias Core:**

   ```bash
   sudo pacman -S bspwm sxhkd polybar picom dunst rofi thunar feh maim xdotool xclip
   ```

2. **Fuentes e Iconos (Evita los cuadros con X):**

   ```bash
   sudo pacman -S ttf-jetbrains-mono-nerd ttf-jetbrains-mono ttf-font-awesome
   ```

3. **Fix preventivo para ZSH (El error del directorio):**

   ```bash
   sudo mkdir -p /usr/share/zsh/plugins/
   sudo git clone https://github.com/Aloxaf/fzf-tab /usr/share/zsh/plugins/fzf-tab-git
   ```

---

### C. Capa Estética: Ejecución del RiceInstaller

Ahora que el sistema tiene todo lo necesario, el instalador de Gh0stzk funcionará de manera fluida.

```bash
# Descargar el instalador oficial
curl -LO http://gh0stzk.github.io/dotfiles/RiceInstaller

# Dar permisos y ejecutar
chmod +x RiceInstaller
./RiceInstaller
```

> [!NOTE]
> Durante el `RiceInstaller`, cuando pregunte por instalar dependencias, dile que **SÍ**. Aunque ya las instalamos, el script hará una verificación final y configurará los archivos `.config` de forma automática.

---

## 🛠️ 4. Capa de Utilidad (KDE Plasma Minimal)

Instalamos KDE solo para tener las herramientas de sistema cuando las necesites, pero sin el "bloat".

```bash
sudo pacman -S plasma-desktop sddm dolphin konsole
```

> [!IMPORTANT]
> Si vas a usar **LightDM** (como pidió Christopher), no instales `sddm`.

---

## 🎮 5. Gaming y Aplicaciones Especiales

Para que Elden Ring y tus tareas de la PUCESA funcionen:

| **Aplicación** | **Comando de Instalación** | **Notas** |
| --- | --- | --- |
| **Steam** | `sudo pacman -S steam` | — |
| **Modo High Performance** | — | Usar siempre `prime-run %command%` en las opciones de lanzamiento de Steam. |
| **Notion** | `paru -S notion-app-electron` | Instalado desde AUR. |

---

## 🧹 6. Limpieza y Auditoría (Post-Instalación)

Para mantener el sistema como un "sistema de ingeniería":

| **Comando** | **Función** |
| --- | --- |
| `pacman -Qqe` | Ver lista de paquetes instalados explícitamente. |
| `sudo pacman -Rs $(pacman -Qdtq)` | Eliminar huérfanos (usar con cuidado). |
| `sudo paccache -r` | Limpiar caché de paquetes viejos. |

---

## 🧪 7. Pruebas de Verificación

| **Verificación** | **Comando** |
| --- | --- |
| ¿Gráfica Intel activa? | `glxinfo \| grep "OpenGL renderer"` |
| ¿NVIDIA despierta? | `prime-run glxinfo \| grep "OpenGL renderer"` |
| ¿Audio ok? | `wpctl status` |

---

<div align="center">

### 💡 ¿Próximo paso?

¿Qué te parece esta estructura para tu Notion, Christopher? Si quieres, **podemos redactar el script automático (.sh)** que ejecute todos estos pasos de una sola vez para que tu próxima instalación sea literalmente apretar un botón y sentarte a ver cómo se configura sola. ¿Te gustaría que hagamos eso?

---

<sub>📅 Última actualización — Febrero 2026</sub>

</div>
