local opt = vim.opt
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.linebreak = true -- wrap line after word
opt.expandtab = true
opt.autoindent = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes" -- always show signcolumn for lsp diags
opt.showtabline = 2 -- show tab line
opt.laststatus = 3 -- show global status line only
-- opt.laststatus = 0 -- hide status line
opt.cmdheight = 0 -- hide cmdline
if vim.g.vscode then
	opt.cmdheight = 1
end
