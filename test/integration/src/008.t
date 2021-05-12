#!/bin/bash

. ../t.sh

test.main() {
	src init
	src compile --paths=src foo/lib/foo/support/file.rb
	src compile --paths=src foo/lib/foo/support/digest.rb
}

t
