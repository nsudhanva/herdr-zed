#!/usr/bin/env bash
# Removes herdr-zed and switches back to the shipped "main" layout.
set -euo pipefail

readonly HOME_DIR="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"

if command -v herdr-app >/dev/null; then
  herdr-app do layout.switch --name main >/dev/null 2>&1 || true
fi

rm -f "$HOME_DIR/layouts/main-zed.json"
rm -rf "${HOME_DIR:?}/mods/zed-tabs" "${HOME_DIR:?}/mods/zed-new-menu"
echo "herdr-zed: removed."
