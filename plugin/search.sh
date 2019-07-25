#!/usr/bin/env sh

search_by_path() {
	fd --full-path "$*" | sed "s/$/:0:0/g"
}

search_all_lines_except_matches() {
	rg --column --hidden --max-columns=500  --line-number --ignore-case --no-heading --color=always --invert-match "$@" $(fd "$@") | rg ":.*:.*:.*\w.*$"
}

search_matches() {
	rg --column --hidden --max-columns=500 --line-number --ignore-case --no-heading --color=always "$*"
}

search_by_path "$@"
search_all_lines_except_matches "$@"
search_matches "$@"
