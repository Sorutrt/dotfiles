-- Packer.nvim v2
vim.cmd('packadd vim-jetpack')
require('jetpack.packer').add {
  {'tani/vim-jetpack'}, -- bootstrap
  'https://github.com/dense-analysis/ale',
  'junegunn/fzf.vim',
  {'junegunn/fzf', run = 'call fzf#install()' },
  {'neoclide/coc.nvim', branch = 'release'},
  {'neoclide/coc.nvim', branch = 'master', run = 'yarn install --frozen-lockfile'},
  {'vlime/vlime', rtp = 'vim' },
  {'sainnhe/everforest'}, -- colorscheme
  {'vim-airline/vim-airline'},
  {'tpope/vim-fireplace', ft = 'clojure' },
  {'Yggdroot/indentLine'},
  {'nvim-tree/nvim-web-devicons'}, -- file icons
  {'lewis6991/gitsigns.nvim'}, -- git status icons
  {'romgrk/barbar.nvim'}, -- tabline <- buffer
  {'nvim-tree/nvim-tree.lua'}, -- filer
  {'shellRaining/hlchunk.nvim'}, -- indent guide
  {'folke/which-key.nvim'}, -- keybind guide
  {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = {'lua', 'javascript', 'typescript' }, -- language parser
        highlight = { enable = true }
      }
    end
  }
}

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

-- wsl2 clipboard
vim.opt.clipboard = 'unnamedplus'
if vim.fn.has("wsl") then
  vim.g.clipboard = {
    name = "win32yank-wsl",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf"
    },
    paste = {
      ["+"] = "win32yank.exe -o --crlf",
      ["*"] = "win32yank.exe -o --crlf"
    },
    cache_enable = 0,
  }
end

-- ~~ colorscheme: everforest ~~
vim.g.everforest_background = 'hard'
vim.g.everforest_better_performance = 1
vim.g.everforest_cursor = 'red'
vim.cmd('colorscheme everforest')

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


-- ========================================
-- Keybindings
-- ========================================
local opts = { noremap = true, silent = true }
local term_opts = { slient = true }

local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ~~ Normal Mode ~~
keymap("n", "<leader>s", ":e $MYVIMRC<CR>", opts) -- open Settings
keymap("n", "<leader>r", ":source $MYVIMRC<CR>", opts) -- Reload settings

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
