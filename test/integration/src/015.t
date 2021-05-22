#!/bin/bash

. ../t.sh

test.main() {
	local ret

	src compile test.sh 2>err && ret=$? || ret=$?

	[[ $ret -gt 0 ]] || die "Failure expected where found exit code: $ret"
}

t
