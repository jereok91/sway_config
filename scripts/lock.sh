#!/bin/sh

# Evita lanzar un segundo bloqueo (timeout + before-sleep, etc.)
pgrep -x swaylock >/dev/null && exit 0

# Captura cada monitor, la desenfoca y la oscurece para swaylock
blurred_swaylock() {
    dir="${XDG_RUNTIME_DIR:-/tmp}/swaylock"
    mkdir -p "$dir" && rm -f "$dir"/*.png

    for output in $(swaymsg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
        grim -o "$output" -t ppm - |
            magick - -scale 10% -blur 0x2.5 -resize 1000% -fill black -colorize 25% "$dir/$output.png" &
    done
    wait

    set --
    for img in "$dir"/*.png; do
        [ -f "$img" ] && set -- "$@" -i "$(basename "$img" .png):$img"
    done

    swaylock --daemonize --show-failed-attempts --color 1e1e2e --scaling fill "$@"
}

if [ -x "$(command -v gtklock)" ]; then
    gtklock --daemonize --follow-focus --idle-hide --start-hidden
elif [ -x "$(command -v waylock)" ]; then
    waylock -fork-on-lock
elif pacman -Qs swaylock-effects >/dev/null; then
    swaylock --daemonize --show-failed-attempts --screenshots --clock --indicator --effect-blur 7x5 --effect-vignette 0.5:0.5 --fade-in 0.2
elif [ -x "$(command -v grim)" ] && [ -x "$(command -v magick)" ]; then
    blurred_swaylock
elif pacman -Qs swaylock >/dev/null; then
    swaylock --daemonize --show-failed-attempts --color 1e1e2e
fi
