vim.api.nvim_create_autocmd("BufWritePost", {
	pattern = "*.typ",
	callback = function()
		local file = vim.fn.expand("%")
		vim.fn.system("typstyle -i " .. file)
		-- refresh the buffer if the file has been modified externally
		vim.cmd("checktime")
	end,
})
