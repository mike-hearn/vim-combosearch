#!/usr/bin/env bash

# Arguments
SEARCH_QUERY="$(tr -d "\"\`\'^$" <<<"$1")"

# Colors
black="$(tput setaf 0)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"
orange="$(tput setaf 3)"
reset="$(tput sgr0)"

colorize_file_output() {
	LC_ALL=C sed -E "s/^(.*)(:[0-9]+:[0-9]+)/$orange\1$black\2$reset/g"
}

colorize_output() {
	LC_ALL=C sed -E "s|^(.*):([0-9]+):([0-9]+)(:)|$red\1$reset:$green\2$(tput sgr0):$reset\3\4 |g"
}

callgitgrepcommand() {
	git --no-pager ls-files -cmo --exclude-standard ":(icase)**$SEARCH_QUERY**" 2>/dev/null | LC_ALL=C sed "s/$/:0:0:/g" | colorize_file_output
	awk '!x[$0]++' <(
		(git --no-pager grep -I -n -i --untracked "$SEARCH_QUERY" 2>/dev/null | LC_ALL=C sed -E "s/:([0-9]+):/:\1:0:/g" | colorize_output)
	)
}

callgrepcommand() {
	awk '!x[$0]++' <(
		(find . -type f -ipath "*$SEARCH_QUERY*" 2>/dev/null | LC_ALL=C sed "s/$/:0:0:/g" | colorize_file_output)
		(grep -rIHin "$SEARCH_QUERY" . 2>/dev/null 2>/dev/null | LC_ALL=C sed -E "s/:([0-9]+):/:\1:0:/g" | colorize_output)
	)
}

if (git -C . rev-parse 2>/dev/null) && [ "$2" != 'all' ]; then
	callgitgrepcommand &
	trap 'kill -9 $!' SIGPIPE
else
	callgrepcommand &
	trap 'kill -9 $!' SIGPIPE
fi
