-- ========================================
-- Jetpack Setup (shellslash より前に実行する必要あり)
-- ========================================
vim.cmd('packadd vim-jetpack')
local jetpack = require('jetpack')

jetpack.begin()

jetpack.add("tani/vim-jetpack")
jetpack.add('dense-analysis/ale')
jetpack.add('junegunn/fzf.vim')
jetpack.add('junegunn/fzf', { ['do'] = function() vim.fn['fzf#install']() end })
jetpack.add('neoclide/coc.nvim', { branch = 'release' })
jetpack.add('rebelot/kanagawa.nvim')
jetpack.add('Yggdroot/indentLine')
jetpack.add('nvim-tree/nvim-web-devicons')
jetpack.add('echasnovski/mini.icons')
jetpack.add('romgrk/barbar.nvim')
jetpack.add('lewis6991/gitsigns.nvim')
jetpack.add('folke/which-key.nvim')
jetpack.add('numToStr/Comment.nvim')
jetpack.add('nvim-tree/nvim-tree.lua')
jetpack.add('shellRaining/hlchunk.nvim')

jetpack.add('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

jetpack['end']()

-- ========================================
-- Windows / Path 対策 (E65 エラー回避)
-- ========================================
-- shellslash を有効にすると、Vim/Neovim 内部でパスのバックスラッシュが
-- スラッシュに変換され、正規表現でのバックリファレンスエラーを回避できます
if vim.fn.has('win32') == 1 then
  vim.opt.shellslash = true

  -- JetpackSync は shellslash と相性が悪いため、一時的に無効化するラッパー
  vim.api.nvim_create_user_command('JetpackSyncWin', function()
    vim.opt.shellslash = false
    vim.cmd('JetpackSync')
    vim.opt.shellslash = true
  end, {})
end

-- ========================================
-- options
-- ========================================
-- ~~ Normal options ~~
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.opt.backup = false
vim.opt.title = true
vim.opt.number = true -- Line number
vim.opt.wrap = false -- Do not turn around long line

-- ~~ Visual options ~~
vim.opt.cursorline = true

-- indent
vim.opt.tabstop = 2 -- show
vim.opt.shiftwidth = 2 -- indent
vim.opt.showtabline = 2 -- 
vim.opt.smartindent = true -- auto indent
vim.opt.expandtab = true -- expand tab to space

-- search
vim.opt.ignorecase = true -- case-insensitive when search
vim.opt.smartcase = true -- Kensakuni Oomoji arutokiha kubetu seehende
vim.opt.hlsearch = true

-- colorscheme
vim.cmd('colorscheme kanagawa')

-- ~~ filer: nvim-tree.lua ~~
-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

require("nvim-tree").setup()

-- indent guide
require("hlchunk").setup({
  chunk = { enable = true },
  indent = { enable = true }
})

-- Toggle comment
require("Comment").setup()

-- coc-pairs / Better <CR>
vim.keymap.set('i', '<CR>', function()
  return vim.fn.pumvisible() == 1 and vim.fn['coc#_select_confirm']() or vim.api.nvim_replace_termcodes("<C-g>u<CR><c-r>=coc#on_enter()<CR>", true, true, true)
end, { noremap = true, expr = true, silent = true })


-- ========================================
-- Keybindings
-- ========================================
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
vim.g.mapleader = " "
keymap("", "<Space>", "<Nop>", opts)
vim.g.maplocalleader = " "

-- ~~ Normal Mode ~~
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "x", '"_x', opts) -- Do not yank with x

-- Move tab to previous/next
keymap("n", "<C-[>", "<Cmd>BufferPrevious<CR>", opts)
keymap("n", "<C-]>", "<Cmd>BufferNext<CR>", opts)

keymap("n", "<leader>t", ":NvimTreeToggle<CR>", opts) -- Toggle file tree

-- ~~ Insert Mode ~~
keymap("i", "jk", "<ESC>", opts)
-- <TAB> to auto completion
vim.keymap.set("i", "<TAB>", 'coc#pum#visible() ? coc#pum#next(1) : "<Tab>"', { noremap = true, silent = true, expr = true, replace_keycodes = false })
vim.keymap.set("i", "<S-TAB>", [[coc#pum#visible() ? coc#pum#prev(1) : "<C-h>"]], { noremap = true, silent = true, expr = true, replace_keycodes = false })


-- ~~ Which-key ~~
local wk = require("which-key")
wk.add({
  { "<leader>s", ":e $MYVIMRC<CR>", desc = "Settings" },
  { "<leader>r", ":source $MYVIMRC<CR>", desc = "Reload settings" },
  { "<leader>t", ":NvimTreeToggle<CR>", desc = "Toggle file tree" },
  { "<leader>j", ":JetpackSyncWin<CR>", desc = "JetpackSync" },
  { "<leader>w", ":w<CR>", desc = "Save file" },
  { "<leader>q", ":q<CR>", desc = "Quit" },
})

