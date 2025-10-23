#!/bin/bash
# bootstrap.sh - New Mac setup script
# Run this first on a brand new Mac

set -e

echo "🚀 New Mac Bootstrap"
echo "===================="
echo ""

# 1. Install Homebrew
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon
    if [[ $(uname -m) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    echo "✅ Homebrew installed"
else
    echo "✅ Homebrew already installed"
fi

echo ""

# 2. Generate SSH key
if [[ ! -f ~/.ssh/id_rsa ]]; then
    echo "🔑 Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    echo "✅ SSH key generated"
    echo ""
    echo "📋 Your public key:"
    cat ~/.ssh/id_rsa.pub
    echo ""
    echo "⚠️  Add this key to GitHub/GitLab before continuing"
    read -p "Press Enter once you've added the key..."
else
    echo "✅ SSH key already exists"
fi

echo ""

# 3. Install chezmoi
if ! command -v chezmoi &> /dev/null; then
    echo "📦 Installing chezmoi..."
    brew install chezmoi
    echo "✅ chezmoi installed"
else
    echo "✅ chezmoi already installed"
fi

echo ""

# 4. Initialize chezmoi with dotfiles repo
echo "📂 Initialize chezmoi..."
DOTFILES_REPO="git@github.com:tahsinrahman/dotfiles-chezmoi.git"

chezmoi init "$DOTFILES_REPO"
echo "✅ chezmoi initialized"
echo ""

# 5. Apply dotfiles
echo "📝 Applying dotfiles..."
chezmoi apply
echo "✅ Dotfiles applied"
echo ""

# 6. Run the Homebrew setup (optional)
if [[ -f "$(chezmoi source-path)/run_once_after_setup-macos.sh" ]]; then
    echo "📦 Install Homebrew packages?"
    read -p "This will install all packages from Brewfile (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bash "$(chezmoi source-path)/run_once_after_setup-macos.sh"
    fi
fi

echo ""
echo "🎉 Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  - Restart your terminal to load new configs"
echo "  - On work machines: create ~/.Brewfile.work for work packages"
