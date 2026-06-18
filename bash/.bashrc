PATH="$PATH:$HOME/.dotnet/tools"
PATH="$PATH:$HOME/.local/tmux-sessionizer"
PATH="$PATH:$HOME/.opencode/bin"
PATH="$PATH:$HOME/.local/bin"

export EDITOR='emacsclient -t'
export VISUAL='emacsclient -t'

alias lg=lazygit
alias t=tmux-sessionizer
alias ls=eza
alias cd=z
alias v=nvim

# Emacs
alias e='emacsclient -t'
alias ec='nohup emacsclient -c -n < /dev/null > /dev/null 2>&1 &'
alias emacsd='systemctl --user status emacs'
alias emacsd-restart='systemctl --user restart emacs'
alias emacsd-stop='systemctl --user stop emacs'
alias emacs-install='emacs -nw'

eval "$(starship init bash)"
eval "$(zoxide init bash)"
