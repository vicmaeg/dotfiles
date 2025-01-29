#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  ssh-agent -t 1h >"$XDG_RUNTIME_DIR/ssh-agent.env"
fi
if [[ ! -f "$SSH_AUTH_SOCK" ]]; then
  source "$XDG_RUNTIME_DIR/ssh-agent.env" >/dev/null
fi

ssh-add ~/.ssh/github 2>/dev/null
export PATH="$HOME/.tmuxifier/bin:$PATH"
export EDITOR=nvim

alias onvif='tmuxifier s onvif'

eval "$(tmuxifier init -)"
