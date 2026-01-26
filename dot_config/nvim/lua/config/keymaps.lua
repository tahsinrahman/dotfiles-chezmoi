-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Window navigation (since C-hjkl=arrows, A-hjkl=aerospace)
-- Tab cycles between windows (explorer <-> editor)
vim.keymap.set("n", "<Tab>", "<C-w>w", { desc = "Next window" })
