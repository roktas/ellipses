#!/bin/bash

. ../t.sh

test.main() {
	src init && src compile test.sh
}

t
