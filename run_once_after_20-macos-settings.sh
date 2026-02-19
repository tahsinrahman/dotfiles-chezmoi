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

log() {
    printf '[macos-settings] %s\n' "$*"
}

# Finder

log "Applying Finder preferences"

# Default view style (list view)
defaults write com.apple.finder FXPreferredViewStyle -string "$FINDER_DEFAULT_VIEW"
# Always show file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Show path breadcrumb bar at bottom
defaults write com.apple.finder ShowPathbar -bool true
# Show status bar (item count, disk space)
defaults write com.apple.finder ShowStatusBar -bool true
# Search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# New windows open at home directory
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "$FINDER_DEFAULT_LOCATION"

# Hide all drive types on desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# Sort folders before files
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Don't warn when changing file extensions
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Safari

# Use compact tab bar
# defaults write com.apple.Safari ShowStandaloneTabBar -bool false

# Dock

log "Applying Dock and Mission Control preferences"

# Icon size in pixels (36px)
defaults write com.apple.dock tilesize -int "$DOCK_TILESIZE"
# Position dock on right side of screen
defaults write com.apple.dock orientation -string "right"
# Use scale animation when minimizing
defaults write com.apple.dock mineffect -string "scale"
# Minimize windows into their app icon
defaults write com.apple.dock minimize-to-application -bool true
# Group windows by app in Mission Control
defaults write com.apple.dock expose-group-apps -bool true
# Hide recent apps section in dock
defaults write com.apple.dock show-recents -bool false
# Auto-hide the dock
defaults write com.apple.dock autohide -bool true
# Don't rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false
# No delay before dock shows on hover
defaults write com.apple.dock autohide-delay -float 0
# Faster dock show/hide animation (default 0.5)
defaults write com.apple.dock autohide-time-modifier -float 0.15

# Disable all hot corners (0 = no action)
defaults write com.apple.dock wvous-tl-corner -int 0
defaults write com.apple.dock wvous-tr-corner -int 0
defaults write com.apple.dock wvous-bl-corner -int 0
defaults write com.apple.dock wvous-br-corner -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0

# Menu bar (Control Center)

log "Applying Control Center preferences"

# Show battery percentage in menu bar
defaults -currentHost write com.apple.controlcenter.plist BatteryShowPercentage -bool true
# Show Bluetooth icon in menu bar
defaults -currentHost write com.apple.controlcenter.plist Bluetooth -int 18

# Trackpad

log "Applying Trackpad preferences"

# Tracking speed (0=slow, 3=fast)
defaults write -g com.apple.trackpad.scaling -float "$TRACKPAD_SPEED"
# Natural (content-follows-finger) scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Enable tap to click (both current host and global, built-in and bluetooth)
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Enable three-finger drag (built-in and bluetooth)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true

# Enable dragging (built-in and bluetooth)
defaults write com.apple.AppleMultitouchTrackpad Dragging -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -int 1

# Keyboard

log "Applying Keyboard and text input preferences"

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable auto-capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable double-space-to-period
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# Disable smart quotes (e.g. "" -> "")
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
# Disable smart dashes (e.g. -- -> —)
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
# Disable accent popup on key hold; enable key repeat instead
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
# Fast key repeat rate (lower = faster; default 6)
defaults write NSGlobalDomain KeyRepeat -int 2
# Short delay before repeat starts (lower = shorter; default 25)
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# UI

log "Applying UI and filesystem preferences"

# Expand save dialog by default
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
# Don't create .DS_Store on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Don't create .DS_Store on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Reduce UI animations system-wide
defaults write com.apple.universalaccess reduceMotion -bool true 2>/dev/null

# Sharing and continuity

log "Applying sharing and continuity preferences"

# AirDrop: visible to contacts only
defaults write com.apple.sharingd DiscoverableMode -string "Contacts Only"
# Allow Handoff: advertise activities to nearby devices
defaults write -g com.apple.coreservices.useractivityd.ActivityAdvertisingAllowed -bool true
# Allow Handoff: receive activities from nearby devices
defaults write -g com.apple.coreservices.useractivityd.ActivityReceivingAllowed -bool true

# Software updates and security responses

log "Applying software update preferences"

# Check for updates automatically
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
# Download updates in the background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1
# Install system data files automatically
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1
# Install critical security updates automatically
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1
# Auto-update App Store apps
defaults write com.apple.commerce AutoUpdate -bool true
# Enable scheduled update checks
softwareupdate --schedule on >/dev/null 2>&1 || log "Unable to toggle softwareupdate schedule (permission or OS restriction)"

# Screenshot workflow

log "Applying screenshot workflow preferences"

mkdir -p "$SCREENSHOTS_DIR"
# Save screenshots to ~/Screenshots
defaults write com.apple.screencapture location -string "$SCREENSHOTS_DIR"
# Remove window shadow from screenshots
defaults write com.apple.screencapture disable-shadow -bool true

# Add ~/Screenshots to Finder sidebar
mysides remove "Screenshots" >/dev/null 2>&1 || true
mysides add "Screenshots" "file://${SCREENSHOTS_DIR}" >/dev/null 2>&1

# Lock screen

# Require password immediately after sleep/screensaver
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Apply changes immediately where possible.

log "Reloading affected macOS services"

# Restart affected services to pick up changes
killall Finder >/dev/null 2>&1 || true
killall Dock >/dev/null 2>&1 || true
killall SystemUIServer >/dev/null 2>&1 || true
