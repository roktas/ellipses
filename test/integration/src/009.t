#!/bin/bash

. ../t.sh

test.main() {
	src update --paths=src
}

t
