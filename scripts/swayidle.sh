#!/usr/bin/env bash
# Lanza swayidle con los tiempos definidos en ~/.config/sway/idle.conf

CONF="$HOME/.config/sway/idle.conf"
LOCK="$HOME/.config/sway/scripts/lock.sh"
KBD="$HOME/.config/sway/scripts/keyboard-backlight-switch.sh"

DIM_MINUTES=4
LOCK_MINUTES=5
SCREEN_OFF_MINUTES=10
SUSPEND_MINUTES=30
[ -f "$CONF" ] && . "$CONF"

args=(-w)

if [ "$DIM_MINUTES" -gt 0 ] && command -v brightnessctl >/dev/null; then
    args+=(timeout $((DIM_MINUTES * 60)) 'brightnessctl -s && brightnessctl set 10'
           resume 'brightnessctl -r')
fi

if [ "$LOCK_MINUTES" -gt 0 ]; then
    args+=(timeout $((LOCK_MINUTES * 60)) "$LOCK")
fi

if [ "$SCREEN_OFF_MINUTES" -gt 0 ]; then
    args+=(timeout $((SCREEN_OFF_MINUTES * 60)) "swaymsg 'output * power off'; $KBD off"
           resume "swaymsg 'output * power on'; $KBD on")
fi

if [ "$SUSPEND_MINUTES" -gt 0 ]; then
    args+=(timeout $((SUSPEND_MINUTES * 60)) 'systemctl suspend')
fi

args+=(before-sleep "$LOCK"
       after-resume "swaymsg 'output * power on'"
       lock "$LOCK")

exec /usr/bin/swayidle "${args[@]}"
