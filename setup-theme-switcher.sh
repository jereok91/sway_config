#!/bin/bash

# Post-installation script for Sway Theme Switcher
# This script sets up the manjaro-sway-theme tool as a system command

set -e

echo "🎨 Setting up Sway Theme Switcher..."

# Create ~/.local/bin if it doesn't exist
mkdir -p "$HOME/.local/bin"

# Make the script executable
chmod +x "$HOME/.config/sway/scripts/manjaro-sway-theme"

# Create symlink
ln -sf "$HOME/.config/sway/scripts/manjaro-sway-theme" "$HOME/.local/bin/manjaro-sway-theme"

echo "📱 Creating desktop entry for application launcher..."

# Create ~/.local/share/applications if it doesn't exist
mkdir -p "$HOME/.local/share/applications"

# Create the .desktop file
cat >"$HOME/.local/share/applications/manjaro-sway-theme.desktop" <<'EOF'
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

chmod +x "$HOME/.local/share/applications/manjaro-sway-theme.desktop"

# Update desktop database (if available)
if command -v update-desktop-database &>/dev/null; then
	update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
	echo "✅ Desktop database updated"
fi

echo "✅ Desktop entry created - Theme Switcher will appear in your app launcher"

# Check if ~/.local/bin is in PATH
if echo "$PATH" | grep -q "$HOME/.local/bin"; then
	echo "✅ ~/.local/bin is already in your PATH"
else
	echo "⚠️  Adding ~/.local/bin to your PATH..."

	echo $SHELL
	echo $BASH_VERSION
	SHELL_NAME="$(basename "$SHELL")"
	REC_FILE=""
	# Detect shell and add to appropriate rc file
	case "$SHELL_NAME" in
	bash)
		echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.bashrc"
		REC_FILE=".bashrc"
		echo "✅ Añadido a ~/.bashrc"
		;;
	zsh)
		echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.zshrc"
		REC_FILE=".zshrc"
		echo "✅ Añadido a ~/.zshrc"
		;;
	fish)
		mkdir -p "$HOME/.config/fish"
		echo 'set -gx PATH $HOME/.local/bin $PATH' >>"$HOME/.config/fish/config.fish"
		REC_FILE="config.fish"
		echo "✅ Añadido a config.fish"
		;;
	*)
		echo 'export PATH="$HOME/.local/bin:$PATH"' >>"$HOME/.profile"
		echo "✅ Shell no reconocido. Añadido a ~/.profile"
		;;
	esac

	echo "ℹ️  Please restart your shell or run: source $RREC_FILE (or your shell's rc file)"
fi

echo ""
echo "✅ Theme Switcher setup complete!"
echo ""
echo "Usage:"
echo "  1. From terminal: manjaro-sway-theme"
echo "  2. From app launcher: Search for 'Sway Theme Switcher' in Rofi/dmenu"
echo "  3. Add a keybinding in ~/.config/sway/modes/default:"
echo "     bindsym \$mod+Shift+t exec manjaro-sway-theme"
echo ""
echo "Enjoy! 🚀"
