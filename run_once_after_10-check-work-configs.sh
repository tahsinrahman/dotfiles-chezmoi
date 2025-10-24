#!/bin/bash
# Check for missing work configuration files and offer to create them
# This runs once per machine after chezmoi apply on work machines

set -e

# Check if this is a work machine
CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"
if [[ -f "$CHEZMOI_CONFIG" ]]; then
    is_work=$(grep -A 1 "^\[data\.machine\]" "$CHEZMOI_CONFIG" 2>/dev/null | grep "is_work" | grep -q "true" && echo "true" || echo "false")
    if [[ "$is_work" != "true" ]]; then
        # Not a work machine, nothing to do
        exit 0
    fi
else
    # No config file, assume personal machine
    exit 0
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

MISSING_FILES=()
MISSING_CONFIG=()

echo -e "${BLUE}🏢 Work Machine Configuration Check${NC}"
echo "========================================"
echo ""

# Check chezmoi.toml for required work config
CHEZMOI_CONFIG="$HOME/.config/chezmoi/chezmoi.toml"
if [[ -f "$CHEZMOI_CONFIG" ]]; then
    # Check if git.work.gitlab_domain exists
    if ! grep -q "^\[data\.git\.work\]" "$CHEZMOI_CONFIG" 2>/dev/null || \
       ! grep -q "gitlab_domain" "$CHEZMOI_CONFIG" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Missing: git.work.gitlab_domain in chezmoi.toml${NC}"
        MISSING_CONFIG+=("gitlab_domain")
    else
        echo -e "${GREEN}✅ Found: git.work.gitlab_domain in chezmoi.toml${NC}"
    fi

    # Check if git.credential.token exists
    if ! grep -q "^\[data\.git\.credential\]" "$CHEZMOI_CONFIG" 2>/dev/null || \
       ! grep -q "token" "$CHEZMOI_CONFIG" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  Missing: git.credential.token in chezmoi.toml${NC}"
        MISSING_CONFIG+=("token")
    else
        echo -e "${GREEN}✅ Found: git.credential.token in chezmoi.toml${NC}"
    fi
else
    echo -e "${RED}❌ Missing: ~/.config/chezmoi/chezmoi.toml${NC}"
    MISSING_CONFIG+=("gitlab_domain" "token")
fi

echo ""
echo "Work files:"

# Check ~/.ssh/config.work
if [[ ! -f ~/.ssh/config.work ]]; then
    echo -e "${YELLOW}⚠️  Missing: ~/.ssh/config.work${NC}"
    MISSING_FILES+=("ssh")
else
    echo -e "${GREEN}✅ Found: ~/.ssh/config.work${NC}"
fi

# Check ~/.Brewfile.work
if [[ ! -f ~/.Brewfile.work ]]; then
    echo -e "${YELLOW}⚠️  Missing: ~/.Brewfile.work${NC}"
    MISSING_FILES+=("brewfile")
else
    echo -e "${GREEN}✅ Found: ~/.Brewfile.work${NC}"
fi

echo ""

# If no missing config or files, we're done
if [[ ${#MISSING_CONFIG[@]} -eq 0 && ${#MISSING_FILES[@]} -eq 0 ]]; then
    echo -e "${GREEN}🎉 All work configuration is complete!${NC}"
    exit 0
fi

# Handle missing chezmoi.toml config
if [[ ${#MISSING_CONFIG[@]} -gt 0 ]]; then
    echo -e "${YELLOW}⚠️  Missing work configuration in chezmoi.toml${NC}"
    echo ""
    echo "Please add the following to ~/.config/chezmoi/chezmoi.toml:"
    echo ""

    if [[ " ${MISSING_CONFIG[@]} " =~ " gitlab_domain " ]]; then
        echo -e "${BLUE}[data.git.work]"
        echo "    gitlab_domain = \"gitlab.company.com\"  # Change to your GitLab domain${NC}"
        echo ""
    fi

    if [[ " ${MISSING_CONFIG[@]} " =~ " token " ]]; then
        echo -e "${BLUE}[data.git.credential]"
        echo "    token = \"your-gitlab-token-here\"  # Your GitLab personal access token${NC}"
        echo ""
    fi

    echo "After adding these values, run:"
    echo "  chezmoi apply"
    echo ""
    echo "This will automatically add your work GitLab config to ~/.gitconfig"
    echo ""

    # Check if running interactively
    if [[ -t 0 ]]; then
        read -p "Open chezmoi.toml in editor now? (y/N): " edit_config
        if [[ "$edit_config" =~ ^[Yy] ]]; then
            ${EDITOR:-nano} ~/.config/chezmoi/chezmoi.toml
            echo ""
            echo "After saving, run: chezmoi apply"
            echo ""
        fi
    fi

    # Exit gracefully - user now knows what to do
    exit 0
fi

# Offer to create missing files
if [[ ${#MISSING_FILES[@]} -gt 0 ]]; then
    echo -e "${YELLOW}Some work configuration files are missing.${NC}"
    echo ""

    # Only prompt if interactive
    if [[ ! -t 0 ]]; then
        echo "Run 'chezmoi apply' interactively to set up these files."
        exit 0
    fi

    read -p "Create missing work configs now? (y/N): " create_now

    if [[ ! "$create_now" =~ ^[Yy] ]]; then
        echo ""
        echo -e "${BLUE}ℹ️  Skipped for now.${NC}"
        echo ""
        echo "To set up later, you can:"
        echo "  1. Re-run: chezmoi apply (this will check again)"
        echo "  2. Manually create the files in your home directory"
        echo ""
        exit 0
    fi

    echo ""
fi

# Create ~/.ssh/config.work
if [[ " ${MISSING_FILES[@]} " =~ " ssh " ]]; then
    echo -e "${BLUE}⚙️  Setting up ~/.ssh/config.work${NC}"
    echo ""
    echo "📝 Creating empty ~/.ssh/config.work"
    echo "   Add your work SSH proxy configurations here"
    echo ""
    echo "   Example:"
    echo "   Host *.internal.company.com"
    echo "    ForwardAgent yes"
    echo "    ProxyCommand ssh-login -h=%h -b=ssh.company.com:2222"
    echo ""

    mkdir -p ~/.ssh
    touch ~/.ssh/config.work
    chmod 600 ~/.ssh/config.work

    read -p "Do you want to edit ~/.ssh/config.work now? (y/N): " edit_ssh
    if [[ "$edit_ssh" =~ ^[Yy] ]]; then
        ${EDITOR:-nano} ~/.ssh/config.work
    fi
    echo -e "${GREEN}✅ ~/.ssh/config.work created${NC}"
    echo ""
fi

# Create ~/.Brewfile.work
if [[ " ${MISSING_FILES[@]} " =~ " brewfile " ]]; then
    echo -e "${BLUE}⚙️  Setting up ~/.Brewfile.work${NC}"
    echo ""

    if [[ -f ~/.local/share/chezmoi/Brewfile.work.example ]]; then
        cp ~/.local/share/chezmoi/Brewfile.work.example ~/.Brewfile.work
        echo -e "${GREEN}✅ ~/.Brewfile.work created from template${NC}"
        echo ""
        echo "📝 Edit ~/.Brewfile.work to add your work-specific packages"

        read -p "Do you want to edit ~/.Brewfile.work now? (y/N): " edit_brewfile
        if [[ "$edit_brewfile" =~ ^[Yy] ]]; then
            ${EDITOR:-nano} ~/.Brewfile.work
        fi
    else
        touch ~/.Brewfile.work
        echo -e "${GREEN}✅ ~/.Brewfile.work created (empty)${NC}"
    fi
    echo ""

    read -p "Install work packages from ~/.Brewfile.work now? (y/N): " install_work
    if [[ "$install_work" =~ ^[Yy] ]]; then
        echo "📦 Installing work packages..."
        brew bundle --file=~/.Brewfile.work
        echo -e "${GREEN}✅ Work packages installed${NC}"
    else
        echo "⏭️  Skipped. Run 'brew bundle --file=~/.Brewfile.work' later to install"
    fi
    echo ""
fi

echo ""
echo -e "${GREEN}🎉 Work configuration setup complete!${NC}"
echo ""
echo "📝 Work-specific files:"
echo "   - ~/.gitconfig (includes work GitLab config from chezmoi.toml)"
echo "   - ~/.ssh/config.work (SSH proxy configurations)"
echo "   - ~/.Brewfile.work (Work-specific packages)"
echo ""
echo "💡 To update GitLab credentials:"
echo "   1. Edit ~/.config/chezmoi/chezmoi.toml"
echo "   2. Run: chezmoi apply"
echo "   3. Your ~/.gitconfig will be automatically updated"
echo ""
