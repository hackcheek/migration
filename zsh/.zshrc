# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export _JAVA_AWT_WM_NONREPARENTING=1

# Prompt
PROMPT="%F{red}┌[%f%F{cyan}%m%f%F{red}]─[%f%F{yellow}%D{%H:%M-%d/%m}%f%F{red}]─[%f%F{magenta}%d%f%F{red}]%f"$'\n'"%F{red}└╼%f%F{green}$USER%f%F{yellow}$%f"
# Export PATH$
export PATH=~/.local/bin:/snap/bin:/usr/sandbox/:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/usr/share/games:/usr/local/sbin:/usr/sbin:/sbin:$PATH

# alias
alias ls='ls -lh --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
#####################################################
# Auto completion / suggestion
# Mixing zsh-autocomplete and zsh-autosuggestions
# Requires: zsh-autocomplete (custom packaging by Parrot Team)
# Jobs: suggest files / foldername / histsory bellow the prompt
# Requires: zsh-autosuggestions (packaging by Debian Team)
# Jobs: Fish-like suggestion for command history
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
source /home/nn/.p10k.zsh
# Select all suggestion instead of top on result only
zstyle ':autocomplete:tab:*' insert-unambiguous yes
zstyle ':autocomplete:tab:*' widget-style menu-select
zstyle ':autocomplete:*' min-input 2
bindkey $key[Up] up-line-or-history
bindkey $key[Down] down-line-or-history


##################################################
# Fish like syntax highlighting
# Requires "zsh-syntax-highlighting" from apt

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Save type history for completion and easier life
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt histignorealldups sharehistory
#setopt appendhistory

# Useful alias for benchmarking programs
# require install package "time" sudo apt install time
# alias time="/usr/bin/time -f '\t%E real,\t%U user,\t%S sys,\t%K amem,\t%M mmem'"
# Display last command interminal
echo -en "\e]2;Parrot Terminal\a"
preexec () { print -Pn "\e]0;$1 - Parrot Terminal\a" }

source /home/nn/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f /home/nn/.p10k.zsh ]] || source /home/nn/.p10k.zsh

# Alias
alias cat='/bin/batcat'
alias catn='/bin/cat'
alias catl='/bin/batcat --paging=never'
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias n='sudo nvim'
alias fetch='clear; screenfetch -c 161'
alias extractor='/home/nn/machines/exploits/web/GitTools/Extractor/extractor.sh'
alias finder='python3 /home/nn/machines/exploits/web/GitTools/Finder/gitfinder.py'
alias dumper='/home/nn/machines/exploits/web/GitTools/Dumper/gitdumper.sh'

[ -f /home/nn/.fzf.zsh ] && source /home/nn/.fzf.zsh

source /usr/share/zshPlugins/sudo.plugin.zsh

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ $KEYMAP == main ]] || [[ $KEYMAP == viins ]] || [[ $KEYMAP = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# HTB template
function htbtemplate(){
    mkdir $1
    cd $1; mkdir enumeration content exploits; touch report.txt
}

# IP target htb
function settarget(){
	ip_address=$1
	machine_name=$2
	echo "$ip_address $machine_name" > /home/nn/.config/bin/target
}

function extractports(){
    /bin/cat $1 | sed -e 's/tcp/\r\n/g' | awk '{print $2}' | cut -d '/' -f 1 | grep -vE 'Ignored|Nmap'| tail -n +5 | xargs | tr ' ' ',' | tr -d '\n' | xclip -selection clipboard
    echo "\n .oO Puertos copiados Oo."
}
