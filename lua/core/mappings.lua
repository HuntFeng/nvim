vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
local map = vim.keymap.set

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map("n", "[[", "#")
map("n", "]]", "*")

-- Move to window using the <ctrl>+hjkl keys
map({ "n", "t" }, "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window", remap = true })
map({ "n", "t" }, "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window", remap = true })
map({ "n", "t" }, "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window", remap = true })
map({ "n", "t" }, "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window", remap = true })

-- move cursor in insert mode using <ctrl>+hjkl
map("i", "<C-h>", "<Left>", { desc = "Move Cursor Left", remap = true })
map("i", "<C-j>", "<Down>", { desc = "Move Cursor Down", remap = true })
map("i", "<C-k>", "<Up>", { desc = "Move Cursor Up", remap = true })
map("i", "<C-l>", "<Right>", { desc = "Move Cursor Right", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<cr>", "o<esc>", { desc = "New line" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>c", "<cmd>confirm bd<cr>", { desc = "Close Buffer" })
-- use tab to open buffer list in telescope
map("n", "<Tab>", function()
	require("telescope.builtin").buffers()
end, { desc = "Buffers" })
-- use number keys 1 to 5 to navigate between buffers
for num = 1, 5 do
	map("n", tostring(num), function()
		local buffers = vim.api.nvim_list_bufs()
		if num > 0 and num <= #buffers then
			local buffer_handle = buffers[num]
			vim.api.nvim_set_current_buf(buffer_handle)
		end
	end, { noremap = true, silent = true })
end

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
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })

-- terminal
map({ "n", "t" }, "<C-`>", "<cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "ToggleTerm horizontal split" })
