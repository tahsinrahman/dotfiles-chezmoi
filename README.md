# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

### New Machine Setup

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <your-github-username>

# Or if repo is already cloned
chezmoi init --apply ~/.local/share/chezmoi
```

### Configure Machine-Specific Data

Create `~/.config/chezmoi/chezmoi.toml`:

**Work Machine:**
```toml
[data.machine]
    is_work = true

[data.git]
    email = "work@example.com"
    name = "Your Name"

[data.git.credential]
    token = "your-gitlab-token"

[data.claude]
    bedrock_url = "https://your-internal-gateway/claude"
    auth_token = "your-auth-token"
```

**Personal Machine:**
```toml
[data.machine]
    is_work = false

[data.git]
    email = "personal@example.com"
    name = "Your Name"
```

### Create Work-Specific Files (Work Machines Only)

**SSH Config** (`~/.ssh/config.work`):
```ssh
Host *.internal.company.com
    ProxyCommand ssh-proxy -h=%h
```

**Git Config** (`~/.gitconfig.work`):
```gitconfig
[url "git@gitlab.company.com:"]
    insteadOf = https://gitlab.company.com

[credential]
    helper = "!f() { echo \"password=YOUR_TOKEN\"; }; f"
```

## Daily Usage

### View Changes
```bash
chezmoi diff
```

### Apply Changes
```bash
chezmoi apply
```

### Add New Dotfile
```bash
chezmoi add ~/.newconfig
```

### Update Existing File
Edit locally, then:
```bash
chezmoi re-add
```

### Commit Changes
```bash
cd ~/.local/share/chezmoi
git add .
git commit -m "description"
git push
```

## What's Included

- **Shell**: Fish, Tmux
- **Terminal**: Alacritty
- **Development**: Git, SSH
- **macOS**: AeroSpace, Karabiner
- **Tools**: Topgrade, Claude Code
- **Package Management**: Homebrew Bundle with comprehensive Brewfile

## Homebrew Bundle Management

This dotfiles repository includes a comprehensive Brewfile that manages all CLI tools, GUI applications, and Mac App Store apps using Homebrew Bundle.

### Initial Setup (macOS Only)

When you run `chezmoi init --apply`, it will automatically:
1. Install Homebrew (if not already installed)
2. Create `~/Brewfile` with all packages
3. Set up helper scripts for package management

### Install/Update All Packages

To install or update all packages from the Brewfile:

```bash
# Option 1: Run the sync script (recommended)
cd $(chezmoi source-path) && ./scripts/brew-sync.sh

# Option 2: Use brew bundle directly
brew bundle --global  # or: brew bundle --file ~/Brewfile
```

The sync script provides:
- Summary of packages to be installed
- Interactive confirmation
- Optional cleanup of old versions
- Colored output with progress

### Update Brewfile After Installing New Packages

After manually installing new packages with `brew install` or `brew install --cask`, update your Brewfile:

```bash
cd $(chezmoi source-path) && ./scripts/brew-update-brewfile.sh
```

**Note:** The auto-generated Brewfile will be plain and lose the current organization/comments. Consider manually adding new packages to keep the organized structure.

### Managing Packages

```bash
# Check what's in the Brewfile
brew bundle list --global

# Find packages not in Brewfile (cleanup candidates)
brew bundle cleanup --global

# Remove packages not in Brewfile
brew bundle cleanup --force --global

# Check if Brewfile is satisfied
brew bundle check --global
```

### What's in the Brewfile?

The Brewfile includes **250+ packages** organized into categories:
- **Custom Taps**: 5 additional repositories
- **Development Tools**: Go, Rust, Python, Node.js, Java + language-specific tooling
- **Kubernetes/Cloud**: kubectl, helm, argocd, istio, minikube, k9s, and more
- **System Utilities**: Modern CLI tools (bat, ripgrep, fd, fzf, etc.)
- **Media Tools**: FFmpeg with codecs, ImageMagick, video/audio processing
- **Security Tools**: GPG, SSH utilities, certificate management
- **GUI Applications**: Development tools, browsers, communication apps (60+ apps)
- **Mac App Store**: AdGuard, PowerPoint, Okta Verify, and more

### Syncing Across Machines

1. **New machine**: Run `chezmoi init --apply` - Brewfile will be created and you can choose to install packages
2. **Existing machine**: Run `chezmoi apply` to update Brewfile, then `brew bundle --global` to sync packages
3. **Keep machines in sync**: Regularly run the sync script or `brew bundle --global`

### Best Practices

1. **Keep Brewfile in version control**: Already done - it's in your chezmoi repo
2. **Regular updates**: Run `brew bundle --global` periodically to keep packages in sync
3. **Remove old packages**: Use `brew bundle cleanup` to find packages not in your Brewfile
4. **Manual package installation**: After `brew install foo`, remember to update the Brewfile

## Platform Support

- **macOS**: Full support
- **Linux**: Platform-specific paths handled automatically

## Security

Sensitive data is stored in `~/.config/chezmoi/chezmoi.toml` (NOT committed):
- Git tokens
- Claude API tokens
- Work-specific credentials

Work-specific configs stored locally (NOT committed):
- `~/.ssh/config.work`
- `~/.gitconfig.work`
