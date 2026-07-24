vim.g.mapleader = " "
vim.g.maplocalleader = ","
local map = vim.keymap.set

-- autopairs
-- map("i", "(", "()<Left>")
-- map("i", "[", "[]<Left>")
-- map("i", "{", "{}<Left>")
-- map("i", "<", "<><Left>")
-- map("i", '"', '""<Left>')
-- map("i", "'", "''<Left>")
-- map("i", "`", "``<Left>")
-- map("i", "$", "$$<Left>")
-- map("i", "/*", "/**/<Left>")

-- better escape
map("i", "jk", "<esc>l", { silent = true })
map("i", "jj", "<esc>l", { silent = true })

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- vim.api.nvim_create_autocmd("FileType", {
--   callback = function()
--     map("n", "[[", "#", { buffer = true })
--     map("n", "]]", "*", { buffer = true })
--   end,
-- })
map("v", "K", ":m '<-2<CR>gv-gv", { desc = "Move selection up" })
map("v", "J", ":m '>+1<CR>gv-gv", { desc = "Move selection down" })
map("v", "H", "<gv", { desc = "Move selection left" })
map("v", "L", ">gv", { desc = "Move selection right" })

-- Move to window using the <ctrl>+hjkl keys
map("n", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("n", "<cr>", function()
  if vim.bo.filetype == "qf" then
    vim.api.nvim_input("<C-cr>")
  else
    vim.cmd("normal! o")
  end
end, { desc = "New line" })

-- buffers
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
-- map("n", "<tab>", ":buffer ", { desc = "Buffer" })
map("n", "<leader>c", "<cmd>confirm bdelete<cr>", { desc = "Close Buffer", remap = true })
map("n", "<leader>bd", ":%bd|e#|bd#<CR>", { desc = "Close all buffers except current" })

-- windows
map("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Delete Window", remap = true })
map("n", "<leader>Q", "<cmd>confirm qall<cr>", { desc = "Delete Window", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
map("n", "-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
-- map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
-- map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
-- map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
-- map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- save file
map({ "x", "n", "s" }, "<leader>w", "<cmd>w<cr>", { desc = "Save File" })

-- wrap
map({ "n", "i", "x", "s" }, "<A-z>", "<cmd>set wrap!<cr>", { desc = "Wrap text" })

-- comment
map("n", "<leader>/", function()
  vim.cmd.normal("gcc")
end, { desc = "Comment", noremap = true })
map("v", "<leader>/", function()
  vim.cmd.normal("gc")
end, { desc = "Comment", noremap = true })
