local map = vim.keymap.set
local opts = { noremap = true, slient = true }

map('i', 'jk', '<ESC>', { desc = "Exit Insert Mode" })

-- Window
-- - Move
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-Down>", "<C-w>j", { desc = "Go to Up Window", remap = true })
map("n", "<C-Up>", "<C-w>k", { desc = "Go to Down Window", remap = true })
map("n", "<C-Right>", "<C-w>l", { desc = "Go to Right Window", remap = true })
-- - Change Size
map("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })
map("n", "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
