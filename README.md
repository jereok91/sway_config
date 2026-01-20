# 🚀 Configuración de Sway - Entorno de Escritorio Wayland

![Sway](https://img.shields.io/badge/Sway-Tiling%20WM-blue?style=for-the-badge&logo=wayland)
![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)

Una configuración completa y lista para producción de **Sway** (i3-compatible Wayland compositor), optimizada para productividad máxima con herramientas modernas, theming personalizado y atajos de teclado ergonómicos.

---

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Prerrequisitos](#-prerrequisitos)
- [Instalación](#-instalación)
- [Dependencias](#-dependencias)
- [Estructura del Repositorio](#-estructura-del-repositorio)
- [Atajos de Teclado](#-atajos-de-teclado)
- [Temas Incluidos](#-temas-incluidos)
- [Configuración Personalizada](#-configuración-personalizada)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Características

### 🎯 Componentes Principales

- **Window Manager**: Sway (Wayland compositor compatible con i3)
- **Terminal**: Foot (servidor/cliente), Alacritty, Kitty
- **Barra de estado**: Waybar con iconos y widgets personalizados
- **Lanzador de aplicaciones**: Rofi (con soporte Wayland)
- **Gestor de portapapeles**: cliphist + wl-clipboard
- **Notificaciones**: Mako con theming dinámico
- **Bloqueo de pantalla**: swaylock con scripts personalizados
- **Screenshots**: grim + grimshot + swappy para edición
- **Idle management**: swayidle + idlehack
- **Autotiling**: autotiling-rs para layouts automáticos
- **Gestión de brillo**: brightnessctl + wob (barra visual)
- **Gestión de audio**: PulseAudio/PipeWire con pulsemixer
- **Night light**: wlsunset para temperatura de color
- **Montaje automático**: PCManFM daemon
- **Multi-monitor**: way-displays + kanshi

### 🎨 Sistema de Temas

- **Temas incluidos**: Catppuccin (4 variantes), Dracula, Matcha (4 colores), Nordic
- **GTK Theme**: Orchis-Teal-Dark
- **Icon Theme**: Papirus
- **Cursor Theme**: Catppuccin-Macchiato-Dark
- **Fuentes**: Roboto (GUI) + RobotoMono Nerd Font (terminal)

### ⚡ Mejoras de Productividad

- Atajos de teclado vim-style (hjkl) y flechas
- Workspaces numerados (1-10) con navegación rápida
- Scratchpad para ventanas flotantes temporales
- Modos especializados: resize, screenshot, shutdown, recording
- Scripts utilitarios para gestión de workspaces y automatizaciones
- Historial de portapapeles persistente
- Selector de emojis con rofimoji
- Integración con playerctl para control multimedia

---

## 🔧 Prerrequisitos

### Drivers de Video

#### Para GPUs Intel/AMD:
```bash
sudo pacman -S mesa vulkan-intel vulkan-radeon
```

#### Para GPUs NVIDIA:
```bash
# Drivers propietarios
sudo pacman -S nvidia nvidia-utils

# Variables de entorno necesarias (agregar a /etc/environment o ~/.bash_profile):
export WLR_NO_HARDWARE_CURSORS=1
export WLR_RENDERER=vulkan
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export GBM_BACKEND=nvidia-drm
```

### Soporte Wayland

Asegúrate de que tu sistema tenga soporte completo para Wayland:

```bash
# Instalar protocolos Wayland base
sudo pacman -S wayland wayland-protocols xorg-xwayland
```

### Nerd Fonts

Esta configuración requiere **Nerd Fonts** para iconos en la barra y terminal:

```bash
# Instalar fuentes necesarias
sudo pacman -S ttf-roboto ttf-roboto-mono-nerd
# O instalar manualmente desde: https://www.nerdfonts.com/
```

### Sesión de Login

Para iniciar Sway desde TTY, agrega a tu `~/.bash_profile` o `~/.zprofile`:

```bash
if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
  exec sway
fi
```

---

## 📦 Instalación

### 1. Respalda tu configuración actual (si existe)

```bash
mv ~/.config/sway ~/.config/sway.backup
```

### 2. Clona este repositorio

```bash
git clone https://github.com/TU-USUARIO/sway-config.git ~/.config/sway
```

### 3. Instala las dependencias (ver sección siguiente)

### 4. Habilitar el Theme Switcher (Opcional)

Para usar el theme switcher interactivo como comando del sistema y en el launcher de aplicaciones:

**Opción A: Script automático (Recomendado)**
```bash
cd ~/.config/sway
./setup-theme-switcher.sh
```

Este script configurará automáticamente:
- ✅ Comando disponible desde terminal (`manjaro-sway-theme`)
- ✅ Entrada en el launcher de aplicaciones (Rofi/dmenu)
- ✅ PATH correctamente configurado
- ✅ Permisos de ejecución

**Opción B: Manual**
```bash
# Crear symlink en ~/.local/bin
mkdir -p ~/.local/bin
ln -sf ~/.config/sway/scripts/manjaro-sway-theme ~/.local/bin/manjaro-sway-theme

# Crear desktop entry
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/manjaro-sway-theme.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Sway Theme Switcher
GenericName=Theme Manager
Comment=Interactive theme switcher for Sway window manager
Exec=manjaro-sway-theme
Icon=preferences-desktop-theme
Terminal=false
Categories=Settings;DesktopSettings;GTK;
Keywords=theme;sway;appearance;colors;wayland;
StartupNotify=true
EOF

# Verificar que ~/.local/bin esté en tu PATH
echo $PATH | grep -q "$HOME/.local/bin" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

### 5. Recarga la configuración

Si ya estás en Sway:
```bash
# Presiona: Super + Shift + C
# O ejecuta:
swaymsg reload
```

Si no estás en Sway:
```bash
# Sal de tu sesión actual y selecciona "Sway" en tu display manager
# O desde TTY:
sway
```

---

## 📦 Dependencias

### Tabla de Herramientas Necesarias

| Estado | Categoría | Herramienta | Paquete | Instalación (Pacman) | Instalación (AUR) |
|--------|-----------|-------------|---------|----------------------|-------------------|
| [ ] | **Core** | Sway | `sway` | `sudo pacman -S sway` | - |
| [ ] | **Core** | Waybar | `waybar` | `sudo pacman -S waybar` | - |
| [ ] | **Core** | Rofi | `rofi-wayland` | `sudo pacman -S rofi-wayland` | - |
| [ ] | **Terminal** | Foot | `foot` | `sudo pacman -S foot` | - |
| [ ] | **Terminal** | Alacritty | `alacritty` | `sudo pacman -S alacritty` | - |
| [ ] | **Terminal** | Kitty | `kitty` | `sudo pacman -S kitty` | - |
| [ ] | **Clipboard** | wl-clipboard | `wl-clipboard` | `sudo pacman -S wl-clipboard` | - |
| [ ] | **Clipboard** | cliphist | `cliphist` | `sudo pacman -S cliphist` | - |
| [ ] | **Clipboard** | wl-clip-persist | `wl-clip-persist` | - | `yay -S wl-clip-persist` |
| [ ] | **Notificaciones** | Mako | `mako` | `sudo pacman -S mako` | - |
| [ ] | **Screenshot** | grim | `grim` | `sudo pacman -S grim` | - |
| [ ] | **Screenshot** | grimshot | `grimshot` | `sudo pacman -S grimshot` | - |
| [ ] | **Screenshot** | swappy | `swappy` | `sudo pacman -S swappy` | - |
| [ ] | **Screenshot** | slurp | `slurp` | `sudo pacman -S slurp` | - |
| [ ] | **Lock Screen** | swaylock | `swaylock` | `sudo pacman -S swaylock` | - |
| [ ] | **Idle** | swayidle | `swayidle` | `sudo pacman -S swayidle` | - |
| [ ] | **Idle** | idlehack | `idlehack` | - | `yay -S idlehack` |
| [ ] | **Brillo** | brightnessctl | `brightnessctl` | `sudo pacman -S brightnessctl` | - |
| [ ] | **Brillo** | wob | `wob` | `sudo pacman -S wob` | - |
| [ ] | **Audio** | pulseaudio | `pulseaudio` | `sudo pacman -S pulseaudio` | - |
| [ ] | **Audio** | pulsemixer | `pulsemixer` | `sudo pacman -S pulsemixer` | - |
| [ ] | **Audio** | playerctl | `playerctl` | `sudo pacman -S playerctl` | - |
| [ ] | **Layout** | autotiling | `autotiling-rs` | - | `yay -S autotiling-rs` |
| [ ] | **Night Light** | wlsunset | `wlsunset` | `sudo pacman -S wlsunset` | - |
| [ ] | **Multimedia** | playerctl | `playerctl` | `sudo pacman -S playerctl` | - |
| [ ] | **Archivos** | PCManFM | `pcmanfm-qt` | `sudo pacman -S pcmanfm-qt` | - |
| [ ] | **Monitor** | way-displays | `way-displays` | - | `yay -S way-displays` |
| [ ] | **Monitor** | kanshi | `kanshi` | `sudo pacman -S kanshi` | - |
| [ ] | **Polkit** | polkit-gnome | `polkit-gnome` | `sudo pacman -S polkit-gnome` | - |
| [ ] | **Bluetooth** | bluetuith | `bluetuith` | - | `yay -S bluetuith` |
| [ ] | **Calendar** | calcurse | `calcurse` | `sudo pacman -S calcurse` | - |
| [ ] | **Emoji** | rofimoji | `rofimoji` | `sudo pacman -S rofimoji` | - |
| [ ] | **System Monitor** | btop | `btop` | `sudo pacman -S btop` | - |
| [ ] | **Workspace Icons** | sworkstyle | `sworkstyle` | - | `yay -S sworkstyle` |
| [ ] | **Power Alert** | poweralertd | `poweralertd` | - | `yay -S poweralertd` |
| [ ] | **Flashfocus** | flashfocus | `flashfocus` | - | `yay -S flashfocus` |
| [ ] | **Autostart** | dex | `dex` | `sudo pacman -S dex` | - |
| [ ] | **Utils** | xdg-user-dirs | `xdg-user-dirs` | `sudo pacman -S xdg-user-dirs` | - |
| [ ] | **Notificaciones** | notify-send | `libnotify` | `sudo pacman -S libnotify` | - |
| [ ] | **Noise Suppression** | noisetorch | `noisetorch` | - | `yay -S noisetorch` |
| [ ] | **Network** | nm-applet | `network-manager-applet` | `sudo pacman -S network-manager-applet` | - |
| [ ] | **Fonts** | Roboto | `ttf-roboto` | `sudo pacman -S ttf-roboto` | - |
| [ ] | **Fonts** | Nerd Fonts | `ttf-roboto-mono-nerd` | `sudo pacman -S ttf-roboto-mono-nerd` | - |
| [ ] | **Themes** | Papirus Icons | `papirus-icon-theme` | `sudo pacman -S papirus-icon-theme` | - |
| [ ] | **Themes** | Orchis Theme | `orchis-theme` | - | `yay -S orchis-theme` |
| [ ] | **Themes** | Catppuccin Cursors | `catppuccin-cursors-macchiato` | - | `yay -S catppuccin-cursors-macchiato` |

### Script de Instalación Rápida

```bash
# Paquetes oficiales (Pacman)
sudo pacman -S --needed sway waybar rofi-wayland foot alacritty kitty \
  wl-clipboard cliphist mako grim grimshot swappy slurp swaylock swayidle \
  brightnessctl wob pulseaudio pulsemixer playerctl wlsunset pcmanfm-qt \
  kanshi polkit-gnome calcurse rofimoji btop dex xdg-user-dirs libnotify \
  network-manager-applet ttf-roboto ttf-roboto-mono-nerd papirus-icon-theme

# Paquetes AUR (Yay)
yay -S --needed wl-clip-persist idlehack autotiling-rs way-displays \
  bluetuith sworkstyle poweralertd flashfocus noisetorch orchis-theme \
  catppuccin-cursors-macchiato
```

---

## 📁 Estructura del Repositorio

```
~/.config/sway/
├── config                      # Configuración principal de Sway
├── autostart                   # Definiciones de aplicaciones al inicio
├── idle.yaml                   # Configuración de swayidle
├── fondo.jpg                   # Wallpaper 1
├── fondo2.jpg                  # Wallpaper 2 (activo)
├── setup-theme-switcher.sh     # Script de instalación del theme switcher
│
├── config.d/                   # Configuraciones modulares
│   ├── 10-keyboard.conf        # Layout de teclado
│   ├── 10-service.conf         # Servicios systemd
│   ├── 50-systemd-user.conf    # Integración systemd
│   ├── 90-enable-theme.conf    # Activación de temas
│   ├── 98-application-defaults.conf  # Apps por defecto
│   ├── 99-autostart-applications.conf  # Aplicaciones de inicio
│   ├── clipboard.conf          # Configuración de portapapeles
│   ├── menu.conf               # Configuración de rofi
│   └── theme.conf              # Configuración de fuentes y tema GTK
│
├── definitions.d/              # Definiciones de tema activo
│   ├── theme.conf              # Tema activo (colores y variables)
│   └── theme.light.conf_       # Backup de tema claro
│
├── inputs/                     # Configuración de dispositivos de entrada
│   ├── default-keyboard        # Config de teclado
│   └── default-touchpad        # Config de touchpad
│
├── modes/                      # Modos de Sway
│   ├── default                 # Modo por defecto
│   ├── resize                  # Modo redimensionar
│   ├── screenshot              # Modo capturas de pantalla
│   ├── recording               # Modo grabación
│   ├── scratchpad              # Modo scratchpad
│   └── shutdown                # Modo apagado/reinicio
│
├── scripts/                    # Scripts de utilidad
│   ├── brightness.sh           # Control de brillo
│   ├── lock.sh                 # Script de bloqueo
│   ├── waybar.sh               # Lanzador de waybar
│   ├── mako.sh                 # Configurador de mako
│   ├── screenshot-notify.sh    # Notificaciones de screenshots
│   ├── help.sh                 # Ayuda de atajos
│   ├── theme-toggle.sh         # Cambio de temas
│   ├── manjaro-sway-theme      # Theme switcher interactivo (GUI)
│   ├── sunset.sh               # Control de wlsunset
│   ├── wob.sh                  # Barra de progreso visual
│   ├── checkupdates.sh         # Verificador de actualizaciones
│   ├── first-empty-workspace.py # Encuentra workspace vacío
│   └── [otros scripts...]
│
├── templates/                  # Plantillas de configuración
│   ├── foot.ini                # Plantilla de Foot
│   ├── mako                    # Plantilla de Mako
│   ├── rofi/                   # Configuración de Rofi
│   │   ├── config.rasi
│   │   └── README.md
│   └── waybar/                 # Configuración de Waybar
│       ├── config.jsonc
│       ├── style.css
│       ├── color.css
│       └── README.md
│
└── themes/                     # Temas disponibles
    ├── catppuccin-frappe/
    ├── catppuccin-latte/
    ├── catppuccin-macchiato/
    ├── catppuccin-mocha/
    ├── dracula/
    ├── matcha-blue/
    ├── matcha-green/
    ├── matcha-leaf/
    ├── matcha-red/
    └── nordic-bluish-accent/  # Tema base activo (Nordic)
```

---

## ⌨️ Atajos de Teclado

### Modificadores

- `$mod` = **Super** (tecla Windows)
- `$alt_mod` = **Alt**

### Básicos

| Atajo | Acción |
|-------|--------|
| `Super + Enter` | Abrir terminal (Foot) |
| `Super + Ctrl + Enter` | Abrir Alacritty |
| `Super + Shift + Enter` | Abrir Kitty |
| `Super + D` | Abrir launcher (Rofi) |
| `Super + Shift + Q` | Cerrar ventana activa |
| `Super + Shift + C` | Recargar configuración |
| `Super + Shift + E` | Menú de apagado |

### Navegación (Vim-style)

| Atajo | Acción |
|-------|--------|
| `Super + H/J/K/L` | Mover foco (izq/abajo/arriba/der) |
| `Super + ←/↓/↑/→` | Mover foco (flechas) |
| `Super + Shift + H/J/K/L` | Mover ventana |
| `Super + Shift + ←/↓/↑/→` | Mover ventana (flechas) |

### Workspaces

| Atajo | Acción |
|-------|--------|
| `Super + [1-10]` | Cambiar a workspace N |
| `Super + Shift + [1-10]` | Mover ventana a workspace N |

### Layouts

| Atajo | Acción |
|-------|--------|
| `Super + B` | Split horizontal |
| `Super + V` | Split vertical |
| `Super + S` | Layout stacking |
| `Super + W` | Layout tabbed |
| `Super + E` | Toggle split |
| `Super + F` | Fullscreen |
| `Super + Shift + Space` | Toggle floating |
| `Super + Space` | Cambiar foco tiling/floating |
| `Super + A` | Foco en contenedor padre |

### Scratchpad

| Atajo | Acción |
|-------|--------|
| `Super + Shift + -` | Enviar ventana a scratchpad |
| `Super + -` | Mostrar/ocultar scratchpad |

### Modo Resize

| Atajo | Acción |
|-------|--------|
| `Super + R` | Entrar a modo resize |
| `H/J/K/L` (en modo) | Redimensionar |
| `←/↓/↑/→` (en modo) | Redimensionar |
| `Enter/Esc` | Salir del modo |

### Screenshots

| Atajo | Acción |
|-------|--------|
| `Super + Shift + G` | Modo screenshot |
| `O` (en modo) | Capturar pantalla completa |
| `P` (en modo) | Capturar región seleccionada |
| `Shift + O/P` | Capturar y subir a x0.at |
| `Print` | Screenshot rápido (grim) |

### Multimedia

| Atajo | Acción |
|-------|--------|
| `XF86AudioMute` | Mutear/desmutear |
| `XF86AudioLowerVolume` | Bajar volumen |
| `XF86AudioRaiseVolume` | Subir volumen |
| `XF86AudioMicMute` | Mutear micrófono |
| `XF86MonBrightnessDown` | Bajar brillo |
| `XF86MonBrightnessUp` | Subir brillo |

### Utilidades Adicionales

| Atajo | Descripción |
|-------|-------------|
| `Super + Shift + T` | Theme Switcher interactivo (si lo configuraste) |
| Ver `~/.config/sway/modes/` | Atajos de modos especializados |
| `Super + ?` | Mostrar ayuda de atajos (si está configurado) |

---

## 🎨 Temas Incluidos

Esta configuración incluye múltiples temas pre-configurados con dos formas de cambiarlos:

### Método 1: Theme Switcher Interactivo (Recomendado)

Usa la herramienta `manjaro-sway-theme` para cambiar temas de forma visual:

```bash
# Desde la terminal
manjaro-sway-theme

# Desde el launcher de aplicaciones
# Busca "Sway Theme Switcher" en Rofi/dmenu

# O presiona: Super + Shift + T (si configuraste el atajo)
```

Esta herramienta te permite:
- ✅ Seleccionar un tema dark y un tema light usando Rofi
- ✅ Elegir cuál será el tema primario
- ✅ Instalar automáticamente dependencias del tema (si existen)
- ✅ Aplicar el tema a Sway y Foot automáticamente
- ✅ Recargar Sway sin reiniciar

### Método 2: Manual

1. Edita `~/.config/sway/definitions.d/theme.conf`
2. Modifica las variables de color y tema según tus preferencias
3. Recarga Sway con `Super + Shift + C`

**Nota:** El tema activo se carga desde `definitions.d/theme.conf`, el cual es referenciado desde el archivo principal `config`. Puedes copiar cualquier tema de la carpeta `themes/` a este archivo para activarlo.

### Temas Disponibles

- **Catppuccin Frappe** - Palette suave y cálida
- **Catppuccin Latte** - Tema claro
- **Catppuccin Macchiato** - Balance entre oscuro y saturado
- **Catppuccin Mocha** - Oscuro con acentos vibrantes
- **Dracula** - Clásico tema oscuro con morados
- **Matcha Blue** - Verde azulado
- **Matcha Green** - Verde natural
- **Matcha Leaf** - Verde hoja
- **Matcha Red** - Rojo matcha
- **Nordic Bluish Accent** - Estilo nórdico con azul (activo)

Cada tema incluye:
- Colores de ventanas y bordes
- Configuración de Waybar
- Paleta de colores para Foot
- Variables para Rofi y Mako

---

## 🔧 Configuración Personalizada

### Cambiar el Wallpaper

Edita el archivo `~/.config/sway/config`:

```bash
output * bg ~/.config/sway/TU_IMAGEN.jpg fill
```

O coloca tu imagen en `~/.config/sway/` y actualiza la ruta.

### Configurar Multi-Monitor

Usa `swaymsg -t get_outputs` para ver tus monitores:

```bash
swaymsg -t get_outputs
```

Luego edita `~/.config/sway/config` o crea un archivo en `config.d/`:

```bash
# Ejemplo:
output HDMI-A-1 resolution 1920x1080 position 0,0
output eDP-1 resolution 1920x1080 position 1920,0
```

### Cambiar el Layout de Teclado

Edita `~/.config/sway/config.d/10-keyboard.conf`:

```bash
input type:keyboard {
    xkb_layout "us"
    xkb_variant "altgr-intl"
}
```

### Personalizar Waybar

Los archivos de configuración están en `~/.config/waybar/`:
- `config.jsonc` - Módulos y estructura
- `style.css` - Estilos visuales
- `color.css` - Colores del tema

### Agregar Aplicaciones al Autostart

Edita `~/.config/sway/config.d/99-autostart-applications.conf` y agrega:

```bash
exec tu-aplicacion
```

### Configurar Atajo para Theme Switcher

Para agregar un atajo de teclado al theme switcher, edita `~/.config/sway/modes/default` y agrega:

```bash
## Launch // Theme Switcher ##
bindsym $mod+Shift+t exec manjaro-sway-theme
```

Luego recarga Sway con `Super + Shift + C`.

---

## 🐛 Troubleshooting

### Sway no arranca

1. Verifica logs:
```bash
journalctl --user -u sway -b
```

2. Revisa variables de entorno NVIDIA (si aplica)
3. Asegúrate de tener instalado `xorg-xwayland`

### Waybar no se ve

```bash
# Reinicia Waybar manualmente
killall waybar
waybar &
```

### Screenshots no funcionan

Verifica que tienes instalados:
```bash
sudo pacman -S grim slurp swappy
```

### El portapapeles no persiste

```bash
# Verifica que cliphist está corriendo
ps aux | grep cliphist

# Reinicia manualmente
wl-paste --watch cliphist store &
```

### Aplicaciones GTK se ven feas

```bash
# Instala herramientas de tema GTK
sudo pacman -S lxappearance

# Ejecuta y selecciona tu tema
lxappearance
```

### Fonts con iconos rotos

Instala Nerd Fonts:
```bash
sudo pacman -S ttf-nerd-fonts-symbols-mono
# O específicamente:
sudo pacman -S ttf-roboto-mono-nerd
```

### Brillo no se ajusta

```bash
# Agrega tu usuario al grupo video
sudo usermod -aG video $USER
# Cierra sesión y vuelve a entrar
```

### Theme Switcher no funciona

```bash
# Verifica que el script esté en el PATH
which manjaro-sway-theme

# Si no está, crea el symlink
mkdir -p ~/.local/bin
ln -sf ~/.config/sway/scripts/manjaro-sway-theme ~/.local/bin/manjaro-sway-theme

# Verifica permisos de ejecución
chmod +x ~/.config/sway/scripts/manjaro-sway-theme

# Asegúrate de que ~/.local/bin esté en el PATH
echo $PATH | grep -q "$HOME/.local/bin" || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 📚 Recursos Adicionales

- [Sway Wiki](https://github.com/swaywm/sway/wiki)
- [Sway Manual](https://man.archlinux.org/man/sway.5)
- [Waybar Wiki](https://github.com/Alexays/Waybar/wiki)
- [ArchWiki - Sway](https://wiki.archlinux.org/title/Sway)
- [Wayland Book](https://wayland-book.com/)

---

## 📝 Licencia

Esta configuración es de uso libre. Úsala, modifícala y compártela como quieras.

---

## 🤝 Contribuciones

Si encontraste un bug o tenés mejoras, sentite libre de abrir un issue o pull request.

---

**¡Disfrutá de tu entorno Sway!** 🚀

Si tenés dudas o problemas, revisá primero la sección de Troubleshooting y los logs del sistema.
