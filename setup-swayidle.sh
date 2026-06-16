#!/bin/bash
# setup-swayidle.sh
# One-shot setup for the swayidle systemd integration.
#
# This script:
#   1. Creates the symlink ~/.config/systemd/user/swayidle.service
#      -> ~/.config/sway/systemd/user/swayidle.service so systemd
#      can find the unit tracked in this repo.
#   2. Patches the broken "include /etc/sway/autostart" line in
#      the sway config (the file does not exist on most installs).
#   3. Reloads the systemd user daemon and enables + starts the
#      swayidle.service.
#
# It is safe to re-run: existing symlinks/config are preserved.

set -e

# Resolve paths relative to this script so it works no matter where
# it is invoked from (autostart, terminal, etc.).
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"

SERVICE_SRC="$REPO_DIR/systemd/user/swayidle.service"
SERVICE_DST_DIR="$HOME/.config/systemd/user"
SERVICE_DST="$SERVICE_DST_DIR/swayidle.service"
CONFIG_FILE="$REPO_DIR/config"

# Coloured output
if [ -t 1 ]; then
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    GREEN=''; YELLOW=''; RED=''; BLUE=''; NC=''
fi

step()  { printf "\n${BLUE}==>${NC} %s\n" "$*"; }
ok()    { printf "  ${GREEN}✓${NC} %s\n" "$*"; }
warn()  { printf "  ${YELLOW}⚠${NC}  %s\n" "$*"; }
fail()  { printf "  ${RED}✗${NC} %s\n" "$*" >&2; }

echo "🔒 Sway idle (swayidle) setup"

# ----------------------------------------------------------------------------
# 1. Sanity check: the versioned unit must exist in the repo
# ----------------------------------------------------------------------------
step "1. Verify the versioned service file"
if [ ! -f "$SERVICE_SRC" ]; then
    fail "Source service not found: $SERVICE_SRC"
    echo "      Re-clone the repo or restore systemd/user/swayidle.service."
    exit 1
fi
ok "Found $SERVICE_SRC"

# ----------------------------------------------------------------------------
# 2. Create the symlink so systemd can load the unit
# ----------------------------------------------------------------------------
step "2. Create symlink in ~/.config/systemd/user/"
mkdir -p "$SERVICE_DST_DIR"

if [ -L "$SERVICE_DST" ]; then
    TARGET="$(readlink -f "$SERVICE_DST")"
    if [ "$TARGET" = "$SERVICE_SRC" ]; then
        ok "Symlink already in place"
    else
        warn "Symlink points to $TARGET, expected $SERVICE_SRC. Re-linking."
        ln -sf "$SERVICE_SRC" "$SERVICE_DST"
        ok "Symlink re-created"
    fi
elif [ -e "$SERVICE_DST" ]; then
    warn "$SERVICE_DST exists and is not a symlink. Backing up to ${SERVICE_DST}.bak"
    mv "$SERVICE_DST" "${SERVICE_DST}.bak"
    ln -sf "$SERVICE_SRC" "$SERVICE_DST"
    ok "Replaced with symlink"
else
    ln -sf "$SERVICE_SRC" "$SERVICE_DST"
    ok "Created symlink"
fi

# ----------------------------------------------------------------------------
# 3. Patch the broken include path in the sway config
# ----------------------------------------------------------------------------
step "3. Check sway config include path"
if [ ! -f "$CONFIG_FILE" ]; then
    warn "Config file not found at $CONFIG_FILE, skipping"
else
    if grep -qE '^[[:space:]]*include[[:space:]]+/etc/sway/autostart([[:space:]]|$)' "$CONFIG_FILE"; then
        warn "Found broken 'include /etc/sway/autostart' in $CONFIG_FILE"
        sed -i 's|^[[:space:]]*include[[:space:]]\+/etc/sway/autostart[[:space:]]*$|include ~/.config/sway/autostart|' "$CONFIG_FILE"
        ok "Patched to 'include ~/.config/sway/autostart'"
    elif grep -qE '^[[:space:]]*include[[:space:]]+~/\.config/sway/autostart([[:space:]]|$)' "$CONFIG_FILE"; then
        ok "Include path already correct"
    else
        warn "No 'include ... autostart' line matched in $CONFIG_FILE"
        echo "      Make sure the autostart variables are loaded."
    fi
fi

# ----------------------------------------------------------------------------
# 4. Reload systemd user daemon
# ----------------------------------------------------------------------------
step "4. Reload systemd user daemon"
if ! command -v systemctl >/dev/null 2>&1; then
    fail "systemctl not found; cannot manage systemd services."
    exit 1
fi

# This will silently no-op if no systemd user session is running yet
# (e.g. when called too early during sway startup); the next reload
# on sway restart will pick things up.
systemctl --user daemon-reload 2>/dev/null \
    && ok "Daemon reloaded" \
    || warn "Could not reload daemon now (will retry on next sway start)"

# ----------------------------------------------------------------------------
# 5. Enable and start the service
# ----------------------------------------------------------------------------
step "5. Enable and start swayidle.service"

enable_swayidle() {
    if systemctl --user is-enabled swayidle.service >/dev/null 2>&1; then
        ok "swayidle.service is already enabled"
    else
        systemctl --user enable swayidle.service
        ok "Enabled swayidle.service"
    fi

    if systemctl --user is-active swayidle.service >/dev/null 2>&1; then
        ok "swayidle.service is already running"
    else
        systemctl --user start swayidle.service \
            && ok "Started swayidle.service" \
            || warn "Could not start swayidle.service (will try again on next sway reload)"
    fi
}

enable_swayidle \
    || warn "Failed to enable/start swayidle.service. Check 'systemctl --user status swayidle'."

# ----------------------------------------------------------------------------
# 6. Final report
# ----------------------------------------------------------------------------
step "6. Status"
if command -v systemctl >/dev/null 2>&1; then
    if systemctl --user status swayidle.service >/dev/null 2>&1; then
        systemctl --user --no-pager status swayidle.service | sed 's/^/      /'
    else
        warn "swayidle.service is not running."
        echo "      Try: systemctl --user start swayidle"
    fi
fi

printf "\n${GREEN}✅ Setup complete.${NC}\n"
printf "   Re-run this script any time you update %s.\n" "$SERVICE_SRC"
