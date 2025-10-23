#!/bin/bash
# brew-update-brewfile.sh
# Update the Brewfile in chezmoi with currently installed packages
# Run this after manually installing new packages with brew install

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍺 Update Brewfile from Current System${NC}"
echo "========================================"

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${YELLOW}⏭️  This script only works on macOS${NC}"
    exit 0
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo -e "${RED}❌ Homebrew is not installed${NC}"
    exit 1
fi

# Get chezmoi source directory
CHEZMOI_SOURCE=$(chezmoi source-path)
BREWFILE="$CHEZMOI_SOURCE/Brewfile"

if [[ ! -f "$BREWFILE" ]]; then
    echo -e "${RED}❌ Brewfile not found in chezmoi at $BREWFILE${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Found Brewfile in chezmoi at $BREWFILE${NC}"
echo ""

# Show what's new
echo -e "${BLUE}📋 Checking for new packages...${NC}"
echo ""

# Create a temporary Brewfile
TEMP_BREWFILE=$(mktemp)
brew bundle dump --file="$TEMP_BREWFILE" --force 2>/dev/null

# Compare counts
CURRENT_TAPS=$(grep -c '^tap ' "$BREWFILE" || echo 0)
NEW_TAPS=$(grep -c '^tap ' "$TEMP_BREWFILE" || echo 0)
CURRENT_FORMULAE=$(grep -c '^brew ' "$BREWFILE" || echo 0)
NEW_FORMULAE=$(grep -c '^brew ' "$TEMP_BREWFILE" || echo 0)
CURRENT_CASKS=$(grep -c '^cask ' "$BREWFILE" || echo 0)
NEW_CASKS=$(grep -c '^cask ' "$TEMP_BREWFILE" || echo 0)
CURRENT_MAS=$(grep -c '^mas ' "$BREWFILE" || echo 0)
NEW_MAS=$(grep -c '^mas ' "$TEMP_BREWFILE" || echo 0)

echo "Current vs New:"
echo "   Taps:     $CURRENT_TAPS → $NEW_TAPS"
echo "   Formulae: $CURRENT_FORMULAE → $NEW_FORMULAE"
echo "   Casks:    $CURRENT_CASKS → $NEW_CASKS"
echo "   Mac Apps: $CURRENT_MAS → $NEW_MAS"
echo ""

# Check for differences
if cmp -s "$BREWFILE" "$TEMP_BREWFILE"; then
    echo -e "${GREEN}✅ No changes detected - Brewfile is up to date${NC}"
    rm "$TEMP_BREWFILE"
    exit 0
fi

echo -e "${YELLOW}⚠️  Changes detected!${NC}"
echo ""
echo "This will REPLACE your current organized Brewfile with an auto-generated one."
echo "Your current Brewfile has nice categories and comments."
echo ""
echo -e "${YELLOW}Options:${NC}"
echo "  1. Cancel and manually add new packages to keep organization"
echo "  2. Replace with auto-generated Brewfile (loses comments/organization)"
echo ""
read -p "Continue with replacement? (y/N) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}⏭️  Cancelled - keeping current Brewfile${NC}"
    echo ""
    echo -e "${BLUE}💡 To manually update, edit: $BREWFILE${NC}"
    rm "$TEMP_BREWFILE"
    exit 0
fi

# Backup current Brewfile
BACKUP_FILE="$BREWFILE.backup.$(date +%Y%m%d-%H%M%S)"
cp "$BREWFILE" "$BACKUP_FILE"
echo -e "${GREEN}✅ Backed up current Brewfile to $BACKUP_FILE${NC}"

# Replace Brewfile
mv "$TEMP_BREWFILE" "$BREWFILE"
echo -e "${GREEN}✅ Updated Brewfile${NC}"

# Show git diff
echo ""
echo -e "${BLUE}📝 Changes in Brewfile:${NC}"
cd "$CHEZMOI_SOURCE"
git diff Brewfile | head -50
echo ""

echo -e "${YELLOW}💡 Next steps:${NC}"
echo "   1. Review changes: cd $(chezmoi source-path) && git diff Brewfile"
echo "   2. Commit changes: cd $(chezmoi source-path) && git add Brewfile && git commit -m 'Update Brewfile'"
echo "   3. Push to remote: cd $(chezmoi source-path) && git push"
