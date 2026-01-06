return {
  {
    "petertriho/nvim-scrollbar",
    event = "BufReadPost",
    config = function()
      local colors = require("tokyonight.colors").setup()
      require("scrollbar").setup({
        show_in_active_only = true,
        handle = {
          color = colors.bg_highlight,
        },
        marks = {
          Search = { color = colors.orange },
          Error = { color = colors.error },
          Warn = { color = colors.warning },
          Info = { color = colors.info },
          Hint = { color = colors.hint },
        },
        handlers = {
          diagnostic = true,
          search = true,
          gitsigns = true,
        },
      })
    end,
  },
}
