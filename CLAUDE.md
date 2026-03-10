# Chezmoi Dotfiles Repository

Manages dotfiles with [chezmoi](https://www.chezmoi.io/) across macOS and Linux.

## Bootstrap (New Machine)

```bash
git clone git@github.com:tahsinrahman/dotfiles-chezmoi.git ~/dotfiles-temp
cd ~/dotfiles-temp
bash bootstrap.sh
```

Bootstrap installs Homebrew, chezmoi, generates SSH key, creates chezmoi config (work vs personal), applies dotfiles, and installs packages.

## Work vs Personal Machines

Config lives in `~/.config/chezmoi/chezmoi.toml` (NOT committed to git).

```toml
[data.machine]
    is_work = true

[data.git]
    email = "your.email@example.com"
    name = "Your Name"
    gitlab_domain = "gitlab.company.com"
    token = "your-gitlab-pat"

[data.openai]
    api_key = "your-openai-api-key"
```

Work machines get: GitLab URL rewriting and credentials in gitconfig, `~/.ssh/config.work`, `~/.Brewfile.work`, and OpenAI env vars (`OPENAI_API_KEY`, `OPENAI_BASE_URL`) in Fish shell.

## Template Files

- `dot_gitconfig.tmpl` — Git config with conditional work sections
- `private_dot_ssh/private_config.tmpl` — SSH config with work includes
- `dot_config/fish/conf.d/init.fish.tmpl` — Fish shell with platform-specific paths
- `run_once_after_10-check-work-configs.sh` — Automatic work config checker

## Platform-Specific Files

- `dot_aerospace.toml` — macOS-only (excluded on Linux via `.chezmoiignore`)
- Fish init template — conditionally includes Homebrew paths on macOS

## File Structure

```
.
├── .chezmoiignore          # Platform-specific file exclusions
├── dot_aerospace.toml      # AeroSpace window manager (macOS only)
├── dot_config/             # ~/.config directory contents
└── .claude/                # Claude Code project configuration
```
