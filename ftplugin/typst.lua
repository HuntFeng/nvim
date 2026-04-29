vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = "*.typ",
	callback = function()
		local file = vim.fn.expand("%")
		vim.fn.system("typstyle -i " .. file)
		vim.cmd("edit!")
	end,
})
