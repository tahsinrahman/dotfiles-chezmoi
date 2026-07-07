#!/usr/bin/env bash
set -euo pipefail

layout="/Library/Keyboard Layouts/Probhat.keylayout"

[[ -f "$layout" ]] || curl -fsSL https://raw.githubusercontent.com/mdminhazulhaque/probhat-macos/master/install.sh | sudo bash

if ! defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null | grep -q 'KeyboardLayout Name = Probhat'; then
  defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add '{
    InputSourceKind = "Keyboard Layout";
    "KeyboardLayout ID" = "-103001";
    "KeyboardLayout Name" = "Probhat";
  }'
fi

killall cfprefsd >/dev/null 2>&1 || true
killall TextInputMenuAgent >/dev/null 2>&1 || true
