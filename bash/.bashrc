source ~/.local/share/omarchy/default/bash/rc

PATH="$PATH:/home/vicmaeg/.dotnet/tools"
PATH="$PATH:/home/vicmaeg/.local/tmux-sessionizer"

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add ~/.ssh/github
fi

alias lg=lazygit
alias t=tmux-sessionizer
