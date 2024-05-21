local function close_neo_tree_if_single_window()
	local total_windows = #vim.api.nvim_tabpage_list_wins(0)
	if total_windows <= 1 then
		local bufnr = vim.api.nvim_get_current_buf()
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		if string.match(bufname, "neo%-tree") then
			vim.cmd("q")
		end
	end
end

-- Autocommand to trigger the function on certain events
vim.api.nvim_create_autocmd({ "BufEnter", "WinClosed" }, {
	pattern = "*",
	callback = close_neo_tree_if_single_window,
})
