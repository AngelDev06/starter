local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = {
      "ruff_format",
      "ruff_organize_imports",
      "black",
    },
    c = { "clang-format" },
    cpp = { "clang-format" },
    cmake = { "cmake_format" },
    r = { "styler", timeout_ms = 15000 },
  },
  default_format_opts = {
    lsp_format = "fallback",
    timeout_ms = 5000,
  },
  format_on_save = {},
  formatters = {
    shfmt = {
      prepend_args = { "-i", "2" },
    },
  },
}

return options
