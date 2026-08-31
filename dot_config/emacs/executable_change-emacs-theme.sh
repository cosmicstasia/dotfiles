#!/usr/bin/env bash
# Helper script to change Emacs theme from external scripts
# Usage: ./change-emacs-theme.sh <theme_name>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <theme_name>"
    exit 1
fi

THEME_NAME="$1"

# Map external theme names to Emacs theme names
case "$THEME_NAME" in
    "catppuccin") EMACS_THEME="catppuccin" ;;
    "ayu") EMACS_THEME="ayu" ;;
    "dracula") EMACS_THEME="dracula" ;;
    "everforest") EMACS_THEME="everforest" ;;
    "rosepine") EMACS_THEME="rose-pine" ;;
    "oceanic") EMACS_THEME="oceanic" ;;
    "gruvbox"|"modern_gruvbox"|"gruv_chad"|"gruv_boxes") EMACS_THEME="gruvbox" ;;
    "oxocarbon"|"oxo_chad") EMACS_THEME="oxocarbon" ;;
    "dwm") EMACS_THEME="everforest" ;;
    "pywal"|"pywal2"|"pywal_dwm") EMACS_THEME="pywal" ;;
    "arrows") EMACS_THEME="rose-pine" ;;
    "hyprspike") EMACS_THEME="catppuccin" ;;
    "flat") EMACS_THEME="doom-one" ;;
    "nord") EMACS_THEME="nord" ;;
    "tokyo-night"|"tokyonight") EMACS_THEME="tokyo-night" ;;
    *) EMACS_THEME="$THEME_NAME" ;;  # fallback to original name
esac

# Try to change theme in running Emacs instance via emacsclient
if command -v emacsclient >/dev/null 2>&1; then
    # Check if Emacs server is running
    if emacsclient -e '(server-running-p)' >/dev/null 2>&1; then
        echo "Changing Emacs theme to: $EMACS_THEME"
        # Use direct theme loading instead of custom function
        emacsclient -e "(when (featurep 'themes) (themes-load '$EMACS_THEME t))" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Emacs theme changed successfully"
        else
            echo "Failed to change Emacs theme (theme may not exist)"
        fi
    else
        echo "Emacs server not running, theme will be applied on next startup"
        # Write theme to persistence file so it's loaded on next startup  
        EMACS_CONFIG_DIR="${EMACS_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/emacs}"
        echo "$EMACS_THEME" > "$EMACS_CONFIG_DIR/current-theme"
    fi
else
    echo "emacsclient not found, skipping Emacs theme change"
fi
