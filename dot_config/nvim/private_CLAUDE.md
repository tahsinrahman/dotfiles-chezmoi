# Neovim Configuration

LazyVim-based Neovim config. See https://lazyvim.github.io/ for framework docs.

## Architecture

```
lua/
├── config/           # Core configuration (extends LazyVim defaults)
│   ├── lazy.lua     # Plugin manager bootstrap
│   ├── options.lua  # Vim options
│   ├── keymaps.lua  # Key mappings
│   └── autocmds.lua # Autocommands
└── plugins/         # Plugin specs (auto-loaded by lazy.nvim)
```

## Formatting

Uses stylua with 2-space indentation and 120 column width (see stylua.toml).
