-- highlight yanked text on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "Visual", timeout = 300 })
	end,
})

-- quickfix list preview
vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		local qf_preview_win_id = -1
		local ns_id = vim.api.nvim_create_namespace("qf_highlight")

		vim.api.nvim_create_autocmd("CursorMoved", {
			buffer = 0,
			callback = function()
				local idx = vim.fn.line(".")
				local qf_entry = vim.fn.getqflist({ idx = idx, items = 1 }).items[1]
				if not vim.api.nvim_win_is_valid(qf_preview_win_id) then
					qf_preview_win_id = vim.api.nvim_open_win(qf_entry.bufnr, false, {
						relative = "win",
						win = 0,
						anchor = "SW",
						width = vim.api.nvim_win_get_width(0),
						height = vim.api.nvim_win_get_height(0) * 0.8,
						col = 0,
						row = 0,
					})
				end
				vim.fn.bufload(vim.fn.bufname(qf_entry.bufnr))
				vim.api.nvim_win_set_buf(qf_preview_win_id, qf_entry.bufnr)
				vim.api.nvim_win_set_cursor(qf_preview_win_id, { qf_entry.lnum, qf_entry.col })
				vim.api.nvim_set_option_value("number", true, { win = qf_preview_win_id })
				vim.api.nvim_buf_clear_namespace(qf_entry.bufnr, ns_id, 0, -1)
				vim.hl.range(qf_entry.bufnr, ns_id, "Visual", { qf_entry.lnum - 1, 0 }, { qf_entry.lnum - 1, -1 })
			end,
		})

		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = 0,
			callback = function()
				if qf_preview_win_id > -1 then
					local idx = vim.fn.line(".")
					local qf_entry = vim.fn.getqflist({ idx = idx, items = 1 }).items[1]
					vim.api.nvim_buf_clear_namespace(qf_entry.bufnr, ns_id, 0, -1)
					vim.api.nvim_win_close(qf_preview_win_id, true)
					qf_preview_win_id = -1
				end
			end,
		})
	end,
})
