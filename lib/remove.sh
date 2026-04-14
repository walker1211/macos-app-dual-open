#!/usr/bin/env bash
set -euo pipefail

remove_app() {
  local source_app
  local target_app

  source_app=$(require_source_app_path "$1")
  target_app=$(secondary_app_path "$source_app")

  [[ -e "$target_app" ]] || die "Secondary app does not exist: $target_app"
  run_rm "$target_app"
  log_info "Removed secondary app: $target_app"
}
