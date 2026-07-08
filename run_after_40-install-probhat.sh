#!/usr/bin/env bash
set -euo pipefail

layout="/Library/Keyboard Layouts/Probhat.keylayout"

[[ -f "$layout" ]] || curl -fsSL https://raw.githubusercontent.com/mdminhazulhaque/probhat-macos/master/install.sh | sudo bash

python3 <<'PY' && exit 0 || true
import plistlib
from pathlib import Path

path = Path.home() / "Library/Preferences/com.apple.HIToolbox.plist"
data = plistlib.loads(path.read_bytes()) if path.exists() else {}
keys = ("AppleEnabledInputSources", "AppleInputSourceHistory")
if all(any(source.get("KeyboardLayout Name") == "Probhat" for source in data.get(key, [])) for key in keys):
    raise SystemExit(0)
raise SystemExit(1)
PY

python3 <<'PY'
import plistlib
from pathlib import Path

path = Path.home() / "Library/Preferences/com.apple.HIToolbox.plist"
data = plistlib.loads(path.read_bytes()) if path.exists() else {}
probhat = {
    "InputSourceKind": "Keyboard Layout",
    "KeyboardLayout ID": -103001,
    "KeyboardLayout Name": "Probhat",
}

for key in ("AppleEnabledInputSources", "AppleInputSourceHistory"):
    sources = data.get(key, [])
    sources = [source for source in sources if source.get("KeyboardLayout Name") != "Probhat"]
    sources.append(probhat)
    data[key] = sources

path.write_bytes(plistlib.dumps(data))
PY

killall cfprefsd >/dev/null 2>&1 || true
killall TextInputMenuAgent >/dev/null 2>&1 || true
