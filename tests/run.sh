#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd)

bash "$ROOT_DIR/tests/common_test.sh"
bash "$ROOT_DIR/tests/clone_test.sh"
bash "$ROOT_DIR/tests/launch_test.sh"
bash "$ROOT_DIR/tests/update_remove_test.sh"
