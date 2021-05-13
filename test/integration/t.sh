#!/usr/bin/env bash

set -Eeuo pipefail; shopt -s nullglob; [[ -z ${TRACE:-} ]] || set -x; unset CDPATH; IFS=$' \t\n'

THIS="$(basename "${0##*/}" .t)"; readonly THIS

unset SRCPATH ELLIPSES_PATH

.cry() {
	echo >&2 "$@"
}

.die() {
	echo >&2 "$@"
	exit 1
}

t() {
	local src=$PWD/$THIS dest=$TESTROOT/$THIS
	local actual=$dest/a expected=$dest/b

	[[ -d $src   ]] || .die "No test fixture found: $src"

	mkdir -p "$dest"
	cp -a "$src"/. "$dest"

	[[ -e $actual   ]] || .die "No 'actual' file/directory found: $actual"
	[[ -e $expected ]] || .die "No 'expected' file/directory found: $expected"

	if [[ -d $actual ]]; then
		cd "$actual"
	else
		cd "$dest"
	fi

	test.main

	diff -r "$actual" "$expected" && rm -rf "$dest"
}
