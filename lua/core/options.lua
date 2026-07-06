local opt = vim.opt
opt.clipboard = vim.env.SSH_TTY and "" or "unnamedplus"
opt.number = true
opt.relativenumber = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.linebreak = true -- wrap line after word
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
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
opt.swapfile = false -- disable swapfile
opt.cursorline = true -- highlight cursoe line
-- opt.pumborder = "single"
-- opt.completeopt = "fuzzy,menuone,popup,noselect"
-- opt.autocomplete = true
-- opt.complete = "o"
--
-- vim.api.nvim_create_autocmd("ColorScheme", {
-- 	callback = function()
-- 		local colors = require("tokyonight.colors.night")
-- 		vim.api.nvim_set_hl(0, "Pmenu", {
-- 			bg = "NONE",
-- 		})
-- 		vim.api.nvim_set_hl(0, "PmenuSel", {
-- 			bg = colors.bg_highlight,
-- 			fg = colors.fg,
-- 		})
-- 		vim.api.nvim_set_hl(0, "PmenuMatch", {
-- 			fg = colors.blue,
-- 			bold = true,
-- 		})
-- 	end,
-- })

function _G.find_file(cmd_arg)
	local cmd = "fd -t f -H -E '.git/**' ."
	if vim.trim(cmd_arg) ~= "" then
		cmd = cmd .. " | fzf --filter " .. cmd_arg
	end
	local files = vim.fn.systemlist(cmd)
	return files
end

vim.o.findfunc = "v:lua.find_file"
opt.grepprg =
	"rg --vimgrep --no-heading --smart-case --glob '!.git/*' --glob '!node_modules/*' --glob '!venv/*' --glob '!.*/*'"
