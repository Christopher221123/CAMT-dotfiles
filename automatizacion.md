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