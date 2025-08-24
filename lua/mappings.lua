require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<space>", "za", { desc = "toggle folding" })
map("n", "<leader>qf", function()
  vim.lsp.buf.code_action {
    filter = function(a)
      return a.isPreferred
    end,
    apply = true,
  }
end, { noremap = true, silent = true, desc = "Action apply quick fix" })
map(
  "n",
  "<leader>qa",
  vim.lsp.buf.code_action,
  { noremap = true, silent = true, desc = "Action show code action menu" }
)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
