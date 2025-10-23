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

## Homebrew Bundle

Packages managed via Brewfile.

### Setup

New machine: `chezmoi init --apply` (auto-installs Homebrew and packages)

### Work-Specific Packages

For work-only packages, create `~/.Brewfile.work` (NOT committed):
```bash
cp $(chezmoi source-path)/Brewfile.work.example ~/.Brewfile.work
# Edit and add work packages
```

Setup script installs from both files automatically.

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
