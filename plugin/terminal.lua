local term_bufnr = nil
local term_winid = nil
local term_width = 80
local term_height = 20

local function center_float_opts(width, height)
	local ui = vim.api.nvim_list_uis()[1]
	local col = math.floor((ui.width - width) / 2)
	local row = math.floor((ui.height - height) / 2)
	return {
		relative = "editor",
		width = width,
		height = height,
		col = col,
		row = row,
		style = "minimal",
	}
end

local function toggle_terminal()
	if term_winid and vim.api.nvim_win_is_valid(term_winid) then
		vim.api.nvim_win_close(term_winid, true)
		term_winid = nil
		return
	end

	if term_bufnr and vim.api.nvim_buf_is_valid(term_bufnr) then
		-- Reuse existing terminal buffer
		term_winid = vim.api.nvim_open_win(term_bufnr, true, center_float_opts(term_width, term_height))
		vim.cmd("startinsert")
	else
		-- Create new terminal buffer
		term_bufnr = vim.api.nvim_create_buf(false, true)
		term_winid = vim.api.nvim_open_win(term_bufnr, true, center_float_opts(term_width, term_height))
		vim.api.nvim_set_option_value("buflisted", false, { buf = term_bufnr })
		vim.fn.jobstart(vim.o.shell, { term = true })
		vim.cmd("startinsert")
	end
end

vim.api.nvim_create_autocmd("TermOpen", {
	callback = function()
		vim.keymap.set("t", "<esc>", [[<C-\><C-n>]])
		vim.keymap.set("n", "q", function()
			local curr_buf = vim.api.nvim_get_current_buf()
			if vim.bo[curr_buf].buftype == "terminal" then
				vim.api.nvim_win_close(0, true)
			end
		end, { buffer = true })
	end,
})
vim.keymap.set({ "n", "t" }, "<C-/>", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-_>", toggle_terminal, { desc = "Toggle terminal" })
