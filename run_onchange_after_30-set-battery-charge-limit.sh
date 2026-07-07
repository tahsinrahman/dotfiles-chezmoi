#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

shortcut_name="Set Battery Charge Limit"

# This shortcut is synced by iCloud Shortcuts; create it once if it is missing.
if shortcuts list | grep -Fxq "$shortcut_name"; then
    shortcuts run "$shortcut_name"
else
    echo "Shortcut missing: $shortcut_name"
fi
