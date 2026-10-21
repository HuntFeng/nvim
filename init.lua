require("vim._core.ui2").enable()

vim.opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.linebreak = true -- wrap line after word
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = "yes" -- always show signcolumn for lsp diags
vim.opt.showtabline = 2 -- show tab line
vim.opt.laststatus = 3 -- show global status line only
vim.opt.showtabline = 0 -- hide tab line
vim.opt.exrc = true -- enable exrc
vim.opt.splitright = true
vim.opt.foldmethod = "indent" -- fold by indent
vim.opt.foldcolumn = "0" -- hide fold column
vim.opt.foldlevelstart = 99 -- open all folds by default
vim.opt.foldenable = true -- enable folding
vim.opt.winborder = "single" -- border for floating windows
vim.opt.swapfile = false -- disable swapfile
vim.opt.cursorline = true -- highlight cursoe line

-- highlight yanked text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 300 })
	end,
})
vim.opt.grepprg = "rg --vimgrep --smart-case"

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- autopairs
-- vim.keymap.set("i", "(", "()<Left>")
-- vim.keymap.set("i", "[", "[]<Left>")
-- vim.keymap.set("i", "{", "{}<Left>")
-- vim.keymap.set("i", "<", "<><Left>")
-- vim.keymap.set("i", '"', '""<Left>')
-- vim.keymap.set("i", "'", "''<Left>")
-- vim.keymap.set("i", "`", "``<Left>")
-- vim.keymap.set("i", "$", "$$<Left>")
-- vim.keymap.set("i", "/*", "/**/<Left>")

-- better escape
vim.keymap.set("i", "jk", "<esc>l", { silent = true })
vim.keymap.set("i", "jj", "<esc>l", { silent = true })

-- better up/down
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
-- vim.api.nvim_create_autocmd("FileType", {
--   callback = function()
--     vim.keymap.set("n", "[[", "#", { buffer = true })
--     vim.keymap.set("n", "]]", "*", { buffer = true })
--   end,
-- })
vim.keymap.set("v", "K", ":m '<-2<CR>gv-gv", { desc = "Move selection up" })
vim.keymap.set("v", "J", ":m '>+1<CR>gv-gv", { desc = "Move selection down" })
vim.keymap.set("v", "H", "<gv", { desc = "Move selection left" })
vim.keymap.set("v", "L", ">gv", { desc = "Move selection right" })

-- Move to window using the <ctrl>+hjkl keys
vim.keymap.set("n", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window", remap = true })
vim.keymap.set("n", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window", remap = true })
vim.keymap.set("n", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window", remap = true })
vim.keymap.set("n", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Move Lines
vim.keymap.set("n", "<cr>", function()
	if vim.bo.filetype == "qf" then
		vim.api.nvim_input("<C-cr>")
	else
		vim.cmd("normal! o")
	end
end, { desc = "New line" })

-- buffers
vim.keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
vim.keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
-- vim.keymap.set("n", "<tab>", ":buffer ", { desc = "Buffer" })
vim.keymap.set("n", "<leader>c", "<cmd>confirm bdelete<cr>", { desc = "Close Buffer", remap = true })
vim.keymap.set("n", "<leader>bd", ":%bd|e#|bd#<CR>", { desc = "Close all buffers except current" })

-- windows
vim.keymap.set("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Delete Window", remap = true })
vim.keymap.set("n", "<leader>Q", "<cmd>confirm qall<cr>", { desc = "Delete Window", remap = true })
vim.keymap.set("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })
vim.keymap.set("n", "-", "<C-W>s", { desc = "Split Window Below", remap = true })
vim.keymap.set("n", "|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- Clear search with <esc>
vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and Clear hlsearch" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
-- vim.keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
-- vim.keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- vim.keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
-- vim.keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
-- vim.keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
-- vim.keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- save file
vim.keymap.set({ "x", "n", "s" }, "<leader>w", "<cmd>w<cr>", { desc = "Save File" })

-- wrap
vim.keymap.set({ "n", "i", "x", "s" }, "<A-z>", "<cmd>set wrap!<cr>", { desc = "Wrap text" })

-- comment
vim.keymap.set("n", "<leader>/", function()
	vim.cmd.normal("gcc")
end, { desc = "Comment", noremap = true })
vim.keymap.set("v", "<leader>/", function()
	vim.cmd.normal("gc")
end, { desc = "Comment", noremap = true })
