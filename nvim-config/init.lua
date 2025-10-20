require("maxence")
vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)
vim.opt.number = true
vim.opt.relativenumber = true

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct).
-- This is also a good place to setup other settings (vim.opt)

local plugins = {
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "nvim-telescope/telescope.nvim", tag = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' } },
  { "nvim-treesitter/nvim-treesitter", branch = 'master', lazy = false, build = ":TSUpdate" },
  { "numToStr/Comment.nvim", opts = {} },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  -- Auto-completion plugins
  { "hrsh7th/nvim-cmp" },          -- Core completion plugin
  { "hrsh7th/cmp-nvim-lsp" },      -- LSP source for nvim-cmp
  { "hrsh7th/cmp-buffer" },        -- Buffer completions
  { "hrsh7th/cmp-path" },          -- Path completions
  { "saadparwaiz1/cmp_luasnip" },  -- Snippet completions
  { "L3MON4D3/LuaSnip" },          -- Snippet engine
{
  "tpope/vim-fugitive",
  cmd = { "Git", "Gdiffsplit", "Gvdiffsplit", "Gstatus", "Gblame" },
  keys = {
    { "<leader>gs", ":Git<CR>", desc = "Git status" },
    { "<leader>gd", ":Gdiffsplit<CR>", desc = "Git diff split" },
    { "<leader>gb", ":Gblame<CR>", desc = "Git blame" },
  },
}

}

local opts = {}

-- Setup lazy.nvim
require("lazy").setup(plugins, opts)
-- Mason
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "pyright", "ts_ls", "lua_ls", "jdtls", "omnisharp"}, -- LSP à installer automatiquement
})
local lspconfig = require("lspconfig")

-- Lua LSP (utile pour Neovim config)
lspconfig.lua_ls.setup({
    settings = {
        Lua = {
            diagnostics = { globals = { "vim" } }, -- éviter les warnings sur vim
        },
    },
})

-- Python
lspconfig.pyright.setup({})

-- JavaScript / TypeScript
lspconfig.ts_ls.setup({})

-- Exemple pour Java
-- lspconfig.jdtls.setup({})
local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }, {
    { name = "buffer" },
  })
})

-- LSP capabilities for nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lspconfig = require("lspconfig")

-- Example for Python
lspconfig.pyright.setup({
  capabilities = capabilities,
})
-- Example for Lua
lspconfig.lua_ls.setup({
  capabilities = capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
    },
  },
})


lspconfig.omnisharp.setup{
    cmd = { "~/.local/share/nvim/mason/bin/omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
}

--telescope
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})

local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "java", "python", "javascript", "typescript"},
  sync_isntall = false,
  highlight = { enable = true },
  indent = { enable = true },
})


local opts = { noremap=true, silent=true }

require("catppuccin").setup()
vim.cmd.colorscheme "catppuccin"
