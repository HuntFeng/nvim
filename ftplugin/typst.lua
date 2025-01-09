vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.typ",
	callback = function()
		local file = vim.fn.expand("%")
		vim.fn.system("typstyle -i " .. file)
		vim.cmd("edit!")
	end,
})
