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
		border = "rounded",
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
		vim.api.nvim_buf_set_option(term_bufnr, "buflisted", false)
		vim.fn.termopen(vim.o.shell)
		vim.cmd("startinsert")
	end
end

vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]])
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]])
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]])
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]])
vim.keymap.set({ "n", "t" }, "<C-/>", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set({ "n", "t" }, "<C-_>", toggle_terminal, { desc = "Toggle terminal" })
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]])
vim.keymap.set("n", "q", "<cmd>bd!<cr>")
