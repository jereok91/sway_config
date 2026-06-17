#!/bin/bash
# setup-sworkstyle.sh
# One-shot setup for the sworkstyle systemd integration.
#
# This script:
#   1. Creates the symlink ~/.config/systemd/user/sworkstyle.service
#      -> ~/.config/sway/systemd/user/sworkstyle.service so systemd
#      can find the unit tracked in this repo.
#   2. Reloads the systemd user daemon and enables + starts the
#      sworkstyle.service.
#
# It is safe to re-run: existing symlinks are preserved.
#
# Requirement: sworkstyle must be installed first. If not, install
# it from AUR:
#     yay -S sworkstyle

set -e

SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# The script lives at the root of the repo (~/.../sway/setup-sworkstyle.sh),
# so the repo dir is the script dir itself.
REPO_DIR="$SCRIPT_DIR"

SERVICE_SRC="$REPO_DIR/systemd/user/sworkstyle.service"
SERVICE_DST_DIR="$HOME/.config/systemd/user"
SERVICE_DST="$SERVICE_DST_DIR/sworkstyle.service"

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

echo "🎨 Swayest Workstyle setup"

# ----------------------------------------------------------------------------
# 0. Sanity check: sworkstyle must be installed
# ----------------------------------------------------------------------------
step "0. Verify sworkstyle is installed"
if ! command -v sworkstyle >/dev/null 2>&1; then
    fail "sworkstyle is not installed."
    echo "      Install it from AUR:  yay -S sworkstyle"
    echo "      Then re-run this script."
    exit 1
fi
ok "Found $(command -v sworkstyle)"

# ----------------------------------------------------------------------------
# 1. Sanity check: the versioned unit must exist in the repo
# ----------------------------------------------------------------------------
step "1. Verify the versioned service file"
if [ ! -f "$SERVICE_SRC" ]; then
    fail "Source service not found: $SERVICE_SRC"
    echo "      Re-clone the repo or restore systemd/user/sworkstyle.service."
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
# 3. Reload systemd user daemon
# ----------------------------------------------------------------------------
step "3. Reload systemd user daemon"
if ! command -v systemctl >/dev/null 2>&1; then
    fail "systemctl not found; cannot manage systemd services."
    exit 1
fi

systemctl --user daemon-reload 2>/dev/null \
    && ok "Daemon reloaded" \
    || warn "Could not reload daemon now (will retry on next sway start)"

# ----------------------------------------------------------------------------
# 4. Enable and start the service
# ----------------------------------------------------------------------------
step "4. Enable and start sworkstyle.service"

if systemctl --user is-enabled sworkstyle.service >/dev/null 2>&1; then
    ok "sworkstyle.service is already enabled"
else
    systemctl --user enable sworkstyle.service
    ok "Enabled sworkstyle.service"
fi

if systemctl --user is-active sworkstyle.service >/dev/null 2>&1; then
    ok "sworkstyle.service is already running"
else
    systemctl --user start sworkstyle.service \
        && ok "Started sworkstyle.service" \
        || warn "Could not start sworkstyle.service (will try again on next sway reload)"
fi

# ----------------------------------------------------------------------------
# 5. Final report
# ----------------------------------------------------------------------------
step "5. Status"
if command -v systemctl >/dev/null 2>&1; then
    if systemctl --user status sworkstyle.service >/dev/null 2>&1; then
        systemctl --user --no-pager status sworkstyle.service | sed 's/^/      /'
    else
        warn "sworkstyle.service is not running."
        echo "      Try: systemctl --user start sworkstyle"
    fi
fi

printf "\n${GREEN}✅ Setup complete.${NC}\n"
printf "   Re-run this script any time you update %s.\n" "$SERVICE_SRC"
