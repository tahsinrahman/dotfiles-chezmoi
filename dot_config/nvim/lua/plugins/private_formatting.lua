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
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prettier",
      },
    },
  },
}
