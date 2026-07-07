#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

if ! osascript <<'APPLESCRIPT'
tell application "System Settings"
  activate
  open location "x-apple.systempreferences:com.apple.Keyboard-Settings.extension"
end tell

delay 2

tell application "System Events"
  tell process "System Settings"
    set frontmost to true

    try
      if value of checkbox "Adjust keyboard brightness in low light" of group 1 of group 2 of splitter group 1 of group 1 of window 1 is 1 then
        click checkbox "Adjust keyboard brightness in low light" of group 1 of group 2 of splitter group 1 of group 1 of window 1
      end if
    end try

    try
      set value of slider "Keyboard brightness" of group 1 of group 2 of splitter group 1 of group 1 of window 1 to 0
    end try
  end tell
end tell
APPLESCRIPT
then
  echo "Could not set keyboard backlight automatically. Grant Accessibility to Terminal/Codex and rerun this script."
  exit 0
fi
