#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=tests/test-lib.sh
source "$ROOT_DIR/tests/test-lib.sh"
# shellcheck source=lib/common.sh
source "$ROOT_DIR/lib/common.sh"

workspace=$(create_test_workspace)
trap 'rm -rf "$workspace"' EXIT

source_app="$workspace/WeChat.app"
mkdir -p "$source_app/Contents"
cat > "$source_app/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>com.tencent.xin</string>
</dict>
</plist>
EOF

assert_eq "$source_app" "$(require_app_path "$source_app")" "require_app_path returns the same .app path"
assert_eq "$workspace/WeChat-secondary.app" "$(secondary_app_path "$source_app")" "secondary app path appends -secondary"
assert_eq "com.tencent.xin.secondary" "$(secondary_bundle_id "com.tencent.xin")" "secondary bundle id appends .secondary"
assert_eq "$source_app/Contents/Info.plist" "$(info_plist_path "$source_app")" "info plist path resolves under Contents"

missing_error=$(capture_failure require_app_path "$workspace/Missing.app")
assert_contains "$missing_error" "Source app not found" "missing app returns readable error"

invalid_error=$(capture_failure require_app_path "$workspace/not-an-app")
assert_contains "$invalid_error" "must end with .app" "non-app path returns readable error"

mkdir -p "$workspace/WeChat-secondary.app"
secondary_input_error=$(capture_failure require_source_app_path "$workspace/WeChat-secondary.app")
assert_contains "$secondary_input_error" "must be the original .app" "secondary app path is rejected as source input"

echo "common_test.sh: PASS"
