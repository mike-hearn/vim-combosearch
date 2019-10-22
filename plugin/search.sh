#!/usr/bin/env bash

# Colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Arguments
SEARCH_QUERY="$(tr -d "\"\`\'^$" <<<"$1")"
IGNORE_OPTIONS=$2

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

sort -u <(rg --files | rg --ignore-case "$SEARCH_QUERY") <(git ls-files) | sed "s/$/:0:0/g" | colorize_file_output

rg \
	--color=never \
	--column \
	--hidden \
	--ignore-case \
	--ignore-file=<(printf "$IGNORE_OPTIONS") \
	--line-number \
	--max-columns=500 \
	--no-heading \
	--no-messages \
	--with-filename \
	"[A-Za-z0-9]" 2> /dev/null | rg --ignore-case "$SEARCH_QUERY" | colorize_output

