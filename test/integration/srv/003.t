#!/bin/bash

. ../t.sh

test.main() {
	srv dump . a >out 2>err
}

t
