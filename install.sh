#!/usr/bin/env bash
# Installs herdr-zed into the Herdr app home and switches to its layout.
# Usage: ./install.sh [--force]
set -euo pipefail

readonly SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_DIR="${HERDR_APP_HOME:-$HOME/.config/herdr-app}"
readonly LAYOUT="main-zed"
readonly MODS=(zed-tabs)
# Earlier versions added a Zed row to a copy of the + menu.
readonly OLD_MODS=(zed-new-menu)

force=false
[[ "${1:-}" == "--force" ]] && force=true

die() { echo "herdr-zed: $*" >&2; exit 1; }

command -v herdr-app >/dev/null || die "herdr-app is not on PATH. Start the Herdr app one time, then try again."
[[ -d "$HOME_DIR" ]] || die "$HOME_DIR does not exist. Start the Herdr app one time, then try again."

targets=("$HOME_DIR/layouts/$LAYOUT.json")
for mod in "${MODS[@]}"; do targets+=("$HOME_DIR/mods/$mod"); done

if ! $force; then
  for t in "${targets[@]}"; do
    [[ -e "$t" ]] && die "$t exists. Run ./install.sh --force to replace it."
  done
fi

for mod in "${MODS[@]}"; do
  rm -rf "${HOME_DIR:?}/mods/$mod"
  cp -R "$SRC/mods/$mod" "$HOME_DIR/mods/$mod"
  herdr-app check "$HOME_DIR/mods/$mod"
done
for mod in "${OLD_MODS[@]}"; do rm -rf "${HOME_DIR:?}/mods/$mod"; done
cp "$SRC/layouts/$LAYOUT.json" "$HOME_DIR/layouts/$LAYOUT.json"

if herdr-app do layout.switch --name "$LAYOUT" >/dev/null 2>&1; then
  echo "herdr-zed: installed. Click Zed in the tab bar."
else
  echo "herdr-zed: installed. Open the Herdr app, then run: herdr-app do layout.switch --name $LAYOUT"
fi
