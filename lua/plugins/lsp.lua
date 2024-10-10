return {
  -- NOTE: Treesitter provides text highlighting for code
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")
      config.setup({
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      { "neovim/nvim-lspconfig" }, -- Required
      {
        "williamboman/mason.nvim",
        build = function()
          pcall(vim.cmd, "MasonUpdate")
        end,
      },
      { "williamboman/mason-lspconfig.nvim" }, -- Optional
      { "hrsh7th/nvim-cmp" },                  -- Required
      { "hrsh7th/cmp-nvim-lsp" },              -- Required
      {
        "L3MON4D3/LuaSnip",
        dependencies = {
          "saadparwaiz1/cmp_luasnip",
          "rafamadriz/friendly-snippets",
        },
      },
      { "rafamadriz/friendly-snippets" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
    },
    config = function()
      local lsp = require("lsp-zero")
      lsp.on_attach(function(client, bufnr)
        local opts = { buffer = bufnr, remap = false }
        vim.keymap.set("n", "gr", function()
          vim.lsp.buf.references()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP Goto Reference" }))
        vim.keymap.set("n", "gd", function()
          vim.lsp.buf.definition()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP Goto Definition" }))
        vim.keymap.set("n", "K", function()
          vim.lsp.buf.hover()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP Hover" }))
        vim.keymap.set("n", "<leader>cd", function()
          vim.diagnostic.setloclist()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP Show Diagnostics" }))
        vim.keymap.set("n", "<leader>ca", function()
          vim.lsp.buf.code_action()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP Code Action" }))
        vim.keymap.set("n", "<leader>cr", function()
          vim.lsp.buf.references()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP References" }))
        vim.keymap.set("n", "<leader>cR", function()
          vim.lsp.buf.rename()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP Rename" }))
        vim.keymap.set("i", "<C-h>", function()
          vim.lsp.buf.signature_help()
        end, vim.tbl_deep_extend("force", opts, { desc = "LSP Signature Help" }))
      end)
      require("mason").setup({
        ui = {
          icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
          },
        },
        ensure_installed = {},
      })
      require("mason-lspconfig").setup({
        ensure_installed = {
          "eslint",
          "lua_ls",
          "svelte",
          "tailwindcss",
          "cssls",
          "clangd",
          "gopls",
          "cssls",
          "rust_analyzer",
          "ts_ls",
        },
        handlers = {
          lsp.default_setup,
          lua_ls = function()
            local lua_opts = lsp.nvim_lua_ls()
            require("lspconfig").lua_ls.setup(lua_opts)
          end,
        },
      })

      local cmp_action = require("lsp-zero").cmp_action()
      local cmp = require("cmp")
      local cmp_select = { behavior = cmp.SelectBehavior.Select }
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip", keyword_length = 2 },
          { name = "buffer",  keyword_length = 3 },
          { name = "path" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
          ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-f>"] = cmp_action.luasnip_jump_forward(),
          ["<C-b>"] = cmp_action.luasnip_jump_backward(),
          ["<Tab>"] = cmp_action.luasnip_supertab(),
          ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),
        }),
      })
    end,
  },
}
