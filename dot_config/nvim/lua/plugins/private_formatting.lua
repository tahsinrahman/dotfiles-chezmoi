return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        json = { "prettier" },
        yaml = { "prettier" },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "prettier",
      },
    },
  },
}
