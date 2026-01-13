return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.json = { "biome" }
      opts.formatters_by_ft.yaml = { "prettier" }
      opts.formatters = opts.formatters or {}
      opts.formatters.biome = {
        env = { BIOME_CONFIG_PATH = os.getenv("HOME") .. "/.config/biome" },
        args = { "format", "--stdin-file-path", "$FILENAME" },
      }
      return opts
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prettier",
        "biome",
      },
    },
  },
}
