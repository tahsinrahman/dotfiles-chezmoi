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
    my clickOff("Adjust keyboard brightness in low light", window 1)
    my setSliderToZero("Keyboard brightness", window 1)
  end tell
end tell

on clickOff(targetName, rootElement)
  tell application "System Events"
    try
      if (name of rootElement as text) is targetName then
        try
          if value of rootElement is 1 then click rootElement
          return true
        end try
      end if
    end try

    try
      repeat with childElement in UI elements of rootElement
        if my clickOff(targetName, childElement) then return true
      end repeat
    end try
  end tell
  return false
end clickOff

on setSliderToZero(targetName, rootElement)
  tell application "System Events"
    try
      if (role of rootElement as text) is "AXSlider" then
        try
          if (name of rootElement as text) contains targetName then
            set value of rootElement to 0
            return true
          end if
        end try
      end if
    end try

    try
      repeat with childElement in UI elements of rootElement
        if my setSliderToZero(targetName, childElement) then return true
      end repeat
    end try
  end tell
  return false
end setSliderToZero
APPLESCRIPT
then
  echo "Could not set keyboard backlight automatically. Grant Accessibility to Terminal/Codex and rerun this script."
  exit 0
fi
