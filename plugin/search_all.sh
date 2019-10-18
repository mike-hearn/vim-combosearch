#!/usr/bin/env bash

# Arguments
SEARCH_QUERY="$(tr -d "\"\`\'^$" <<<"$1")"

colorize_file_output() {
	sed -E 's/^(.*)(:[0-9]+:[0-9]+)/\o033[0;33m\1\o033[0m\2/g'
}

colorize_output() {
	sed -E 's/^(.*):([0-9]+):([0-9]+)(:)/\o033[1;31m\1\o033[0m:\o033[1;32m\2:\o033[0m\3\o033[0m\4 /g'
}

sort -u <(rg --files | rg --ignore-case "$SEARCH_QUERY") <(git ls-files) | sed "s/$/:0:0/g" | colorize_file_output

rg \
	-uuuu \
	--color=never \
	--column \
	--ignore-case \
	--line-number \
	--max-columns=500 \
	--no-heading \
	--no-messages \
	--with-filename \
	"[A-Za-z0-9]" 2> /dev/null | rg --ignore-case "$SEARCH_QUERY" | colorize_output

