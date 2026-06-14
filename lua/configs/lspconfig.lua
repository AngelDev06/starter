-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local servers = {
  html = {},
  cssls = {},
  pyright = {
    filetypes = { "python" },
  },
  clangd = {},
  cmake = {
    init_options = {
      buildDirectory = "out/build",
    },
  },
}

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end

-- setup diagnostics
vim.diagnostic.config { virtual_text = false }
