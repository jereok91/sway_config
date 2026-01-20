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
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    REC_FILE=".bashrc"
    echo "✅ Añadido a ~/.bashrc"
    ;;
  zsh)
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    REC_FILE=".zshrc"
    echo "✅ Añadido a ~/.zshrc"
    ;;
  fish)
    mkdir -p "$HOME/.config/fish"
    echo 'set -gx PATH $HOME/.local/bin $PATH' >> "$HOME/.config/fish/config.fish"
    REC_FILE="config.fish"
    echo "✅ Añadido a config.fish"
    ;;
  *)
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.profile"
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
echo "  2. Add a keybinding in ~/.config/sway/modes/default:"
echo "     bindsym \$mod+Shift+t exec manjaro-sway-theme"
echo ""
echo "Enjoy! 🚀"
