#!/bin/bash
# brew-sync.sh
# Install/update all packages from ~/Brewfile
# Can be run manually anytime with: chezmoi cd && ./scripts/brew-sync.sh

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍺 Homebrew Bundle Sync${NC}"
echo "================================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}⏭️  This script only works on macOS${NC}"
    exit 0
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}❌ Homebrew is not installed${NC}"
    echo "Please run 'chezmoi init' first to install Homebrew"
    exit 1
fi

# Check if Brewfile exists
BREWFILE="$HOME/Brewfile"
if [[ ! -f "$BREWFILE" ]]; then
    echo -e "${RED}❌ Brewfile not found at $BREWFILE${NC}"
    echo "Please run 'chezmoi apply' first to create the Brewfile"
    exit 1
fi

echo -e "${GREEN}✅ Found Brewfile at $BREWFILE${NC}"
echo ""

# Show summary of what will be installed
echo -e "${BLUE}📋 Brewfile Summary:${NC}"
echo "   Taps:     $(grep -c '^tap ' "$BREWFILE" || echo 0)"
echo "   Formulae: $(grep -c '^brew ' "$BREWFILE" || echo 0)"
echo "   Casks:    $(grep -c '^cask ' "$BREWFILE" || echo 0)"
echo "   Mac Apps: $(grep -c '^mas ' "$BREWFILE" || echo 0)"
echo ""

# Ask for confirmation
read -p "Do you want to install/update packages from Brewfile? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⏭️  Skipping Homebrew installation${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}📦 Installing packages from Brewfile...${NC}"
echo "This may take a while..."
echo ""

# Install packages
if brew bundle --file="$BREWFILE" --no-lock; then
    echo ""
    echo -e "${GREEN}✅ Homebrew bundle installation complete!${NC}"
else
    echo ""
    echo -e "${RED}❌ Some packages failed to install${NC}"
    echo "Check the output above for details"
    exit 1
fi

# Cleanup old versions
echo ""
read -p "Do you want to cleanup old versions of packages? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🧹 Cleaning up old versions...${NC}"
    brew cleanup
    echo -e "${GREEN}✅ Cleanup complete!${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All done!${NC}"
echo ""
echo "Tip: Run 'brew bundle cleanup --file=$BREWFILE' to see packages"
echo "     that are installed but not in the Brewfile"
