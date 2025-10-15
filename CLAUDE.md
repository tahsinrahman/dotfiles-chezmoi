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
