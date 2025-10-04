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
map(
  "n",
  "<leader>fr",
  ":Telescope lsp_references<CR>",
  { noremap = true, silent = true, desc = "telescope find references" }
)
map(
  "n",
  "<leader>fw",
  ":Telescope grep_string<CR>",
  { noremap = true, silent = true, desc = "telescope search word under cursor" }
)
map(
  "n",
  "<leader>fg",
  ":Telescope live_grep<CR>",
  { noremap = true, silent = true, desc = "telescope live grep in project" }
)

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
