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

### Automated Setup (macOS Only)

When you run `chezmoi init --apply` on a new machine, it will automatically:
1. Install Homebrew (if not already installed)
2. Create `~/Brewfile` with all packages
3. **Prompt you to install all packages** from the Brewfile

The setup script (`run_once_after_setup-macos.sh.tmpl`) runs automatically once and handles everything.

### Manual Setup or Re-sync

To manually run the setup or sync packages on an existing machine:

```bash
# Re-run the complete setup
cd $(chezmoi source-path) && bash run_once_after_setup-macos.sh.tmpl

# Or use brew bundle directly for quick syncing
brew bundle --global
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

### Common Tasks

```bash
# Sync packages from Brewfile
brew bundle --global

# Update Brewfile after installing new packages manually
brew bundle dump --force --global

# Find packages not in Brewfile (cleanup candidates)
brew bundle cleanup --global

# Remove packages not in Brewfile
brew bundle cleanup --force --global
```

### Syncing Across Machines

1. **New machine**: Run `chezmoi init --apply <github-username>` - setup runs automatically
2. **Existing machine**: Run `chezmoi apply` to update Brewfile, then `brew bundle --global` to sync
3. **Keep in sync**: Regularly run `brew bundle --global` on all machines

### Best Practices

1. **After installing new packages**: Run `brew bundle dump --force --global` to update your Brewfile
2. **Regular syncing**: Run `brew bundle --global` periodically to keep machines in sync
3. **Cleanup**: Use `brew bundle cleanup --global` to find unused packages
4. **Keep it organized**: The Brewfile has comments and categories - try to maintain them when adding packages manually

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
