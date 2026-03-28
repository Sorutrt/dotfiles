vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.cmd('packadd vim-jetpack')
require('jetpack.packer').add {
  { 'tani/vim-jetpack' },
  { 'sainnhe/everforest' },
  {
    'nvim-tree/nvim-web-devicons',
    cmd = {
      'NvimTreeOpen',
      'NvimTreeClose',
      'NvimTreeToggle',
      'NvimTreeFocus',
      'NvimTreeFindFile',
    },
  },
  {
    'nvim-tree/nvim-tree.lua',
    cmd = {
      'NvimTreeOpen',
      'NvimTreeClose',
      'NvimTreeToggle',
      'NvimTreeFocus',
      'NvimTreeFindFile',
    },
    config = function()
      require('nvim-tree').setup({
        renderer = {
          group_empty = true,
        },
        update_focused_file = {
          enable = true,
          update_root = false,
        },
        view = {
          width = 32,
        },
      })
    end,
  },
}

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.encoding = 'utf-8'
vim.opt.fileencoding = 'utf-8'
vim.opt.backup = false
vim.opt.title = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true

vim.g.everforest_background = 'hard'
vim.g.everforest_better_performance = 1
vim.g.everforest_cursor = 'red'
vim.cmd('colorscheme everforest')

local opts = { noremap = true, silent = true }

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', opts)

vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)
vim.keymap.set('n', 'x', '"_x', opts)
vim.keymap.set('n', '<leader>t', '<Cmd>NvimTreeToggle<CR>', opts)
vim.keymap.set('n', '<leader>s', '<Cmd>edit $MYVIMRC<CR>', opts)
vim.keymap.set('n', '<leader>r', '<Cmd>source $MYVIMRC<CR>', opts)
vim.keymap.set('n', '<leader>j', '<Cmd>JetpackSync<CR>', opts)
vim.keymap.set('n', '<leader>w', '<Cmd>write<CR>', opts)
vim.keymap.set('n', '<leader>q', '<Cmd>quit<CR>', opts)
vim.keymap.set('i', 'jk', '<Esc>', opts)
