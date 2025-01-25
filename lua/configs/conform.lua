local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    python = {
      "ruff_format",
      "ruff_organize_imports",
      "black"
    },
    c = { "clang-format" },
    cpp = { "clang-format" },
    cmake = { "cmake_format" }
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
  format_on_save = { timeout_ms = 5000 },
  formatters = {
    shfmt = {
      prepend_args = { "-i", "2" }
    }
  }
}

return options
