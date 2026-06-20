#!/bin/bash
# Grille de workspaces 3 colonnes :
# 1  2  3
# 4  5  6
# 7  8  9
# 10

COLS=3
MAX=10

current=$(hyprctl activeworkspace -j | jq '.id')
direction=$1

case "$direction" in
    right)
        col=$(( (current - 1) % COLS ))
        [[ $col -lt $((COLS - 1)) ]] && target=$((current + 1))
        ;;
    left)
        col=$(( (current - 1) % COLS ))
        [[ $col -gt 0 ]] && target=$((current - 1))
        ;;
    down)
        target=$((current + COLS))
        [[ $target -gt $MAX ]] && target=$current
        ;;
    up)
        target=$((current - COLS))
        [[ $target -lt 1 ]] && target=$current
        ;;
esac

[[ -n "$target" ]] && hyprctl dispatch workspace "$target"
