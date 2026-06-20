#!/bin/bash

selected=$(hyprctl clients -j | python3 -c "
import json, sys
clients = json.load(sys.stdin)

workspaces = {}
for c in clients:
    wid = c['workspace']['id']
    if wid <= 0:
        continue
    title = c.get('title') or c.get('class') or '?'
    if len(title) > 40:
        title = title[:40] + '…'
    workspaces.setdefault(wid, []).append(title)

for wid in sorted(workspaces):
    titles = ', '.join(workspaces[wid])
    print(f'Bureau {wid}  —  {titles}')
" | fuzzel --dmenu --prompt "Bureau > " --width 80)

[[ -z "$selected" ]] && exit 0

workspace=$(echo "$selected" | grep -oP '(?<=Bureau )\d+')
[[ -n "$workspace" ]] && hyprctl dispatch workspace "$workspace"
