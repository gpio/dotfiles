#!/bin/bash

SHORTCUTS_DIR="$HOME/.config/hypr/shortcuts"

# Détecte la fenêtre active
active=$(hyprctl activewindow -j 2>/dev/null)
win_class=$(echo "$active" | python3 -c "import json,sys; print(json.load(sys.stdin).get('class',''))" 2>/dev/null | tr '[:upper:]' '[:lower:]')
win_pid=$(echo "$active" | python3 -c "import json,sys; print(json.load(sys.stdin).get('pid',''))" 2>/dev/null)

# Cherche une app connue dans l'arbre des processus (priorité aux apps connues)
known_apps="nvim vim claude code aerc yazi"
find_foreground() {
    local pid=$1
    local name
    name=$(cat /proc/$pid/cmdline 2>/dev/null | tr '\0' ' ' | awk '{print $1}' | xargs basename 2>/dev/null)
    # Si c'est une app connue, retourner immédiatement
    if echo "$known_apps" | grep -qw "$name"; then
        echo "$name"
        return
    fi
    # Sinon explorer les enfants
    local children
    children=$(ps --ppid "$pid" -o pid= 2>/dev/null | tr -d ' ')
    if [ -z "$children" ]; then
        echo "$name"
    else
        for child in $children; do
            find_foreground "$child"
        done
    fi
}

# Détermine l'app au premier plan
terminals=("kitty" "alacritty" "foot" "wezterm")
app="$win_class"

# Détecte si tmux tourne dans cette fenêtre spécifiquement
in_tmux=false
if [[ " ${terminals[@]} " =~ " ${win_class} " ]]; then
    pgrep -P "$win_pid" -x tmux &>/dev/null && in_tmux=true
    if ! $in_tmux; then
        find_foreground "$win_pid" 2>/dev/null | grep -q "^tmux$" && in_tmux=true
    fi
fi

if [[ " ${terminals[@]} " =~ " ${win_class} " ]]; then
    if $in_tmux; then
        fg_proc=$(tmux display-message -p '#{pane_current_command}' 2>/dev/null)
    else
        # Priorise les apps connues parmi tous les processus trouvés
        all_procs=$(find_foreground "$win_pid" 2>/dev/null)
fg_proc=""
        for known in nvim vim claude code aerc yazi; do
            if echo "$all_procs" | grep -qx "$known"; then
                fg_proc="$known"
                break
            fi
        done
        [ -z "$fg_proc" ] && fg_proc=$(echo "$all_procs" | grep -v "^kitten$" | head -1)
    fi

    case "$fg_proc" in
        nvim)          app="nvim" ;;
        vim)           app="vim" ;;
        claude)        app="claude" ;;
        code|code-oss) app="code" ;;
        aerc)          app="aerc" ;;
        yazi)          app="yazi" ;;
        zsh|bash|fish) app="zsh" ;;
    esac
fi

# Charge un fichier avec préfixe [label]
load_shortcuts() {
    local label="$1"
    local file="$SHORTCUTS_DIR/$2.txt"
    [ -f "$file" ] || return
    grep -v "^$\|^#" "$file" | while IFS= read -r line; do
        printf "%-10s %s\n" "[$label]" "$line"
    done
}

# Convertit un raccourci en commande(s) wtype exécutables
shortcut_to_cmd() {
    python3 << 'PYEOF'
import sys, os, re

shortcut = os.environ.get('SHORTCUT', '')

KEY_MAP = {
    # Flèches
    '←': 'Left', '→': 'Right', '↑': 'Up', '↓': 'Down',
    'left': 'Left', 'right': 'Right', 'up': 'Up', 'down': 'Down',
    # Entrée / Echap
    'entrée': 'Return', 'enter': 'Return', 'return': 'Return',
    'escape': 'Escape', 'échap': 'Escape', 'esc': 'Escape',
    # Navigation
    'tab': 'Tab',
    'space': 'space', 'espace': 'space',
    'backspace': 'BackSpace',
    'delete': 'Delete', 'suppr': 'Delete',
    'insert': 'Insert', 'inser': 'Insert',
    'home': 'Home', 'début': 'Home',
    'end': 'End', 'fin': 'End',
    'pageup': 'Prior', 'page_up': 'Prior', 'pgprec': 'Prior',
    'pagedown': 'Next', 'page_down': 'Next', 'pgsuiv': 'Next',
    # Fonction
    **{f'f{i}': f'F{i}' for i in range(1, 13)},
    # Ponctuation
    '+': 'plus', '-': 'minus', '=': 'equal', '.': 'period',
    ',': 'comma', ';': 'semicolon', ':': 'colon',
    '/': 'slash', '\\': 'backslash',
    '[': 'bracketleft', ']': 'bracketright',
    '{': 'braceleft', '}': 'braceright',
    '(': 'parenleft', ')': 'parenright',
    "'": 'apostrophe', '"': 'quotedbl', '`': 'grave',
    '!': 'exclam', '@': 'at', '#': 'numbersign',
    '$': 'dollar', '%': 'percent', '^': 'asciicircum',
    '&': 'ampersand', '*': 'asterisk', '_': 'underscore',
}

MOD_MAP = {
    'ctrl': 'ctrl', 'control': 'ctrl',
    'shift': 'shift',
    'alt': 'alt',
    'super': 'super', 'win': 'super', 'meta': 'super',
}

SKIP_KEYS = {'xf86', '²', 'twosuperior', 'molette', 'clic', 'souris'}

def resolve_key(k):
    kl = k.lower()
    if kl in KEY_MAP:
        return KEY_MAP[kl]
    if len(k) == 1:
        return k.lower()
    # Touches F1-F12 directement
    if re.match(r'^[Ff]\d+$', k):
        return k.upper()
    return None

def build_wtype(mods, key):
    args = []
    for m in mods:
        args += ['-M', m]
    args += ['-k', key]
    for m in reversed(mods):
        args += ['-m', m]
    return 'wtype ' + ' '.join(args)

# Prend le premier combo si alternatives (G / R / S)
shortcut = shortcut.split('/')[0].strip()

# Skip touches spéciales non typables
if any(s in shortcut.lower() for s in SKIP_KEYS):
    sys.exit(3)

# Split sur +
parts = [p.strip() for p in re.split(r'\s*\+\s*', shortcut)]

# Séparer mods et keys
mods = []
keys = []
for p in parts:
    if p.lower() in MOD_MAP:
        mods.append(MOD_MAP[p.lower()])
    else:
        keys.append(p)

if not keys:
    sys.exit(1)

# Super → hyprctl dispatch
if 'super' in mods:
    import json, subprocess
    try:
        binds = json.loads(subprocess.check_output(['hyprctl', 'binds', '-j']))
    except Exception:
        sys.exit(2)

    MODMASK = {'shift': 1, 'ctrl': 4, 'alt': 8, 'super': 64}
    HYPR_KEY_ALIASES = {
        'entrée': 'return', 'enter': 'return',
        'échap': 'escape', 'esc': 'escape',
        'suppr': 'delete',
        'inser': 'insert',
        'début': 'home',
        'fin': 'end',
        '←': 'left', '→': 'right', '↑': 'up', '↓': 'down',
        'tab': 'tab',
    }
    target_mask = sum(MODMASK.get(m, 0) for m in mods)
    raw_key = keys[-1].lower() if keys else ''
    target_key = HYPR_KEY_ALIASES.get(raw_key, raw_key)

    for b in binds:
        if b.get('submap'):
            continue
        if b['modmask'] == target_mask and b['key'].lower() == target_key:
            dispatcher = b['dispatcher']
            arg = b['arg']
            cmd = f'hyprctl dispatch {dispatcher} {arg}'.strip()
            print(cmd)
            sys.exit(0)
    sys.exit(2)

# Séquence tmux : Ctrl+A puis touche (ex: Ctrl + A + c)
if 'ctrl' in mods and len(keys) >= 2:
    # Premier groupe = Ctrl+premierKey (le préfixe)
    prefix_key = resolve_key(keys[0])
    final_key  = resolve_key(keys[1])
    if not prefix_key or not final_key:
        sys.exit(1)
    cmd1 = build_wtype(['ctrl'], prefix_key)
    # La touche finale peut avoir des mods restants (ex: Ctrl+A+Shift+X)
    extra_mods = [m for m in mods if m != 'ctrl']
    cmd2 = build_wtype(extra_mods, final_key)
    print(f'{cmd1}; sleep 0.08; {cmd2}')
    sys.exit(0)

# Raccourci simple
key = resolve_key(keys[-1])
if not key:
    sys.exit(1)

print(build_wtype(mods, key))
PYEOF
}

# Construit la pile de raccourcis selon le contexte
build_stack() {
    case "$app" in
        nvim)    load_shortcuts "nvim"   nvim ;;
        vim)     load_shortcuts "vim"    vim ;;
        claude)  load_shortcuts "claude" claude ;;
        code|code-oss) load_shortcuts "code" code ;;
        zsh)     load_shortcuts "zsh"    zsh ;;
        aerc)    load_shortcuts "aerc"   aerc ;;
        yazi)    load_shortcuts "yazi"   yazi ;;
        firefox) load_shortcuts "fox"    firefox ;;
        blender) load_shortcuts "blend"  blender ;;
        google-chrome|chromium) load_shortcuts "chrome" google-chrome ;;
    esac

    if [[ " ${terminals[@]} " =~ " ${win_class} " ]]; then
        $in_tmux && load_shortcuts "tmux" tmux
        load_shortcuts "zsh"   zsh
        load_shortcuts "kitty" kitty
    fi

    load_shortcuts "hypr" hyprland
}

# Affiche et exécute
selected=$(build_stack | fuzzel --dmenu --prompt "[$app] > " --width 85)

[[ -z "$selected" ]] && exit 0

# Extrait le raccourci : retire [label] puis coupe sur 2+ espaces
shortcut=$(echo "$selected" | sed 's/^\[[^]]*\] *//' | python3 -c "
import sys
line = sys.stdin.read().strip()
import re
parts = re.split(r'\s{2,}', line)
print(parts[0].strip() if parts else '')
")

cmd=$(SHORTCUT="$shortcut" shortcut_to_cmd)
exit_code=$?

if [ $exit_code -eq 0 ] && [ -n "$cmd" ]; then
    sleep 0.15
    eval "$cmd"
fi
