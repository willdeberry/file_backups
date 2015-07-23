colorize_diff() {
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

hilite() {
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

svndiff() {
	svn diff "${@}" | colorize_diff | less
}

svn-log-grep() {
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

svn-log-step() {
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

rsync-progress() {
	local source="${1}"
	local dest="${2}"
	local command="rsync -azv"
	local expected_lines="$(${command} -n ${source} ${dest} | wc -l)"
	${command} ${source} ${dest} | pv -ptlr -s "${expected_lines}" >/dev/null
}

battery_status() {
	if [ ! -e "/sys/class/power_supply/BAT0/energy_now" ]; then
		return 1
	fi

	local current="$(cat /sys/class/power_supply/BAT0/energy_now)"
	local full="$(cat /sys/class/power_supply/BAT0/energy_full)"
	local charge="$(echo "${current}/${full}*100" | bc -l | cut -c 1-5 | cut -d'.' -f1)"

	local none='\033[00m'
	local red='\033[01;31m'
	local green='\033[01;32m'
	local yellow='\033[01;33m'

	local color="$red"

	# prevent a charge of more than 100% displaying
	if [ "$charge" -gt "99" ]; then
		charge=100
	fi

	if [ "$charge" -gt "15" ]; then
		color="$yellow"
	fi

	if [ "$charge" -gt "30" ]; then
		color="$green"
	fi

	echo -e "${color}${charge}%${none}"
}

datetimestamp() {
	date '+%R %a %F'
}

network_connection() {
	nmcli --nocheck dev status | awk '$3 == "connected" {print $4}' | head -n 1
}
