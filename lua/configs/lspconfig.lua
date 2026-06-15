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
  r_language_server = {},
}

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end

-- setup diagnostics
vim.diagnostic.config { virtual_text = false }

--- ====================================================================
--- R SHIELD: Defends Neovim 0.12 Core from R's Userdata Signature Bug
--- ====================================================================
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- ONLY patch the R language server, keeping all other LSPs pristine
    if client and client.name == "r_language_server" then
      if client._signature_patched then
        return
      end
      client._signature_patched = true

      local orig_request = client.request
      client.request = function(self, method, params, handler, bufnr)
        if method == "textDocument/signatureHelp" then
          local orig_handler = handler

          -- Wrap the underlying callback right before Neovim core loops it
          handler = function(err, result, ctx, config)
            if result and type(result) == "table" then
              -- Force swap glitchy userdata fields into standard Lua empty tables
              if not result.signatures or type(result.signatures) ~= "table" then
                result.signatures = {}
              end
            end

            if orig_handler then
              return orig_handler(err, result, ctx, config)
            end
          end
        end
        return orig_request(self, method, params, handler, bufnr)
      end
    end
  end,
})
