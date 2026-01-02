# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Framework

This is a LazyVim-based Neovim configuration. LazyVim provides sensible defaults and a plugin ecosystem - see https://lazyvim.github.io/ for documentation.

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

## Adding/Modifying Plugins

Create or edit files in `lua/plugins/`. Each file returns a table of plugin specs:

```lua
return {
  {
    "plugin/name",
    opts = { ... },  -- Merges with existing config
  },
}
```

To disable a LazyVim plugin: `{ "plugin/name", enabled = false }`

To override opts entirely, use `opts = function() return { ... } end`

## LazyVim Defaults

- Options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
- Keymaps: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
- Autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

## Lua Formatting

Uses stylua with 2-space indentation and 120 column width (see stylua.toml).
