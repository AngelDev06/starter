require "nvchad.autocmds"
local autocmd = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("Folding", { clear = true })

autocmd("FileType", {
  group = group,
  callback = function()
    if vim.bo.filetype ~= "python" then
      vim.defer_fn(function()
        vim.opt_local.foldmethod = "expr"
        vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
      end, 10)
    end
  end,
})
