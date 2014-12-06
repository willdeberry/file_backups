# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    #alias grep='grep --color=auto'
    #alias fgrep='fgrep --color=auto'
    #alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -l'
#alias la='ls -A'
#alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

ANDROID_HOME=~/documents/android-studio/sdk
JAVA_HOME=/usr/lib/jvm/java-6-openjdk-amd64/jre/
PATH=~/bin:~/gwn_bin:/opt/android-sdk/platform-tools/:~/code/PLC/tools/report_processing_utilities/:~/code/PLC.SyncRoot/trunk/opt/scripts:~/code/misc/dcommit:$PATH
export EDITOR=vim
export VISUAL=vim
export DEFAULT_APPSERVER_USER=wdeberry

if [ -n "$( which keychain )" ]; then
	eval $(keychain --eval --agents ssh -Q --quiet id_rsa)
fi

if [ -n "$( which xinput )" ]; then
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
	xinput --disable $( xinput list --id-only "SynPS/2 Synaptics TouchPad" )
fi

if [ -n "$( which synclient )" ]; then
	synclient TouchpadOff=$(synclient -l | grep -ce TouchpadOff.*0)
fi

if [ -n "$( which setxkbmap )" ]; then
	setxkbmap -option ctrl:nocaps
fi

SVNP_HUGE_REPO_EXCLUDE_PATH="nufw-svn$|/tags$|/branches$"
SVNP_CHECK_DISTANT_REPO="1"
. ~/bin/subversion-prompt

if [ -n "$( which svn )" ]; then
	export PS1="[ \w\$(__svn_stat) ]\$ "
else
	export PS1="[ \w ]\$ "
fi

bind '"\e[5~": history-search-backward'
bind '"\e[6~": history-search-forward'

function svndiff() {
    svn diff "${@}" | colorize_diff | less
}

function svn-log-grep() {
	local reverse="-r"

	if [ "${#}" -eq 0 ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
		echo "Usage: svn-log-grep [-r] PATTERN TARGET"
		echo
		echo "Searches for PATTERN in diffs of TARGET from HEAD backwards"
		return
	fi

	case "${1}" in
		"-r")
			reverse=""
			shift
			;;
	esac

    local pattern="${1}"
    local target="${2}"

    for rev in $( svn log "${target}" | grep -oP "(?<=^r)\d+(?= |)" | sort -n ${reverse} ) ; do
        if svn log -r "${rev}" "${target}" | grep -q "${pattern}" 2>/dev/null || svn diff -c "${rev}" "${target}" | grep -q "^[+-].*${pattern}" 2>/dev/null ; then
			clear
            cat <<END_OF_PROMPT
Found a match in revision ${rev}:
$( svn log -v -c "${rev}" )
END_OF_PROMPT
            read -n 1 -p "View diff? (y/N/q) "
            echo
            if [ "${REPLY}" == "y" ] || [ "${REPLY}" == "Y" ] ; then
                svndiff -c "${rev}" "${target}"
            elif [ "${REPLY}" == "q" ] || [ "${REPLY}" == "Q" ] ; then
                break
            fi
        fi
    done
}

function svn-log-step() {
	local reverse=""

	if [ "${#}" -eq 0 ] || [ "${1}" == "-h" ] || [ "${1}" == "--help" ] ; then
		echo "Usage: svn-log-step [-r] TARGET"
		echo
		echo "Steps through all diffs of TARGET from the beginning to HEAD"
		return
	fi

	case "${1}" in
		"-r")
			reverse="-r"
			shift
			;;
	esac

    local target="${1}"

    for rev in $( svn log "${target}" | grep -oP "(?<=^r)\d+(?= |)" | sort -n ${reverse} ) ; do
        clear
        svn log -v -c "${rev}"
        read -n 1 -p "View diff? (Y/n/q) "
        echo
        if [ -z "${REPLY}" ] || [ "${REPLY}" == "y" ] || [ "${REPLY}" == "Y" ] ; then
            svndiff -c "${rev}" "${target}"
        elif [ "${REPLY}" == "q" ] || [ "${REPLY}" == "Q" ] ; then
            break
        fi
    done
}
