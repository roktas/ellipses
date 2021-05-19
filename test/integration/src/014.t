#!/bin/bash

. ../t.sh

test.main() {
	export SRCPATH=$PWD

	cd foo/bar && src update
}

t
