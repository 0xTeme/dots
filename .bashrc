#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
eval "$(starship init bash)"
cat ~/.cache/wallust/sequences 2>/dev/null

# fzf history search with Ctrl+R
eval "$(fzf --bash)"

# Auto attach/create tmux session on terminal open
if [[ -z "$TMUX" ]] && [[ -n "$PS1" ]]; then
    exec tmux new-session -A -s main
fi
export PATH="$HOME/.local/bin:$PATH"
alias dots='git --git-dir=/home/temesgen/.dotfiles/ --work-tree=/home/temesgen'
