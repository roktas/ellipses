#!/bin/bash

. ../t.sh

test.main() {
	src init && src compile --paths=src test.sh
}

t
