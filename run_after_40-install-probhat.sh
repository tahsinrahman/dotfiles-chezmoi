#!/usr/bin/env bash
set -euo pipefail

layout="/Library/Keyboard Layouts/Probhat.keylayout"

[[ -f "$layout" ]] || curl -fsSL https://raw.githubusercontent.com/mdminhazulhaque/probhat-macos/master/install.sh | sudo bash

python3 <<'PY'
import plistlib
from pathlib import Path

path = Path.home() / "Library/Preferences/com.apple.HIToolbox.plist"
data = plistlib.loads(path.read_bytes()) if path.exists() else {}
sources = data.get("AppleEnabledInputSources", [])

probhat = {
    "InputSourceKind": "Keyboard Layout",
    "KeyboardLayout ID": "-103001",
    "KeyboardLayout Name": "Probhat",
}

sources = [source for source in sources if source.get("KeyboardLayout Name") != "Probhat"]
sources.append(probhat)
data["AppleEnabledInputSources"] = sources
path.write_bytes(plistlib.dumps(data))
PY

killall cfprefsd >/dev/null 2>&1 || true
killall TextInputMenuAgent >/dev/null 2>&1 || true
