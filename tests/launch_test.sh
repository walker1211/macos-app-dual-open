#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=tests/test-lib.sh
source "$ROOT_DIR/tests/test-lib.sh"

workspace=$(create_test_workspace)
trap 'rm -rf "$workspace"' EXIT

mkdir -p "$workspace/WeChat-secondary.app/Contents"
chmod +x "$ROOT_DIR/tests/fixtures/bin/open"
export PATH="$ROOT_DIR/tests/fixtures/bin:$PATH"
export APP_DUAL_LOG_FILE="$workspace/open.log"

bash "$ROOT_DIR/bin/app-dual" launch "$workspace/WeChat.app"

open_log=$(cat "$APP_DUAL_LOG_FILE")
assert_contains "$open_log" "open -a $workspace/WeChat-secondary.app" "launch opens the secondary app path"

: > "$APP_DUAL_LOG_FILE"
mkdir -p "$workspace/Missing-secondary.app/Contents"
bash "$ROOT_DIR/bin/app-dual" launch "$workspace/Missing.app"
path_first_log=$(cat "$APP_DUAL_LOG_FILE")
assert_contains "$path_first_log" "open -a $workspace/Missing-secondary.app" "launch derives secondary path even when source app is absent"

missing_error=$(capture_failure bash "$ROOT_DIR/bin/app-dual" launch "$workspace/StillMissing.app")
assert_contains "$missing_error" "Secondary app does not exist" "launch gives a readable missing-secondary error"

echo "launch_test.sh: PASS"
