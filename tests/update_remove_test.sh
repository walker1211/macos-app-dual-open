#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck source=tests/test-lib.sh
source "$ROOT_DIR/tests/test-lib.sh"

workspace=$(create_test_workspace)
trap 'rm -rf "$workspace"' EXIT

mkdir -p "$workspace/source/WeChat.app/Contents"
cat > "$workspace/source/WeChat.app/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>com.tencent.xin</string>
</dict>
</plist>
EOF

mkdir -p "$workspace/source/WeChat-secondary.app/Contents"
cat > "$workspace/source/WeChat-secondary.app/Contents/Info.plist" <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleIdentifier</key>
  <string>old.bundle.id</string>
</dict>
</plist>
EOF

chmod +x "$ROOT_DIR/tests/fixtures/bin/cp" "$ROOT_DIR/tests/fixtures/bin/PlistBuddy" "$ROOT_DIR/tests/fixtures/bin/codesign" "$ROOT_DIR/tests/fixtures/bin/rm"
export PATH="$ROOT_DIR/tests/fixtures/bin:$PATH"
export APP_DUAL_LOG_FILE="$workspace/update-remove.log"

update_output=$(bash "$ROOT_DIR/bin/app-dual" update "$workspace/source/WeChat.app")
assert_contains "$update_output" "[INFO] Updated secondary app: $workspace/source/WeChat-secondary.app" "update prints updated success message"
assert_not_contains "$update_output" "[INFO] Created secondary app" "update does not print created success message"

bundle_id=$(python3 - <<'PY' "$workspace/source/WeChat-secondary.app/Contents/Info.plist"
import plistlib, sys
with open(sys.argv[1], 'rb') as f:
    data = plistlib.load(f)
print(data['CFBundleIdentifier'])
PY
)
assert_eq "com.tencent.xin.secondary" "$bundle_id" "update recreates the secondary bundle id"

source_bundle_id=$(python3 - <<'PY' "$workspace/source/WeChat.app/Contents/Info.plist"
import plistlib, sys
with open(sys.argv[1], 'rb') as f:
    data = plistlib.load(f)
print(data['CFBundleIdentifier'])
PY
)
assert_eq "com.tencent.xin" "$source_bundle_id" "update must not modify source CFBundleIdentifier"

update_log=$(cat "$APP_DUAL_LOG_FILE")
assert_contains "$update_log" "rm -rf $workspace/source/WeChat-secondary.app" "update removes the old secondary app before cloning"

: > "$APP_DUAL_LOG_FILE"
bash "$ROOT_DIR/bin/app-dual" remove "$workspace/source/WeChat.app"
[[ ! -e "$workspace/source/WeChat-secondary.app" ]] || fail "remove deletes the secondary app"

remove_log=$(cat "$APP_DUAL_LOG_FILE")
assert_contains "$remove_log" "rm -rf $workspace/source/WeChat-secondary.app" "remove deletes the derived secondary path"

remove_missing_error=$(capture_failure bash "$ROOT_DIR/bin/app-dual" remove "$workspace/source/WeChat.app")
assert_contains "$remove_missing_error" "Secondary app does not exist" "remove errors when the secondary app is absent"

echo "update_remove_test.sh: PASS"
