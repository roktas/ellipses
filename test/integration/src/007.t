#!/bin/bash

. ../t.sh

test.main() {
	src init && src compile --paths=src test.sh && src decompile --paths=src test.sh
}

t
