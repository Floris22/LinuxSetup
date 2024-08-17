# Prompt init
#autoload -Uz promptinit
#promptinit
#prompt adam1

# Autocompletions
source ~/.config/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh


# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# History
HISTSIZE=5000
SAVEHIST=5000
HISTFILE=~/.config/.zsh/.zsh_history
HISTDUP=erase

setopt histignorealldups sharehistory
setopt appendhistory

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Functions
# function that does ls after cd
cd() {
    builtin cd "$@" && ls -lh --color
}

# create dir and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# extract func
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# find file using pattern
ff() {
    find . -type f -iname '*'"$*"'*' -ls
}

cursor() {
    ~/AppImages/cursor/*.AppImage "$@" &
    disown
}

# Aliases
alias ls='ls --color'
alias ytd=~/Projects/YTDownload/yt.sh

# Exports
export PATH="$PATH:/home/flo/.local/bin"
export PATH="/usr/bin/flutter/bin:$PATH"
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

eval "$(starship init zsh)"
