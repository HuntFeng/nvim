-- highlight yanked text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "Search", timeout = 300 })
	end,
})
