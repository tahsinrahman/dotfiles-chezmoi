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

- **AeroSpace (`dot_aerospace.toml`)**: macOS-only window manager configuration

## Development Guidelines

### Adding New Dotfiles

1. Add the file: `chezmoi add ~/.newconfig`
2. Verify: `chezmoi diff`
3. Commit changes: `git add . && git commit -m "add: new config"`

### Making Files Platform-Specific

To make a file apply only to specific platforms:

1. Add to `.chezmoiignore` with conditional logic
2. Test with `chezmoi apply --dry-run` on different systems

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
