#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

# Détection du gestionnaire de paquets
if command -v pacman &>/dev/null; then
    PKG="sudo pacman -S --noconfirm"
    PACKAGES="zsh kitty tmux neovim vim yazi fzf atuin"
elif command -v apt &>/dev/null; then
    PKG="sudo apt install -y"
    PACKAGES="zsh kitty tmux neovim vim fzf"
    echo "Note: atuin et yazi peuvent nécessiter une installation manuelle sur Debian/Ubuntu."
else
    echo "Gestionnaire de paquets non supporté (ni pacman ni apt trouvé)."
    exit 1
fi

echo "Installation des paquets..."
$PKG $PACKAGES

# Symlinks
echo "Création des symlinks..."

ln -sf "$DOTFILES/zsh/.zshrc"              ~/.zshrc
ln -sf "$DOTFILES/vim/.vimrc"              ~/.vimrc
ln -sf "$DOTFILES/tmux/.tmux.conf"         ~/.tmux.conf

mkdir -p ~/.config/kitty ~/.config/yazi ~/.tmux/plugins/tmux-which-key \
         ~/.config/hypr/scripts ~/.config/hypr/shortcuts

ln -sf "$DOTFILES/kitty/kitty.conf"        ~/.config/kitty/kitty.conf
ln -sf "$DOTFILES/yazi/yazi.toml"          ~/.config/yazi/yazi.toml
ln -sf "$DOTFILES/yazi/theme.toml"         ~/.config/yazi/theme.toml
ln -sf "$DOTFILES/tmux/which-key/config.yaml" ~/.tmux/plugins/tmux-which-key/config.yaml

# Hyprland
ln -sf "$DOTFILES/hypr/hyprland.conf"      ~/.config/hypr/hyprland.conf
ln -sf "$DOTFILES/hypr/hyprpaper.conf"     ~/.config/hypr/hyprpaper.conf
ln -sf "$DOTFILES/hypr/hypridle.conf"      ~/.config/hypr/hypridle.conf
ln -sf "$DOTFILES/hypr/hyprlock.conf"      ~/.config/hypr/hyprlock.conf
for script in "$DOTFILES"/hypr/scripts/*.sh; do
    ln -sf "$script" ~/.config/hypr/scripts/"$(basename "$script")"
done
for shortcut in "$DOTFILES"/hypr/shortcuts/*.txt; do
    ln -sf "$shortcut" ~/.config/hypr/shortcuts/"$(basename "$shortcut")"
done

# Nvim
if [ -d ~/.config/nvim ] && [ ! -L ~/.config/nvim ]; then
    echo "Sauvegarde de l'ancien nvim config -> ~/.config/nvim.bak"
    mv ~/.config/nvim ~/.config/nvim.bak
fi
ln -sf "$DOTFILES/nvim" ~/.config/nvim

# TPM (tmux plugin manager)
if [ ! -d ~/.tmux/plugins/tpm ]; then
    echo "Installation de TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# zsh-autosuggestions
if [ ! -d ~/.zsh/zsh-autosuggestions ]; then
    echo "Installation de zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
fi

# tmux which-key build
if command -v python3 &>/dev/null; then
    echo "Build du menu which-key tmux..."
    python3 "$DOTFILES/tmux/which-key/../../.tmux/plugins/tmux-which-key/plugin/build.py" \
        ~/.tmux/plugins/tmux-which-key/config.yaml \
        ~/.tmux/plugins/tmux-which-key/plugin/init.tmux 2>/dev/null || true
fi

# Plugins tmux
if command -v tmux &>/dev/null; then
    echo "Installation des plugins tmux..."
    tmux new-session -d -s install 2>/dev/null || true
    ~/.tmux/plugins/tpm/bin/install_plugins
fi

echo ""
echo "Installation terminée!"
echo "Lance 'zsh' ou ouvre un nouveau terminal pour appliquer les changements."
