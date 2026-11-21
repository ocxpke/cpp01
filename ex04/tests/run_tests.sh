#!/bin/bash
# Run from ex04/: make && ./tests/run_tests.sh
BIN=./sedIsForLosers
OK=0; KO=0

check() {
	# $1 name, $2 file, $3 s1, $4 s2, $5 expected content
	$BIN "$2" "$3" "$4"
	if [ "$(cat "$2.replace")" == "$5" ]; then
		echo "[OK] $1"; OK=$((OK+1))
	else
		echo "[KO] $1"; echo "  got:      $(cat "$2.replace")"; echo "  expected: $5"; KO=$((KO+1))
	fi
}

error() {
	# $1 name, rest: arguments that must fail
	name=$1; shift
	if $BIN "$@" 2>/dev/null; then
		echo "[KO] $name (should fail)"; KO=$((KO+1))
	else
		echo "[OK] $name"; OK=$((OK+1))
	fi
}

check "basic replace"        tests/basic.txt  "world" "42" $'Hello 42\nThe 42 is big\n4242\nno match here'
check "s2 empty (delete)"    tests/basic.txt  "world" ""   $'Hello \nThe  is big\n\nno match here'
check "s2 contains s1"       tests/repeat.txt "a"     "aa" "aaaaaaaa"
check "overlapping s1"       tests/repeat.txt "aa"    "b"  "bb"
check "no match"             tests/basic.txt  "xyz"   "42" "$(cat tests/basic.txt)"
check "empty file"           tests/empty.txt  "a"     "b"  ""
check "replace newline"      tests/basic.txt  $'\n'   " "  "Hello world The world is big worldworld no match here "

error "wrong number of args" tests/basic.txt "a"
error "file does not exist"  tests/nope.txt  "a" "b"
error "s1 empty"             tests/basic.txt ""  "b"

rm -f tests/*.replace
echo "OK: $OK  KO: $KO"
