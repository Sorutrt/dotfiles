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
  {'numToStr/Comment.nvim'}, -- Toggle comment
  {'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = {'lua', 'javascript', 'typescript', 'cpp' }, -- language parser
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
local term_opts = { slient = true }

local keymap = vim.api.nvim_set_keymap

-- Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
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
require("which-key").add({
  { "<leader>s", ":e $MYVIMRC<CR>", desc = "Settings", mode = "n" }, -- open Settings
  { "<leader>r", ":source $MYVIMRC<CR>", desc = "Reload settings", mode = "n" }, -- Reload settings
  { "<leader>t", ":NvimTreeToggle<CR>", desc = "Toggle file tree", mode = "n" },
  { "<leader>j", ":JetpackSync<CR>", desc = "JetpackSync", mode = "n" },
  { "<leader>w", ":w<CR>", desc = "save file", mode = "n" },
  { "<leader>q", ":q<CR>", desc = "quit", mode = "n"}
})
