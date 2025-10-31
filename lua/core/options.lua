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
opt.showtabline = 0 -- hide tab line
opt.cmdheight = 0 -- hide cmdline
opt.exrc = true -- enable exrc
opt.splitright = true
opt.foldmethod = "indent" -- fold by indent
opt.foldcolumn = "0" -- hide fold column
opt.foldlevelstart = 99 -- open all folds by default
opt.foldenable = true -- enable folding
opt.winborder = "single" -- border for floating windows
opt.grepprg =
	"rg --vimgrep --no-heading --smart-case --glob '!.git/*' --glob '!node_modules/*' --glob '!venv/*' --glob '!.*/*'"
vim.cmd([[set path+=**]]) -- able to search subdirs
opt.wildignore = opt.wildignore + {
	"node_modules/*",
	".*/*",
	"build/*",
}
opt.completeopt = "menu,menuone,noselect"
