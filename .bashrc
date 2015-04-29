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
PATH=~/bin:~/gwn_bin:/opt/android-sdk/platform-tools/:~/code/PLC/tools/report_processing_utilities/:~/code/PLC.SyncRoot/trunk/opt/scripts:~/code/misc/dcommit:$PATH
export EDITOR=vim
export VISUAL=vim
export DEFAULT_APPSERVER_USER=wdeberry

if [ -s ~/.Xmodmap ]; then
	xmodmap ~/.Xmodmap
fi

if [ -s ~/.xbindkeysrc ]; then
	xbindkeys
fi

if which keychain &>/dev/null; then
	eval $(keychain --eval --agents ssh -Q --quiet id_rsa)
fi

if xinput | grep -q IBM; then
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation" 1
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Button" 2
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Timeout" 200
	xinput set-prop "TPPS/2 IBM TrackPoint" "Evdev Wheel Emulation Axes" 6 7 4 5
	xinput --disable $( xinput list --id-only "SynPS/2 Synaptics TouchPad" )
	synclient TouchpadOff=$(synclient -l | grep -ce TouchpadOff.*0)
fi

if which setxkbmap &>/dev/null; then
	setxkbmap -option ctrl:nocaps
fi

if which svn &>/dev/null; then
	export PS1="[ \w\$(__svn_stat) ]\$ "
	SVNP_HUGE_REPO_EXCLUDE_PATH="nufw-svn$|/tags$|/branches$"
	SVNP_CHECK_DISTANT_REPO="1"
	source ~/bin/subversion-prompt
else
	export PS1="[ \w ]\$ "
fi

function colorize_diff() {
	case "${#}" in
		0)
			local no_color="$( echo -e "\e[0m" )"
			local diff_before="$( echo -e "\e[1;31m" )"
			local diff_after="$( echo -e "\e[1;34m" )"
			local diff_meta="$( echo -e "\e[1;32m" )"
			local diff_locator="$( echo -e "\e[1;33m" )"
			local diff_msg="$( echo -e "\e[0;35m" )"
			sed \
				-e "s/^-.*\$/${diff_before}&${no_color}/g" \
				-e "s/^+.*\$/${diff_after}&${no_color}/g" \
				-e "s/^@.*\$/${diff_locator}&${no_color}/g" \
				-e "s/^Index: .*\$/${diff_meta}&${no_color}/g" \
				-e "s/^===.*\$/${diff_meta}&${no_color}/g" \
				-e "s/^diff .*\$/${diff_meta}&${no_color}/g" \
				-e "s/^\\\\ No newline at end of file.*\$/${diff_meta}&${no_color}/g" \
				-e "s/^Only in .*\$/${diff_msg}&${no_color}/g" \
				-e "s/^Binary files .*\$/${diff_msg}&${no_color}/g"
			echo -n "${no_color}"
			;;
		1|2)
			diff -u "${@}" | colorize_diff
			;;
		*)
			diff "${@}" | colorize_diff
			;;
	esac
}

function hilite() {
	if [ "${#}" -eq 0 ] ; then
		cat <<END_OF_USAGE
hilite [-i] PATTERN[:COLOR] [...]

Copy stdin to stdout, highlighting the specified PATTERN(s) in
the corresponding COLOR(s).

PATTERN is a sed-compatible regular expression
	foo
	error: [0-9][-9]

COLOR is one of the supported colors or the first letter thereof:
	red
	green
	yellow
	blue
	purple
	cyan
	white (effectively bold)

Use a capital letter [RGYBPCW] to invert the highlighting. Use -i to
invert all highlighting.

This uses sed under the hood, so you may use the delimiter of your
choice by separating PATTERN and COLOR with that delimiter.

If no color code is provided, red is assumed (like grep) and the
delimiter is assumed to be /.

If the delimiter appears in PATTERN, you will have to either:
	1) choose a different delimiter by explicitly specifying it and COLOR
	2) escape occurrences of the delimiter character in PATTERN

Recognized delimiters are defined by the character class [:_|/%]

Examples:

	Highlight a few different things in different colors
		... | hilite foo:red bar:blue baz:yellow

	Use shorthand notation for those colors
		... | hilite foo:r bar:b baz:y

	Highlight the current time (HH:MM:SS) in purple
		date | hilite '[012][0-9]:[0-5][0-9]:[0-5][0-9]%p'
END_OF_USAGE
		return
	elif [ "${#}" -eq 1 ] && [ "${1}" == "--exercise" ] ; then
		echo red green yellow blue purple cyan white | hilite red:r green:g yellow:y blue:b purple:p cyan:c white:w
		return
	elif [ "${#}" -eq 1 ] && [ "${1}" == "--exercise-bg" ] ; then
		echo red green yellow blue purple cyan white | hilite -i red:r green:g yellow:y blue:b purple:p cyan:c white:w
		return
	fi

	local patterns_file="$( mktemp )"
	local pattern color delimiter

	local invert=''

	for arg ; do
		test "${arg}" == '-i' && invert='true'
	done

	for arg ; do
		color="$( echo "${arg}" | grep -oP '[:_|/%][a-zA-Z]+$' )"
		if [ -z "${color}" ] ; then
			color="r"
			pattern="${arg}"
			delimiter="/"
		else
			pattern="${arg%${color}}"
			delimiter="${color:0:1}"
			color="${color:1}"
		fi

		case "${color}" in
			r|red)    test "${invert}" && color='\x1b[101;90m' || color='\x1b[1;31m' ;;
			g|green)  test "${invert}" && color='\x1b[102;90m' || color='\x1b[1;32m' ;;
			y|yellow) test "${invert}" && color='\x1b[103;90m' || color='\x1b[1;33m' ;;
			b|blue)   test "${invert}" && color='\x1b[104;90m' || color='\x1b[1;34m' ;;
			p|purple) test "${invert}" && color='\x1b[105;90m' || color='\x1b[1;35m' ;;
			c|cyan)   test "${invert}" && color='\x1b[106;90m' || color='\x1b[1;36m' ;;
			w|white)  test "${invert}" && color='\x1b[107;90m' || color='\x1b[1;37m' ;;

			R) color='\x1b[101;90m' ;;
			G) color='\x1b[102;90m' ;;
			Y) color='\x1b[103;90m' ;;
			B) color='\x1b[104;90m' ;;
			P) color='\x1b[105;90m' ;;
			C) color='\x1b[106;90m' ;;
			W) color='\x1b[107;90m' ;;

			*) printf "Error: unexpected color specification '%s%s' for pattern %s\n" "${delimiter}" "${color}" "${pattern}" 1>&2 ;;
		esac

		printf '%s\n' "s${delimiter}${pattern}${delimiter}${color}&"'\x1b[0m'"${delimiter}g" >>"${patterns_file}"
	done

	sed -f "${patterns_file}"
	rm -f "${patterns_file}"
}

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

function rsync-progress() {
	local source="${1}"
	local dest="${2}"
	local command="rsync -azv"
	local expected_lines="$( ${command} --dry-run ${source} ${dest} | wc -l )"
	${command} ${source} ${dest} | pv --line-mode --size "${expected_lines}" --progress --timer --rate >/dev/null
}
