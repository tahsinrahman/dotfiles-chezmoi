#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
    exit 0
fi

FINDER_DEFAULT_VIEW="Nlsv" # Nlsv=list, Clmv=columns, Flwv=gallery, Icwv=icons
FINDER_DEFAULT_LOCATION="file://${HOME}/"
DOCK_TILESIZE=36
TRACKPAD_SPEED=3
SCREENSHOTS_DIR="${HOME}/Screenshots"

# Finder

defaults write com.apple.finder FXPreferredViewStyle -string "$FINDER_DEFAULT_VIEW"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf" # Search current folder

defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "$FINDER_DEFAULT_LOCATION"

defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder _FXSortFoldersFirst -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Safari

# defaults write com.apple.Safari ShowStandaloneTabBar -bool false

# Dock

defaults write com.apple.dock tilesize -int "$DOCK_TILESIZE"
defaults write com.apple.dock orientation -string "right"
defaults write com.apple.dock mineffect -string "scale"
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock mru-spaces -bool false
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Disable all hot corners.
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# Menu bar (Control Center)

defaults -currentHost write com.apple.controlcenter.plist BatteryShowPercentage -bool true
defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18

# Trackpad

defaults write -g com.apple.trackpad.scaling -float "$TRACKPAD_SPEED"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

defaults write com.apple.AppleMultitouchTrackpad Dragging -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -int 1

# Keyboard

defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# UI

defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Screenshot workflow
mkdir -p "$SCREENSHOTS_DIR"
defaults write com.apple.screencapture location -string "$SCREENSHOTS_DIR"
defaults write com.apple.screencapture disable-shadow -bool true

# Finder sidebar favorite: Screenshots
mysides remove "Screenshots" >/dev/null 2>&1 || true
mysides add "Screenshots" "file://${SCREENSHOTS_DIR}" >/dev/null 2>&1

# Lock immediately after sleep/screensaver.
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Apply changes immediately where possible.
killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
