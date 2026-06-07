#export PS1='%(!.%F{red}.%F{green})%n@%m%f:%~ %# [%?] '
eval "$(starship init zsh)" #curl -sS https://starship.rs/install.sh | sh

alias ls='ls --color=auto'
eval "$(dircolors -b)"

path+=('/home/fab/.local/bin' '/home/fab/bin' '/home/fab/bin/intelFPGA_lite/17.0/quartus/bin')

export QUARTUS_ROOTDIR=/home/fab/bin/intelFPGA_lite/17.0/quartus

#historique avec sqlite
eval "$(atuin init zsh)"
#autoload -U colors; colors
autoload -U compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then compinit; else compinit -C; fi
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

source <(fzf --zsh)
source /usr/share/zsh/plugins/fzf-tab-git/fzf-tab.plugin.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_STRATEGY=completion

HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY
#setopt EXTENDED_HISTORY         # include timestamp
#setopt HIST_BEEP                # beep if attempting to access a history entry which isn’t there
setopt HIST_EXPIRE_DUPS_FIRST   # trim dupes first if history is full
setopt HIST_FIND_NO_DUPS        # do not display previously found command
#setopt HIST_IGNORE_DUPS         # do not save duplicate of prior command
setopt HIST_IGNORE_SPACE        # do not save if line starts with space
setopt HIST_NO_STORE            # do not save history commands
setopt HIST_REDUCE_BLANKS       # strip superfluous blanks
#setopt INC_APPEND_HISTORY       # don’t wait for shell to exit to save history lines
# setopt HIST_ALLOW_CLOBBER       # related to shell clobber setting
setopt HIST_IGNORE_ALL_DUPS     # remove old event if new one is a duplicate
# setopt HIST_LEX_WORDS           # related to how white space is saved
# setopt HIST_NO_FUNCTIONS        # do not save function commands
#setopt HIST_SAVE_NO_DUPS        # omit older duplicates of newer commands
setopt HIST_SUBST_PATTERN       # use pattern matching for substitutions
# setopt HIST_VERIFY              # expand command line without executing it

# Make zsh autocomplete with up arrow
stty -ixon

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end


# Tmux session principale
alias mux='tmux new-session -A -s mux'

#Alias
alias ll='ls -la'
alias i='sudo pacman -Sy'
alias up='sudo pacman -Syu'
alias top='btop'
alias vim='nvim'
alias vi="/usr/bin/vim"
alias q='exit'
alias r='yazi'
alias copy='kitty +kitten clipboard'
alias paste='kitty +kitten clipboard --get-clipboard'


alias ls='eza --icons'
alias ll='eza -la --icons --git'
alias lt='eza --tree --icons --level=2'
alias icat='kitten icat'


export QSYS_ROOTDIR="/home/fab/.cache/yay/quartus-free/pkg/quartus-free-quartus/opt/intelFPGA/25.1/quartus/sopc_builder/bin"
