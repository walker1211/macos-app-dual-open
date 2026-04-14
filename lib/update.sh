#!/usr/bin/env bash
set -euo pipefail

update_app() {
  local source_app
  local target_app

  source_app=$(require_source_app_path "$1")
  target_app=$(secondary_app_path "$source_app")

  if [[ -e "$target_app" ]]; then
    run_rm "$target_app"
  fi

  clone_app "$source_app"
  log_info "Updated secondary app: $target_app"
}
