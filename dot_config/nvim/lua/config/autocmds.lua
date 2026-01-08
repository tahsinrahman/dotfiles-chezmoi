-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto-save after a short delay when text changes
local autosave_timer = nil
vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
  pattern = "*",
  callback = function()
    if autosave_timer then
      autosave_timer:stop()
    end
    autosave_timer = vim.defer_fn(function()
      if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
        vim.cmd("silent! write")
      end
    end, 1000) -- 1 second delay
  end,
  desc = "Auto-save after delay",
})

-- Ensure single newline at end of file (remove multiple trailing newlines)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.bo.modifiable and vim.bo.buftype == "" then
      local save_cursor = vim.fn.getpos(".")
      vim.cmd([[silent! %s/\n\+\%$//e]])
      vim.fn.setpos(".", save_cursor)
    end
  end,
  desc = "Remove multiple trailing newlines",
})

