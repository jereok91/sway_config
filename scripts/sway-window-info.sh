#!/bin/bash
# sway-window-info.sh
# List all open windows with their identifiers, so you can
# figure out the right key for sworkstyle (or any other tool that
# matches windows by app_id / class).
#
# Usage:
#   ~/.config/sway/scripts/sway-window-info.sh              # all windows
#   ~/.config/sway/scripts/sway-window-info.sh compass      # filter by name
#   ~/.config/sway/scripts/sway-window-info.sh --json       # raw JSON output

set -u

JSON_MODE=0
FILTER=""

for arg in "$@"; do
    case "$arg" in
        --json|-j) JSON_MODE=1 ;;
        --help|-h)
            cat <<'EOF'
sway-window-info.sh — list open windows for sworkstyle config

Usage:
  sway-window-info.sh [filter]   show windows matching filter (case-insensitive)
  sway-window-info.sh --json     raw JSON output
  sway-window-info.sh --help     this help

The output columns are:
  APP_ID   Wayland app_id  (preferred for matching in sworkstyle)
  CLASS    X11 class       (use if app_id is empty)
  INSTANCE X11 instance    (rarely needed)
  TITLE    Window title    (used for regex '/match/' rules)
  PID      Process ID

In the sworkstyle config (sworkstyle/config.toml):
  'APP_ID' = 'ICON'         # exact app_id match
  'CLASS'  = 'ICON'         # exact X11 class match (if app_id is empty)
  '/regex/' = 'ICON'        # title regex match
EOF
            exit 0
            ;;
        *) FILTER="$arg" ;;
    esac
done

if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required but not installed." >&2
    echo "  Install with: sudo pacman -S jq" >&2
    exit 1
fi

# Pull every window out of the tree, then filter to those that
# actually have an app_id or an X11 class (so we skip empty
# workspaces, bars, etc.). The recursive descent .. does the
# walking for us.
windows=$(swaymsg -t get_tree | jq -r '
    .. | objects
    | select((.app_id != null and .app_id != "") or
             (.window_properties.class != null and .window_properties.class != ""))
    | {
        app_id:   (.app_id // "-"),
        class:    (.window_properties.class // "-"),
        instance: (.window_properties.instance // "-"),
        title:    (.name // "-"),
        pid:      (.pid // "-")
      }
')

if [ -n "$FILTER" ]; then
    windows=$(echo "$windows" | jq --arg f "$FILTER" -r '
        select(
            (.app_id   | ascii_downcase | contains($f | ascii_downcase)) or
            (.class    | ascii_downcase | contains($f | ascii_downcase)) or
            (.title    | ascii_downcase | contains($f | ascii_downcase))
        )
    ')
fi

if [ "$JSON_MODE" -eq 1 ]; then
    echo "$windows" | jq -s '.'
    exit 0
fi

count=$(echo "$windows" | jq -s 'length')
if [ "$count" -eq 0 ]; then
    if [ -n "$FILTER" ]; then
        echo "No windows matching \"$FILTER\"."
        echo "Try without a filter, or open the app first and re-run."
    else
        echo "No open windows found."
    fi
    exit 0
fi

if command -v tput >/dev/null 2>&1 && [ -t 1 ]; then
    BOLD=$(tput bold); RESET=$(tput sgr0)
    CYAN=$(tput setaf 6); DIM=$(tput setaf 8)
else
    BOLD=""; RESET=""; CYAN=""; DIM=""
fi

echo "$windows" | jq -r '
    [.app_id, .class, .instance, .title, (.pid|tostring)] | @tsv
' | while IFS=$'\t' read -r app_id class instance title pid; do
    printf "${CYAN}%-20s${RESET} ${BOLD}%-22s${RESET} ${DIM}instance=%s${RESET}\n" \
        "$app_id" "$class" "$instance"
    printf "  ${DIM}title:${RESET} %s\n" "$title"
    printf "  ${DIM}pid:${RESET}   %s\n\n" "$pid"
done

echo "${BOLD}${count}${RESET} window(s) listed."

if [ -n "$FILTER" ] && [ "$count" -gt 0 ]; then
    # Re-run the query and grab the first app_id/class for the hint
    first=$(swaymsg -t get_tree | jq -r --arg f "$FILTER" '
        .. | objects
        | select((.app_id != null and .app_id != "") or
                 (.window_properties.class != null and .window_properties.class != ""))
        | select(
            ((.app_id   // "") | ascii_downcase | contains($f | ascii_downcase)) or
            ((.window_properties.class // "") | ascii_downcase | contains($f | ascii_downcase)) or
            ((.name // "") | ascii_downcase | contains($f | ascii_downcase))
          )
        | "\(.app_id // "-")|\(.window_properties.class // "-")"
    ' | head -1)
    first_appid=$(echo "$first" | cut -d'|' -f1)
    first_class=$(echo "$first" | cut -d'|' -f2)

    echo
    echo "Add to sworkstyle/config.toml (pick whichever key is non-empty):"
    if [ "$first_appid" != "-" ] && [ -n "$first_appid" ]; then
        echo "  '$first_appid' = ''    # exact app_id match"
    fi
    if [ "$first_class" != "-" ] && [ -n "$first_class" ]; then
        echo "  '$first_class' = ''    # exact X11 class match"
    fi
    echo "  '/$FILTER/' = ''    # title regex match"
    echo
    echo "Pick an icon from https://www.nerdfonts.com/cheat-sheet"
    echo "and paste the glyph between the quotes."
fi
