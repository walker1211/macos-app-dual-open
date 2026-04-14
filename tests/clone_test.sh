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

chmod +x "$ROOT_DIR/tests/fixtures/bin/cp" "$ROOT_DIR/tests/fixtures/bin/PlistBuddy" "$ROOT_DIR/tests/fixtures/bin/codesign"
export PATH="$ROOT_DIR/tests/fixtures/bin:$PATH"
export APP_DUAL_LOG_FILE="$workspace/commands.log"

bash "$ROOT_DIR/bin/app-dual" clone "$workspace/source/WeChat.app"

secondary_app="$workspace/source/WeChat-secondary.app"
[[ -d "$secondary_app" ]] || fail "clone should create the secondary app"

bundle_id=$(python3 - <<'PY' "$secondary_app/Contents/Info.plist"
import plistlib, sys
with open(sys.argv[1], 'rb') as f:
    data = plistlib.load(f)
print(data['CFBundleIdentifier'])
PY
)
assert_eq "com.tencent.xin.secondary" "$bundle_id" "clone rewrites CFBundleIdentifier"

source_bundle_id=$(python3 - <<'PY' "$workspace/source/WeChat.app/Contents/Info.plist"
import plistlib, sys
with open(sys.argv[1], 'rb') as f:
    data = plistlib.load(f)
print(data['CFBundleIdentifier'])
PY
)
assert_eq "com.tencent.xin" "$source_bundle_id" "clone must not modify source CFBundleIdentifier"

log_contents=$(cat "$APP_DUAL_LOG_FILE")
assert_contains "$log_contents" "cp -R $workspace/source/WeChat.app $workspace/source/WeChat-secondary.app" "clone runs cp"
assert_contains "$log_contents" "PlistBuddy -c Print :CFBundleIdentifier $workspace/source/WeChat.app/Contents/Info.plist" "clone reads source bundle id"
assert_contains "$log_contents" "PlistBuddy -c Set :CFBundleIdentifier com.tencent.xin.secondary $workspace/source/WeChat-secondary.app/Contents/Info.plist" "clone writes secondary bundle id"
assert_contains "$log_contents" "codesign --force --deep --sign - $workspace/source/WeChat-secondary.app" "clone runs codesign"

duplicate_error=$(capture_failure bash "$ROOT_DIR/bin/app-dual" clone "$workspace/source/WeChat.app")
assert_contains "$duplicate_error" "Secondary app already exists" "clone refuses to overwrite existing secondary app"

echo "clone_test.sh: PASS"
