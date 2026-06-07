# Dotfiles

Config personnelle pour : zsh, kitty, tmux, nvim, vim, yazi.

## Installation sur une nouvelle machine

```bash
git clone https://github.com/TON_USER/dotfiles ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

Le script détecte automatiquement **pacman** (Arch) ou **apt** (Debian/Ubuntu).

### Ce que fait install.sh

- Installe les paquets nécessaires
- Crée les symlinks vers `~/.config/` et `~/`
- Installe TPM (gestionnaire de plugins tmux)
- Installe zsh-autosuggestions
- Installe les plugins tmux (resurrect, continuum, which-key, tokyo-night)

## Sauvegarder les modifications

```bash
cd ~/.dotfiles
./save.sh
```

Copie les fichiers modifiés dans le repo, commit et push automatiquement.

## Structure

```
dotfiles/
├── zsh/.zshrc
├── kitty/kitty.conf
├── tmux/.tmux.conf
├── tmux/which-key/config.yaml
├── nvim/               (config LazyVim complète)
├── vim/.vimrc
└── yazi/
    ├── yazi.toml
    └── theme.toml
```

## Raccourcis tmux

| Raccourci | Action |
|---|---|
| `Ctrl+a` | Prefix |
| `Ctrl+a Espace` | Menu which-key |
| `Ctrl+a Tab` | Fenêtre suivante |
| `Ctrl+a Shift+Tab` | Session suivante |
| `Ctrl+a \|` | Split vertical |
| `Ctrl+a -` | Split horizontal |
| `Ctrl+a h/j/k/l` | Navigation entre panneaux |
| `Ctrl+a Ctrl+s` | Sauvegarder session (resurrect) |
| `Ctrl+a Ctrl+r` | Restaurer session (resurrect) |
