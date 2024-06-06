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

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

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

-- windows
map("n", "<leader>q", "<cmd>confirm q<cr>", { desc = "Delete Window", remap = true })
map("n", "<leader>Q", "<cmd>confirm qall<cr>", { desc = "Delete Window", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })

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
map("n", "<leader>w", "<cmd>w<cr><esc>", { desc = "Save File" })

-- lazy
map("n", "<leader>L", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- neo-tree
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "NeoTree" })

-- telescope
map("n", "<leader>ff", "<cmd>Telescope git_files<cr>", { desc = "Find Git Files" })
map("n", "<leader>fF", "<cmd>Telescope find_files<cr>", { desc = "Find All Files" })
map("n", "<leader>fw", "<cmd>Telescope live_grep<cr>", { desc = "Live Grep" })

-- lsp
map("n", "gS", function()
	vim.lsp.buf.signature_help()
end, { desc = "Show function signature help" })
map("n", "<leader>li", "<cmd>LspInfo<cr>", { desc = "LSP Info" })
map("n", "<leader>lR", "<cmd>LspRestart<cr>", { desc = "LSP Restart" })
map("n", "<leader>la", function()
	vim.lsp.buf.code_action()
end, { desc = "LSP Action" })
map("n", "<leader>lf", function()
	vim.lsp.buf.format()
end, { desc = "Format Code" })
map("n", "<leader>lr", function()
	vim.lsp.buf.format()
end, { desc = "Rename Symbol" })

-- comment
map("n", "<leader>/", function()
	return require("Comment.api").call("toggle.linewise." .. (vim.v.count == 0 and "current" or "count_repeat"), "g@$")()
end, { silent = true, expr = true, desc = "Toggle Comment Line" })
map(
	"x",
	"<leader>/",
	"<Esc><Cmd>lua require('Comment.api').locked('toggle.linewise')(vim.fn.visualmode())<CR>",
	{ desc = "Toggle comment for selection" }
)

-- terminal
map("n", "<C-`>", "<cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "ToggleTerm horizontal split" })
map("t", "<C-`>", "<cmd>ToggleTerm size=10 direction=horizontal<CR>", { desc = "ToggleTerm horizontal split" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window", remap = true })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window", remap = true })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window", remap = true })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window", remap = true })
