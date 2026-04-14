#!/usr/bin/env bash
set -euo pipefail

launch_app() {
  local source_app=$1
  local target_app

  [[ "$source_app" == *.app ]] || die "Source path must end with .app: $source_app"
  target_app=$(secondary_app_path "$source_app")

  [[ -e "$target_app" ]] || die "Secondary app does not exist: $target_app"
  run_open_app "$target_app"
  log_info "Launched secondary app: $target_app"
}
