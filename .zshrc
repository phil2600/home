# "-*- sh -*-"
##
## .zshrc for zsh in /home/phil
##
## Based on tsuna configuration file
## Made by Philippe FAURE
## Login   <faure_p@epita.fr>
##
## Started on  Sat Mar 11 02:42:09 2006 Philippe FAURE
## Last update Mon Dec 06 23:22:54 2010 Philippe FAURE
##

#######
# ENV #
#######

export NAME='Phil'
export FULLNAME='Philippe FAURE'
export EMAIL='phil@epita.fr'
export REPLYTO='phil@epita.fr'
export NNTPSERVER="news.epita.fr"

export EDITOR='emacs'
export PATH="$HOME/opt/android/tools:$HOME/bin:$PATH"

export PHILCONF_DIR="$HOME/.phil_conf"

export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.rar=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'
export LS_OPTIONS='-F'

export MALLOC_OPTIONS='J'

if [ x"$HOST" = x"gate-ssh" ] && (setopt | grep -q 'interactive'); then
  PROMPT="%{[1;31m%}%n%{[1;38m%}@%{[1;31m%}%m%{[m%} %B%40<..<%~%<<%b %(!.#.$) "
  RPROMPT="%(?..%{[1;31m%}%?%{[m%} )%{[1;31m%}%D{%H:%M:%S}%{[m%}"
  echo ">>>> You are on gate-ssh, forwarding you to freebsd"
  ssh freebsd
  echo ">>>> Back on gate-ssh... exiting"
  exit
fi

[ ! -z "$DISPLAY" ] && xset b off && xset r rate 250 75
[ -r ~/code/config.site ] && export CONFIG_SITE="$HOME/code/config.site"


###########
# ALIASES # (basics)
###########

# use colors when browsing man pages (if not using pinfo or PAGER=most)
[ -d ~/.terminfo/ ] && which most > /dev/null 2>&1 && alias man='TERMINFO=~/.terminfo/ LESS=C TERM=mostlike PAGER=less man'

lsbin='ls'
alias svn='~/bin/svn-wrapper.sh'
case `uname -s` in
  *BSD | Darwin)
    gls --version >/dev/null 2>/dev/null && lsbin='gls' && \
      export LS_OPTIONS="$LS_OPTIONS -b -h --color"
    ;;
  Linux | CYGWIN*)
    export LS_OPTIONS="$LS_OPTIONS -b -h --color"
    ;;
esac

if [ "`uname -s`" != "SunOS" ]; then
  if gmv --version > /dev/null 2>&1; then
    alias mv="gmv -v"
  else
    alias mv="mv -v"
  fi
  if gcp --version > /dev/null 2>&1; then
    alias cp="gcp -v"
  else
    alias cp="cp -v"
  fi
fi;
if grm --version > /dev/null 2>&1; then
  alias rrm="grm -v"
else
  alias rrm="/bin/rm -v"
fi
for app in svn prcs cvs; do
  type vcs-$app | grep -qF 'is /' && alias $app="vcs-$app"
done

alias unrar='nice -n 19 unrar'


###############
# ZSH OPTIONS #
###############

setopt correct                  # spelling correction
setopt complete_in_word         # not just at the end
setopt alwaystoend              # when completing within a word, move cursor to the end of the word
setopt auto_cd                  # change to dirs without cd
setopt hist_ignore_all_dups     # If a new command added to the history list duplicates an older one, the older is removed from the list
setopt hist_find_no_dups        # do not display duplicates when searching for history entries
setopt auto_list                # Automatically list choices on an ambiguous completion.
setopt auto_param_keys          # Automatically remove undesirable characters added after auto completions when necessary
setopt auto_param_slash         # Add slashes at the end of auto completed dir names
#setopt no_bg_nice               # ??
setopt complete_aliases
setopt equals                   # If a word begins with an unquoted `=', the remainder of the word is taken as the name of a command.
                                # If a command exists by that name, the word is replaced by the full pathname of the command.
setopt extended_glob            # activates: ^x         Matches anything except the pattern x.
                                #            x~y        Match anything that matches the pattern x but does not match y.
                                #            x#         Matches zero or more occurrences of the pattern x.
                                #            x##        Matches one or more occurrences of the pattern x.
setopt hash_cmds                # Note the location of each command the first time it is executed in order to avoid search during subsequent invocations
setopt hash_dirs                # Whenever a command name is hashed, hash the directory containing it
setopt mail_warning             # Print a warning message if a mail file has been accessed since the shell last checked.
setopt append_history           # append history list to the history file (important for multiple parallel zsh sessions!)

# no beep
unsetopt beep
unsetopt hist_beep
unsetopt list_beep

HISTFILE=~/.history_zsh
SAVEHIST=1000
HISTSIZE=1000

LOGCHECK=60
WATCHFMT="%n has %a %l from %M"
WATCH=all


##########
# COLORS #
##########

std="%{[m%}"
red="%{[0;31m%}"
green="%{[0;32m%}"
yellow="%{[0;33m%}"
blue="%{[0;34m%}"
purple="%{[0;35m%}"
cyan="%{[0;36m%}"
grey="%{[0;37m%}"
white="%{[0;38m%}"
lred="%{[1;31m%}"
lgreen="%{[1;32m%}"
lyellow="%{[1;33m%}"
lblue="%{[1;34m%}"
lpurple="%{[1;35m%}"
lcyan="%{[1;36m%}"
lgrey="%{[1;37m%}"
lwhite="%{[1;38m%}"


###########
# PROMPTS #
###########

PS2='`%_> '       # secondary prompt, printed when the shell needs more information to complete a command.
PS3='?# '         # selection prompt used within a select loop.
PS4='+%N:%i:%_> ' # the execution trace prompt (setopt xtrace). default: '+%N:%i>'
if [ $UID != 0 ]; then
  local prompt_user="${lgreen}%n${std}"
else
  local prompt_user="${lred}%n${std}"
fi
local prompt_host="${lyellow}%m${std}"
local prompt_cwd="%B%40<..<%~%<<%b"
local prompt_time="${lblue}%D{%H:%M:%S}${std}"
local prompt_rv="%(?..${lred}%?${std} )"
PROMPT="${prompt_user}${lwhite}@${std}${prompt_host} ${prompt_cwd} %(!.#.$) "
RPROMPT="${prompt_rv}${prompt_time}"


##############
# TERM STUFF #
##############

#/bin/stty erase "^H" intr "^C" susp "^Z" dsusp "^Y" stop "^S" start "^Q" kill "^U"  >& /dev/null


################
# KEY BINDINGS #
################

bindkey -e
bindkey '\e[1~'	beginning-of-line	# home
bindkey '\e[4~'	end-of-line		# end
bindkey "^[[A"	up-line-or-search	# cursor up
bindkey "\eOP"	run-help		# run-help when F1 is pressed

type run-help | grep -q 'is an alias' && unalias run-help

# Correspondance touches-fonction$
bindkey '^A'    beginning-of-line       # Home$
bindkey '^E'    end-of-line             # End$
bindkey '^D'    delete-char             # Del$
bindkey '^[[3~' delete-char             # Del$
bindkey '^[[2~' overwrite-mode          # Insert$
bindkey '^[[5~' history-search-backward # PgUp$
bindkey '^[[6~' history-search-forward  # PgDn$
bindkey '^[[7~' beginning-of-line
bindkey '^[[8~' end-of-line
bindkey '^[,'   insert-last-word	# I always hit m-, instead if m-. for some reason
bindkey '^I'	complete-word		# complete on tab, leave expansion to _expand

# Useful piping shortcuts
bindkey -s '^|l' "|less\n"				# c-| l  pipe to less
bindkey -s '^|g' '|grep ""^[OD'				# c-| g  pipe to grep
bindkey -s '^|a' "|awk '{print $}'^[OD^[OD"		# c-| a  pipe to awk
bindkey -s '^|s' '|sed -e "s///g"^[OD^[OD^[OD^[OD'	# c-| s  pipe to sed

# Input controls
bindkey '^[[1;3D' backward-word		# alt + LEFT
bindkey '^[[1;3C' forward-word		# alt + RIGHT
bindkey '_^?'	  backward-delete-word	# alt + BACKSPACE  delete word backward
bindkey '^[[3;3~' delete-word		# alt + DELETE  delete word forward
bindkey '^['      self-insert		# alt + ENTER  allow multiline input



#######################
# COMPLETION TWEAKING #
#######################

# The following lines were added by compinstall
_compdir=~/usr/share/zsh/functions
[[ -z $fpath[(r)$_compdir] ]] && fpath=($fpath $_compdir)

autoload -U compinit; compinit

setopt shortloops

limit coredumpsize 0

autoload zmv
autoload -U zed

setopt equals

setopt noclobber


# This one is a bit ugly. You may want to use only `*:correct'
# if you also have the `correctword_*' or `approximate_*' keys.
# End of lines added by compinstall

zmodload zsh/complist

zstyle ':completion:*:processes' command 'ps -au$USER'     # on processes completion complete all user processes
zstyle ':completion:*:descriptions' format \
       $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'           # format on completion
zstyle ':completion:*' verbose yes                         # provide verbose completion information
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format \
       $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'
zstyle ':completion:*:matches' group 'yes'                 # separate matches into groups
zstyle ':completion:*:options' description 'yes'           # describe options in full
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:*:zcompile:*' ignored-patterns '(*~|*.zwc)'

# activate color-completion(!)
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

## correction

# Ignore completion functions for commands you don't have:
#  zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

zstyle ':completion:*'             completer _complete _correct _approximate
zstyle ':completion:*:correct:*'   insert-unambiguous true
#  zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
#  zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e)%}'
zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:correct:*'   original true
zstyle ':completion:correct:'      prompt 'correct to:'

# allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:' max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'
#  zstyle ':completion:*:correct:*'   max-errors 2 numeric

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# insert all expansions for expand completer
zstyle ':completion:*:expand:*' tag-order all-expansions

# ignore duplicate entries
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# filename suffixes to ignore during completion (except after rm command)
#  zstyle ':completion:*:*:(^rm):*:*files' ignored-patterns  '*?.(o|c~|old|pro|zwc)' '*~'

# Don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# If there are more than N options, allow selecting from a menu with
# arrows (case insensitive completion!).
#  zstyle ':completion:*-case' menu select=5
zstyle ':completion:*' menu select=2

# zstyle ':completion:*:*:kill:*' verbose no

# caching
[ -d $ZSHDIR/cache ] && zstyle ':completion:*' use-cache yes && \
                        zstyle ':completion::complete:*' cache-path $ZSHDIR/cache/

known_hosts=''
[ -f "$HOME/.ssh/known_hosts" ] && \
known_hosts="`awk '$1!~/\|/{print $1}' $HOME/.ssh/known_hosts | cut -f1 -d, | xargs`"

zstyle ':completion:*:hosts' hosts ${=lrde_hosts} ${=known_hosts}

# simple completion for fbset (switch resolution on console)
_fbmodes() { compadd 640x480-60 640x480-72 640x480-75 640x480-90 640x480-100 768x576-75 800x600-48-lace 800x600-56 800x600-60 800x600-70 800x600-72 800x600-75 800x600-90 800x600-100 1024x768-43-lace 1024x768-60 1024x768-70 1024x768-72 1024x768-75 1024x768-90 1024x768-100 1152x864-43-lace 1152x864-47-lace 1152x864-60 1152x864-70 1152x864-75 1152x864-80 1280x960-75-8 1280x960-75 1280x960-75-32 1280x1024-43-lace 1280x1024-47-lace 1280x1024-60 1280x1024-70 1280x1024-74 1280x1024-75 1600x1200-60 1600x1200-66 1600x1200-76 }
compdef _fbmodes fbset

# use generic completion system for programs not yet defined:
compdef _gnu_generic tail head feh cp mv gpg df stow uname ipacsum fetchipac

# Debian specific stuff
#zstyle ':completion:*:*:lintian:*' file-patterns '*.deb'
zstyle ':completion:*:*:linda:*'   file-patterns '*.deb'

_debian_rules() { words=(make -f debian/rules) _make }
compdef _debian_rules debian/rules # type debian/rules <TAB> inside a source package

# see upgrade function in this file
compdef _hosts upgrade


###############
# MISC. STUFF #
###############

for confFiles in ~/.zshrc.local  /nix/etc/profile.d/nix.sh; do
    [ -r "$confFiles" ] && source "$confFiles"
done

pushd "$PHILCONF_DIR/zsh" >&-
	source ../zsh_global_functions
	source compilation
	source copy
	source duplicates
	source goinfre
	source highlight
	source maths
	source network
popd >&-


####################
# Phil STUPIDITIES #
####################
# Show the TODO file
[ -e ~/TODO ] && ([ -e ~/todo.sh ] && ~/todo.sh -l || < ~/TODO)

umask 0066
