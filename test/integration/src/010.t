#!/bin/bash

. ../t.sh

test.main() {
	export SRCPATH="$PWD"/x/y/z
	src init && src compile test.sh && src decompile test.sh
}

t
