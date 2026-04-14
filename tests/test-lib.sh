#!/usr/bin/env bash
set -euo pipefail

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_eq() {
  local expected=$1
  local actual=$2
  local message=$3
  if [[ "$expected" != "$actual" ]]; then
    fail "$message (expected: $expected, actual: $actual)"
  fi
}

assert_contains() {
  local haystack=$1
  local needle=$2
  local message=$3
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "$message (missing: $needle)"
  fi
}

assert_not_contains() {
  local haystack=$1
  local needle=$2
  local message=$3
  if [[ "$haystack" == *"$needle"* ]]; then
    fail "$message (unexpected: $needle)"
  fi
}

capture_failure() {
  set +e
  local output
  output=$("$@" 2>&1)
  local status=$?
  set -e
  if [[ $status -eq 0 ]]; then
    fail "expected failure from: $*"
  fi
  printf '%s' "$output"
}

create_test_workspace() {
  mktemp -d "${TMPDIR:-/tmp}/app-dual-test.XXXXXX"
}
