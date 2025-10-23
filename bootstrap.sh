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
    echo "✅ Homebrew installed"
fi

# Add Homebrew to PATH (idempotent)
if [[ $(uname -m) == "arm64" ]]; then
    BREW_PATH="/opt/homebrew/bin/brew"
else
    BREW_PATH="/usr/local/bin/brew"
fi

# Eval for current session
eval "$($BREW_PATH shellenv)"

# Add to shell RC files if not already present
for rc_file in ~/.bashrc ~/.zshrc; do
    if [[ -f "$rc_file" ]] && ! grep -q "brew shellenv" "$rc_file"; then
        echo "" >> "$rc_file"
        echo "# Homebrew" >> "$rc_file"
        echo "eval \"\$($BREW_PATH shellenv)\"" >> "$rc_file"
        echo "✅ Added Homebrew to $rc_file"
    fi
done

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

# 4. Create chezmoi config
echo "⚙️  Creating chezmoi config..."
echo ""
read -p "Enter your name: " user_name
read -p "Enter your email: " user_email
echo ""

mkdir -p ~/.config/chezmoi
cat > ~/.config/chezmoi/chezmoi.toml <<EOF
[data.machine]
    is_work = false

[data.git]
    email = "$user_email"
    name = "$user_name"
EOF
echo "✅ chezmoi config created"
echo ""

# 5. Initialize chezmoi with dotfiles repo
echo "📂 Initialize chezmoi..."
DOTFILES_REPO="git@github.com:tahsinrahman/dotfiles-chezmoi.git"

chezmoi init "$DOTFILES_REPO"
echo "✅ chezmoi initialized"
echo ""

# 6. Apply dotfiles
echo "📝 Applying dotfiles..."
chezmoi apply
echo "✅ Dotfiles applied"
echo ""

# 7. Install Homebrew packages from Brewfile
echo "📦 Installing Homebrew packages..."
if [[ -f ~/Brewfile ]]; then
    brew bundle --global
    echo "✅ Packages installed"
else
    echo "⚠️  No Brewfile found, skipping package installation"
fi

echo ""
echo "🎉 Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  - Restart your terminal to load new configs"
echo "  - On work machines: create ~/.Brewfile.work for work packages"
