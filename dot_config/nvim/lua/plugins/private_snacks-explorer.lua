return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      replace_netrw = true,
    },
    picker = {
      sources = {
        files = {
          hidden = true,
        },
        explorer = {
          hidden = true,
          auto_close = false,
          win = {
            list = {
              keys = {
                ["<Tab>"] = {
                  function()
                    -- Find editor window (non-explorer, non-floating)
                    for _, win in ipairs(vim.api.nvim_list_wins()) do
                      local cfg = vim.api.nvim_win_get_config(win)
                      if cfg.relative == "" then
                        local buf = vim.api.nvim_win_get_buf(win)
                        local ft = vim.bo[buf].filetype
                        if ft ~= "snacks_picker_list" and ft ~= "snacks_picker_input" and ft ~= "snacks_layout_box" then
                          vim.api.nvim_set_current_win(win)
                          return
                        end
                      end
                    end
                  end,
                  desc = "Switch to editor",
                },
              },
            },
            input = {
              keys = {
                ["<Tab>"] = false,
              },
            },
          },
        },
      },
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        Snacks.explorer()
      end,
    })

    -- Quit when only explorer window remains
    vim.api.nvim_create_autocmd("WinEnter", {
      callback = function()
        local dominated_by_explorer = true
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          local cfg = vim.api.nvim_win_get_config(win)
          if cfg.relative == "" then -- not floating
            local buf = vim.api.nvim_win_get_buf(win)
            local ft = vim.bo[buf].filetype
            if ft ~= "snacks_picker_list" and ft ~= "snacks_layout_box" and ft ~= "" then
              dominated_by_explorer = false
              break
            end
          end
        end
        if dominated_by_explorer then
          vim.cmd("qa")
        end
      end,
    })
  end,
}
