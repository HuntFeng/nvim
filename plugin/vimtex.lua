-- These globals must be set before vimtex is added, as its plugin scripts
-- read them when Neovim activates the package. Install neovim-remote for nvr.
vim.g.vimtex_compiler_method = "tectonic"
vim.g.vimtex_compiler_tectonic = {
	executable = "tectonic",
	callback = 1,
	options = { "--synctex" },
}
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.vimtex_view_general_viewer = "sioyek"
vim.g.vimtex_view_general_options = string.format(
	'--inverse-search="nvr --servername %s +%%2 %%1" --forward-search-file @tex --forward-search-line @line @pdf',
	vim.v.servername
)

vim.pack.add({ "https://github.com/lervag/vimtex" })

vim.opt.spell = true
vim.opt.spelllang = "en_us"
