#!/usr/bin/env bash
set -euo pipefail

clone_app() {
  local source_app
  local source_plist
  local source_bundle_id
  local target_app
  local target_plist
  local target_bundle_id

  source_app=$(require_source_app_path "$1")
  source_plist=$(info_plist_path "$source_app")
  [[ -f "$source_plist" ]] || die "Info.plist not found: $source_plist"

  source_bundle_id=$(run_plistbuddy -c "Print :CFBundleIdentifier" "$source_plist")
  [[ -n "$source_bundle_id" ]] || die "Failed to read CFBundleIdentifier from: $source_plist"

  target_app=$(secondary_app_path "$source_app")
  target_plist=$(info_plist_path "$target_app")
  target_bundle_id=$(secondary_bundle_id "$source_bundle_id")

  [[ ! -e "$target_app" ]] || die "Secondary app already exists: $target_app"

  run_cp "$source_app" "$target_app"
  run_plistbuddy -c "Set :CFBundleIdentifier $target_bundle_id" "$target_plist"
  run_codesign "$target_app"
}
