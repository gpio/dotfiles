#!/bin/bash

WALLPAPER_DIR="$HOME/Images/Wallpapers"
MONITOR="eDP-1"

declare -A workspace_wallpaper
mapfile -t all_wallpapers < <(find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) | sort)

set_wallpaper() {
    local workspace="$1"
    if [[ -z "${workspace_wallpaper[$workspace]}" ]]; then
        local idx=$((RANDOM % ${#all_wallpapers[@]}))
        local wp="${all_wallpapers[$idx]}"
        workspace_wallpaper[$workspace]="$wp"
    fi
    local wp="${workspace_wallpaper[$workspace]}"
    [[ -f "$wp" ]] || return
    hyprctl hyprpaper wallpaper "$MONITOR,$wp"
}

set_wallpaper 1

while read -r line; do
    if [[ "$line" == workspace* ]]; then
        workspace=$(echo "$line" | grep -oP '(?<=workspace>>)\d+')
        [[ -n "$workspace" ]] && set_wallpaper "$workspace"
    fi
done < <(socat - "UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock")
