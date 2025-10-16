# CLAUDE.md - Chezmoi Dotfiles Repository

This repository manages dotfiles using [chezmoi](https://www.chezmoi.io/), a tool for managing configuration files across multiple machines.

## Repository Purpose

This is a personal dotfiles repository that synchronizes configuration files across different systems (macOS, Linux, etc.) while handling platform-specific differences.

## Working with Chezmoi

### Key Concepts

- **Source directory**: `~/.local/share/chezmoi` (this repository)
- **Destination directory**: `~` (your home directory)
- **File naming convention**: `dot_` prefix becomes `.` (e.g., `dot_aerospace.toml` → `~/.aerospace.toml`)

### Common Commands

```bash
# Add a file to chezmoi management
chezmoi add ~/.configfile

# See what changes would be applied
chezmoi diff

# Apply changes from source to destination
chezmoi apply

# Edit a file in chezmoi
chezmoi edit ~/.configfile

# Check chezmoi status
chezmoi status

# Verify configuration
chezmoi doctor
```

## Platform-Specific Files

### Using .chezmoiignore

The `.chezmoiignore` file uses templates to conditionally exclude files based on the operating system:

```
{{ if ne .chezmoi.os "darwin" }}
dot_aerospace.toml
{{ end }}
```

This pattern means: "If the OS is NOT darwin (macOS), ignore this file."

### Platform Detection

Chezmoi provides these OS identifiers:
- `darwin` - macOS
- `linux` - Linux
- `windows` - Windows

### Current Platform-Specific Configurations

- **AeroSpace (`dot_aerospace.toml`)**: macOS-only window manager configuration (entire file excluded on Linux via `.chezmoiignore`)
- **Fish init (`dot_config/fish/conf.d/init.fish.tmpl`)**: Contains macOS-specific Homebrew paths that are conditionally included only on macOS

## Development Guidelines

### Adding New Dotfiles

1. Add the file: `chezmoi add ~/.newconfig`
2. Verify: `chezmoi diff`
3. Commit changes: `git add . && git commit -m "add: new config"`

### Making Files Platform-Specific

**Method 1: Exclude entire files with .chezmoiignore**

To exclude entire files on specific platforms, use `.chezmoiignore`:

```
{{- if ne .chezmoi.os "darwin" }}
.aerospace.toml
{{- end }}
```

Note: Patterns in `.chezmoiignore` match target paths (destination), not source paths.

**Method 2: Platform-specific content within files (Templates)**

To include platform-specific lines within a file, add it as a template:

```bash
# Add file as template
chezmoi add --template ~/.config/fish/conf.d/init.fish
```

Then edit the template to add conditional logic:

```fish
{{- if eq .chezmoi.os "darwin" }}
set -gx PATH /opt/homebrew/bin $PATH
set -gx PATH /opt/homebrew/sbin $PATH
{{- end }}
```

The `{{- }}` syntax trims whitespace, preventing empty lines on other platforms.

**Testing templates:**

```bash
# Preview what the file will look like
chezmoi cat ~/.config/fish/conf.d/init.fish

# Test with dry-run
chezmoi apply --dry-run --verbose
```

### Managing Sensitive Data with Templates

**Important**: Never commit sensitive data (tokens, passwords, API keys) to the repository. Use chezmoi's data file to store private information.

**Configuration File Location**: `~/.config/chezmoi/chezmoi.toml`

This file is stored **outside** the chezmoi source directory and is **not committed to git**.

**Example: Storing Git credentials**

1. Create the data file `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.git]
    email = "your.email@example.com"
    name = "Your Name"

[data.git.credential]
    token = "your-secret-token-here"
```

2. Reference the data in your template files using `{{ .variableName }}`:

```gitconfig
# In dot_gitconfig.tmpl
[user]
    email = {{ .git.email }}
    name = {{ .git.name }}

[credential]
    helper = "!f() { echo \"password={{ .git.credential.token }}\"; }; f"
```

3. Preview the rendered template:

```bash
chezmoi cat ~/.gitconfig
```

**Machine-specific configurations:**

You can conditionally include configuration blocks based on machine type (work vs. personal):

1. Add a machine identifier to `~/.config/chezmoi/chezmoi.toml`:

```toml
[data.machine]
    is_work = true

[data.git]
    email = "your.email@example.com"
    name = "Your Name"

[data.git.credential]
    token = "your-work-token"
```

2. Use conditionals in your templates:

```gitconfig
# In dot_gitconfig.tmpl
[user]
    email = {{ .git.email }}
    name = {{ .git.name }}

{{- if .machine.is_work }}
[credential]
    helper = "!f() { echo \"password={{ .git.credential.token }}\"; }; f"
{{- end }}
```

On personal machines, set `is_work = false` in chezmoi.toml and the credential block won't be included.

**External work-specific configs (not committed):**

For configurations containing sensitive work information (internal domains, IPs, credentials, etc.) that should never be committed to version control, use include directives with external files:

**SSH Config Example:**

```ssh-config
# In private_dot_ssh/private_config.tmpl
Include ~/.orbstack/ssh/config
Include ~/.ssh/config.work

Host github.com
 HostName ssh.github.com
 Port 443
```

Create work file locally (NOT managed by chezmoi):
```bash
# ~/.ssh/config.work
Host *.internal.company.com
 ProxyCommand ssh-proxy -h=%h
```

**Git Config Example:**

```gitconfig
# In dot_gitconfig.tmpl
[user]
    email = {{ .git.email }}
    name = {{ .git.name }}

[include]
    path = ~/.gitconfig.work
```

Create work file locally (NOT managed by chezmoi):
```bash
# ~/.gitconfig.work
[url "git@gitlab.company.com:"]
    insteadOf = https://gitlab.company.com

[credential]
    helper = "!f() { echo \"password=YOUR_TOKEN\"; }; f"
```

On personal machines, simply don't create the work config files - both SSH and Git will silently skip missing include files.

**Setting up on a new machine:**

1. Clone and initialize chezmoi: `chezmoi init <your-repo-url>`
2. Create `~/.config/chezmoi/chezmoi.toml` with your machine-specific data
3. Apply configs: `chezmoi apply`
4. *Work machines only:* Create work-specific configs:
   - `~/.ssh/config.work` - Work SSH hosts
   - `~/.gitconfig.work` - Work Git URL rewrites and credentials

**Files currently using templates:**
- `dot_gitconfig.tmpl` - Git configuration with external work includes
- `private_dot_ssh/private_config.tmpl` - SSH config with external work includes
- `dot_config/fish/conf.d/init.fish.tmpl` - Fish shell with platform-specific paths

### Testing Changes

Before applying changes:
```bash
# See what would change
chezmoi diff

# Dry run (no actual changes)
chezmoi apply --dry-run --verbose
```

## File Structure

```
.
├── .chezmoiignore          # Platform-specific file exclusions
├── dot_aerospace.toml      # AeroSpace window manager (macOS only)
├── dot_config/             # ~/.config directory contents
└── .claude/                # Claude Code project configuration
    ├── CLAUDE.md           # This file
    └── settings.local.json # Local Claude settings
```

## Maintenance

### Syncing Across Machines

1. **Push changes**: `git push`
2. **Pull on another machine**: `git pull && chezmoi apply`

### Reviewing Platform Differences

Use `chezmoi doctor` to verify configuration and see detected platform information.
