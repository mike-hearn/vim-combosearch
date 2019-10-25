#!/usr/bin/env bash

# Arguments
search_query="$(tr -d "\"\`\'^$" <<<"$1")"

# Colors
black="$(tput setaf 0)"
red="$(tput setaf 1)"
green="$(tput setaf 2)"
orange="$(tput setaf 3)"
blue="$(tput setaf 4)"
reset="$(tput sgr0)"

colorize_file_output() {
	LC_ALL=C sed -E "s/^(.*)(:[0-9]+:[0-9]+)/$orange\1$black\2$reset/g"
}

colorize_output() {
	LC_ALL=C sed -E "s|^(.*):([0-9]+):([0-9]+)(:)|$red\1$reset:$green\2$(tput sgr0):$reset\3\4 |g"
}

callcommand() {
	awk '!x[$0]++' <({ rg -uu --files 2> /dev/null | rg --ignore-case "$search_query"; } & { git ls-files 2> /dev/null; }) | sed "s/$/:0:0/g" | colorize_file_output

	rg \
		-uu \
		--color=never \
		--column \
		--ignore-case \
		--line-number \
		--max-columns=500 \
		--no-heading \
		--no-messages \
		--with-filename \
		"[A-Za-z0-9]" 2> /dev/null | rg --ignore-case "$search_query" | colorize_output
}

callcommand & trap 'kill -9 $!' SIGPIPE
