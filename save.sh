#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Sauvegarde des dotfiles..."

cp ~/.zshrc                                              "$DOTFILES/zsh/.zshrc"
cp ~/.config/kitty/kitty.conf                           "$DOTFILES/kitty/kitty.conf"
cp ~/.tmux.conf                                          "$DOTFILES/tmux/.tmux.conf"
cp ~/.tmux/plugins/tmux-which-key/config.yaml           "$DOTFILES/tmux/which-key/config.yaml"
cp ~/.vimrc                                              "$DOTFILES/vim/.vimrc"
cp ~/.config/yazi/yazi.toml                             "$DOTFILES/yazi/yazi.toml"
cp ~/.config/yazi/theme.toml                            "$DOTFILES/yazi/theme.toml"
rsync -a --delete ~/.config/nvim/                       "$DOTFILES/nvim/"

cd "$DOTFILES"
git add -A
git diff --cached --quiet && echo "Rien à sauvegarder." && exit 0

git commit -m "update: $(date '+%Y-%m-%d %H:%M')"
git push
echo "Dotfiles sauvegardés et poussés sur GitHub."
