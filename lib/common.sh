#!/usr/bin/env bash
set -euo pipefail

log_info() {
  printf '[INFO] %s\n' "$1"
}

log_error() {
  printf '[ERROR] %s\n' "$1" >&2
}

die() {
  log_error "$1"
  exit 1
}

require_app_path() {
  local app_path=$1
  [[ "$app_path" == *.app ]] || die "Source path must end with .app: $app_path"
  [[ -e "$app_path" ]] || die "Source app not found: $app_path"
  printf '%s\n' "$app_path"
}

require_source_app_path() {
  local app_path
  local base

  app_path=$(require_app_path "$1")
  base=$(basename "$app_path" .app)
  [[ "$base" != *-secondary ]] || die "Source app must be the original .app, not an existing secondary copy: $app_path"
  printf '%s\n' "$app_path"
}

info_plist_path() {
  local app_path=$1
  printf '%s\n' "$app_path/Contents/Info.plist"
}

secondary_app_path() {
  local app_path=$1
  local dir
  local base
  dir=$(dirname "$app_path")
  base=$(basename "$app_path" .app)
  printf '%s/%s-secondary.app\n' "$dir" "$base"
}

secondary_bundle_id() {
  local bundle_id=$1
  printf '%s.secondary\n' "$bundle_id"
}

plistbuddy_bin() {
  if [[ -n "${APP_DUAL_PLISTBUDDY:-}" ]]; then
    printf '%s\n' "$APP_DUAL_PLISTBUDDY"
  elif command -v PlistBuddy >/dev/null 2>&1; then
    command -v PlistBuddy
  else
    printf '/usr/libexec/PlistBuddy\n'
  fi
}

run_cp() {
  cp -R "$1" "$2"
}

run_rm() {
  rm -rf "$1"
}

run_plistbuddy() {
  "$(plistbuddy_bin)" "$@"
}

run_codesign() {
  codesign --force --deep --sign - "$1"
}

run_open_app() {
  open -a "$1"
}
