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

# Add Homebrew to PATH for current session
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add to shell RC files if not already present
for rc_file in ~/.bashrc ~/.zshrc; do
    if ! grep -q "brew shellenv" "$rc_file" 2>/dev/null; then
        echo "" >> "$rc_file"
        echo "# Homebrew" >> "$rc_file"
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$rc_file"
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

# 4. Create chezmoi config (if not exists)
if [[ ! -f ~/.config/chezmoi/chezmoi.toml ]]; then
    echo "⚙️  Creating chezmoi config..."
    echo ""
    read -p "Enter your name: " user_name
    read -p "Enter your email: " user_email
    echo ""
    read -p "Is this a work machine? (y/N): " is_work_input

    # Normalize input to lowercase and default to 'n'
    is_work_input="${is_work_input:-n}"
    is_work_input=$(echo "$is_work_input" | tr '[:upper:]' '[:lower:]')

    if [[ "$is_work_input" == "y" || "$is_work_input" == "yes" ]]; then
        is_work="true"
        echo "🏢 Setting up as WORK machine"
        echo ""
        read -p "Enter your GitLab domain (e.g., gitlab.company.com): " gitlab_domain
        read -p "Enter your GitLab personal access token: " gitlab_token
        echo ""
    else
        is_work="false"
        echo "🏠 Setting up as PERSONAL machine"
        echo ""
    fi

    mkdir -p ~/.config/chezmoi

    # Create base config
    cat > ~/.config/chezmoi/chezmoi.toml <<EOF
[data.machine]
    is_work = $is_work

[data.git]
    email = "$user_email"
    name = "$user_name"
EOF

    # Add work-specific config if this is a work machine
    if [[ "$is_work" == "true" ]]; then
        cat >> ~/.config/chezmoi/chezmoi.toml <<EOF
    gitlab_domain = "$gitlab_domain"
    token = "$gitlab_token"
EOF
    fi

    echo "✅ chezmoi config created"
else
    echo "✅ chezmoi config already exists"
    # Read existing is_work setting
    is_work=$(grep -A 1 "^\[data\.machine\]" ~/.config/chezmoi/chezmoi.toml | grep "is_work" | sed 's/.*= *//')
fi
echo ""

# 5. Initialize chezmoi with dotfiles repo (if not already done)
if [[ ! -d ~/.local/share/chezmoi/.git ]]; then
    echo "📂 Initialize chezmoi..."
    DOTFILES_REPO="git@github.com:tahsinrahman/dotfiles-chezmoi.git"
    chezmoi init "$DOTFILES_REPO"
    echo "✅ chezmoi initialized"
else
    echo "✅ chezmoi already initialized"
fi
echo ""

# 6. Apply dotfiles
echo "📝 Applying dotfiles..."
chezmoi apply -v
echo "✅ Dotfiles applied"
echo ""

# 7. Install Homebrew packages from Brewfile
echo "📦 Installing Homebrew packages..."
brew bundle --global
echo "✅ Packages installed"

echo ""
echo "Note: Work machine setup (if configured) will run automatically during 'chezmoi apply'"
echo ""
echo "🎉 Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  - Restart your terminal to load new configs"
