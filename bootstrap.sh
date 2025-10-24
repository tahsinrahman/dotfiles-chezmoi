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
    else
        is_work="false"
        echo "🏠 Setting up as PERSONAL machine"
    fi
    echo ""

    mkdir -p ~/.config/chezmoi
    cat > ~/.config/chezmoi/chezmoi.toml <<EOF
[data.machine]
    is_work = $is_work

[data.git]
    email = "$user_email"
    name = "$user_name"
EOF
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

# 8. Work machine specific setup
if [[ "$is_work" == "true" ]]; then
    echo "🏢 Work Machine Setup"
    echo "====================="
    echo ""

    # 8a. Setup ~/.gitconfig.work
    if [[ ! -f ~/.gitconfig.work ]]; then
        echo "⚙️  Setting up work Git configuration..."
        echo ""
        echo "📋 Example template available at:"
        echo "   ~/.local/share/chezmoi/.gitconfig.work.example"
        echo ""
        read -p "Enter your GitLab domain (e.g., gitlab.company.com): " gitlab_domain
        read -p "Enter your GitLab personal access token: " gitlab_token
        echo ""

        cat > ~/.gitconfig.work <<EOF
[url "git@${gitlab_domain}:"]
	insteadOf = https://${gitlab_domain}

[credential]
	helper = "!f() { sleep 1; echo \"username=token\"; echo \"password=${gitlab_token}\"; }; f"
EOF
        chmod 600 ~/.gitconfig.work
        echo "✅ ~/.gitconfig.work created"
    else
        echo "✅ ~/.gitconfig.work already exists"
    fi
    echo ""

    # 8b. Setup ~/.ssh/config.work
    if [[ ! -f ~/.ssh/config.work ]]; then
        echo "⚙️  Setting up work SSH configuration..."
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
        echo "✅ ~/.ssh/config.work created"
    else
        echo "✅ ~/.ssh/config.work already exists"
    fi
    echo ""

    # 8c. Setup ~/.Brewfile.work
    if [[ ! -f ~/.Brewfile.work ]]; then
        echo "⚙️  Setting up work Brewfile..."
        echo ""
        echo "📋 Copying example template..."

        if [[ -f ~/.local/share/chezmoi/Brewfile.work.example ]]; then
            cp ~/.local/share/chezmoi/Brewfile.work.example ~/.Brewfile.work
            echo "✅ ~/.Brewfile.work created from template"
            echo ""
            echo "📝 Please edit ~/.Brewfile.work to add your work-specific packages"

            read -p "Do you want to edit ~/.Brewfile.work now? (y/N): " edit_brewfile
            if [[ "$edit_brewfile" =~ ^[Yy] ]]; then
                ${EDITOR:-nano} ~/.Brewfile.work
            fi
        else
            touch ~/.Brewfile.work
            echo "✅ ~/.Brewfile.work created (empty)"
        fi
        echo ""

        # Ask if they want to install work packages now
        read -p "Install work packages from ~/.Brewfile.work? (y/N): " install_work
        if [[ "$install_work" =~ ^[Yy] ]]; then
            echo "📦 Installing work packages..."
            brew bundle --file=~/.Brewfile.work
            echo "✅ Work packages installed"
        else
            echo "⏭️  Skipping work package installation"
            echo "   Run 'brew bundle --file=~/.Brewfile.work' later to install"
        fi
    else
        echo "✅ ~/.Brewfile.work already exists"
        echo ""
        read -p "Update work packages from ~/.Brewfile.work? (y/N): " update_work
        if [[ "$update_work" =~ ^[Yy] ]]; then
            echo "📦 Updating work packages..."
            brew bundle --file=~/.Brewfile.work
            echo "✅ Work packages updated"
        fi
    fi
    echo ""

    echo "🎉 Work machine setup complete!"
    echo ""
    echo "📝 Work-specific files created:"
    echo "   - ~/.gitconfig.work (Git credentials & URL rewrites)"
    echo "   - ~/.ssh/config.work (SSH proxy configurations)"
    echo "   - ~/.Brewfile.work (Work-specific packages)"
    echo ""
fi

echo ""
echo "🎉 Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  - Restart your terminal to load new configs"
