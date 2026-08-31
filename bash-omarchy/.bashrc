# If not running interactively, don't do anything (leave this at the top of this file)
[[ $- != *i* ]] && return

source ~/.local/share/omarchy/default/bash/rc

export DOTNET_ROOT="$HOME/.dotnet"
PATH="$HOME/.dotnet:$PATH"
PATH="$PATH:$HOME/.dotnet/tools"
PATH="$PATH:$HOME/.opencode/bin"
PATH="$PATH:$HOME/.local/bin"

if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval `ssh-agent -s`
  ssh-add ~/.ssh/github
fi

alias lg=lazygit
alias hw=herdr-workspacer
