#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export PATH="$HOME/.local/bin:$PATH"
alias dots='git --git-dir=/home/temesgen/.dotfiles/ --work-tree=/home/temesgen'
alias ls='ls --color=auto'
alias grep='grep --color=auto'

cat ~/.cache/wallust/sequences 2>/dev/null
eval "$(starship init bash)"
eval "$(fzf --bash)"

if [[ -z "$TMUX" ]] && [[ -n "$PS1" ]]; then
    exec tmux new-session -A -s main
fi
