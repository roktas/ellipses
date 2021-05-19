#!/bin/bash

. ../t.sh

test.main() {
	export SRCPATH=$PWD

	cd foo/bar && src init ../../ && src compile test.sh && src decompile test.sh
}

t
