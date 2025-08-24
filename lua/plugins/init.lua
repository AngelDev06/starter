return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>fm",
        function()
          require("conform").format { async = true }
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    opts = function()
      return require "configs.conform"
    end,
    init = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
    end,
    config = function(_, opts)
      require("conform").setup(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "tmhedberg/SimpylFold",
    ft = "python",
  },
  {
    "lewis6991/hover.nvim",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = {
      init = function()
        require "hover.providers.lsp"
        require "hover.providers.diagnostic"
        require "hover.providers.fold_preview"
      end,
      preview_opts = {
        border = "single",
      },
      preview_window = false,
      title = true,
    },
    config = function(_, opts)
      local hover = require "hover"
      hover.setup(opts)
      vim.keymap.set("n", "<leader>hv", hover.hover, { desc = "hover info" })
      vim.api.nvim_create_autocmd({ "CursorHold" }, {
        callback = function()
          if vim.o.updatetime == 50 then
            vim.o.updatetime = 2000
            return
          end
          hover.hover()
        end,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "BufNewFile" },
    opts = function()
      return require "configs.lintconfig"
    end,
    config = function(_, opts)
      local M = {}

      local lint = require "lint"
      for name, linter in pairs(opts.linters) do
        if type(linter) == "table" and type(lint.linters[name]) == "table" then
          lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
          if type(linter.prepend_args) == "table" then
            lint.linters[name].args = lint.linters[name].args or {}
            vim.list_extend(lint.linters[name].args, linter.prepend_args)
          end
        else
          lint.linters[name] = linter
        end
      end
      lint.linters_by_ft = opts.linters_by_ft

      function M.debounce(ms, fn)
        local timer = vim.uv.new_timer()
        return function(...)
          local argv = { ... }
          timer:start(ms, 0, function()
            timer:stop()
            vim.schedule_wrap(fn)(unpack(argv))
          end)
        end
      end

      function M.lint()
        -- Use nvim-lint's logic first:
        -- * checks if linters exist for the full filetype first
        -- * otherwise will split filetype by "." and add all those linters
        -- * this differs from conform.nvim which only uses the first filetype that has a formatter
        local names = lint._resolve_linter_by_ft(vim.bo.filetype)

        -- Create a copy of the names table to avoid modifying the original.
        names = vim.list_extend({}, names)

        -- Add fallback linters.
        if #names == 0 then
          vim.list_extend(names, lint.linters_by_ft["_"] or {})
        end

        -- Add global linters.
        vim.list_extend(names, lint.linters_by_ft["*"] or {})

        -- Filter out linters that don't exist or don't match the condition.
        local ctx = { filename = vim.api.nvim_buf_get_name(0) }
        ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
        names = vim.tbl_filter(function(name)
          local linter = lint.linters[name]
          if not linter then
            LazyVim.warn("Linter not found: " .. name, { title = "nvim-lint" })
          end
          return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
        end, names)

        -- Run linters.
        if #names > 0 then
          lint.try_lint(names)
        end
      end

      vim.api.nvim_create_autocmd(opts.events, {
        group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
        callback = M.debounce(100, M.lint),
      })
    end,
  },
  {
    "Vimjas/vim-python-pep8-indent",
    ft = "python",
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "BufEnter",
    opts = {
      provider_selector = function(bufnr, filetype, buftype)
        local custom_provider = {
          python = true,
        }
        if custom_provider[filetype] then
          return ""
        else
          return "lsp"
        end
      end,
    },
    config = function(_, opts)
      local ufo = require "ufo"
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      vim.o.timeoutlen = 700
      vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "UFO open all folds" })
      vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "UFO close all folds" })
      ufo.setup(opts)
    end,
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "cpp" },
    cmd = { "TSCppDefineClassFunc", "TSCppMakeConcreteClass", "TSCppRuleOf3", "TSCppRuleOf5" },
    keys = {
      {
        mode = { "n", "v" },
        "<leader>dm",
        ":TSCppDefineClassFunc<CR>",
        silent = true,
        desc = "Generate definitions for c++ methods"
      },
    },
    config = true,
  },
  {
    "smoka7/multicursors.nvim",
    event = "VeryLazy",
    dependencies = "nvimtools/hydra.nvim",
    opts = {},
    cmd = { "MCstart", "MCvisual", "MCclear", "MCpattern", "MCvisualPattern", "MCunderCursor" },
    keys = {
      {
        mode = { "n", "v" },
        "<leader>mw",
        ":MCstart<CR>",
        silent = true,
        desc = "Multi-Cursor create selection under word",
      },
      {
        mode = { "n", "v" },
        "<leader>mc",
        ":MCunderCursor<CR>",
        silent = true,
        desc = "Multi-Cursor create selection under cursor",
      },
      {
        mode = { "n", "v" },
        "<leader>mv",
        ":MCvisual<CR>",
        silent = true,
        desc = "Multi-Cursor create selection from last visual",
      },
    },
  },
  -- load luasnips + cmp related in insert mode only
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      {
        -- snippet plugin
        "L3MON4D3/LuaSnip",
        dependencies = "rafamadriz/friendly-snippets",
        opts = { history = true, updateevents = "TextChanged,TextChangedI" },
        config = function(_, opts)
          require("luasnip").config.set_config(opts)
          require "nvchad.configs.luasnip"
        end,
      },

      -- autopairing of (){}[] etc
      {
        "windwp/nvim-autopairs",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          local npairs = require "nvim-autopairs"
          local Rule = require "nvim-autopairs.rule"
          npairs.setup(opts)

          npairs.add_rules {
            Rule("/*", "*/", { "c", "cpp" }):replace_map_cr(function()
              return "<C-g>u<CR><CR><C-u><Up><end><space>"
            end),
          }

          -- setup cmp for autopairs
          local cmp_autopairs = require "nvim-autopairs.completion.cmp"
          require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
        end,
      },

      -- cmp sources plugins
      {
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-nvim-lsp-signature-help",
      },
    },
    opts = function()
      return require "configs.cmp"
    end,
    config = function(_, opts)
      require("cmp").setup(opts)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSBufEnable", "TSBufDisable", "TSModuleInfo" },
    build = ":TSUpdate",
    opts = function()
      return require "configs.treesitter"
    end,
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
