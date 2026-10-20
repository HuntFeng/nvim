-- Serve snippets from <config>/snippets/<filetype>.lua (a `{ prefix = body }` table)
-- through 'completefunc', so they show up in the builtin (auto)completion menu
-- via the "F" source in 'complete'.

local cache = {} -- filetype -> { prefix = body }
local start_col -- 0-based column where the completed prefix starts

local function load(ft)
	if not cache[ft] then
		local path = vim.fn.stdpath("config") .. "/snippets/" .. ft .. ".lua"
		local ok, snippets = pcall(dofile, path)
		cache[ft] = ok and snippets or {}
	end
	return cache[ft]
end

-- global so the completefunc option string can reference it
function _G.snippet_complete(findstart, base)
	if findstart == 1 then
		local line = vim.api.nvim_get_current_line():sub(1, vim.fn.col(".") - 1)
		-- include a leading backslash so `\frac` is replaced as a whole (LaTeX)
		start_col = vim.fn.match(line, [[\\\?\k*$]])
		return start_col
	end
	base = base:gsub("^\\", "")
	local items = {}
	for prefix, body in pairs(load(vim.bo.filetype)) do
		if base == "" or #vim.fn.matchfuzzy({ prefix }, base) > 0 then
			table.insert(items, { word = prefix, kind = "Snippet", info = body, user_data = { snippet = body } })
		end
	end
	return items
end

vim.opt.pumborder = "single"
vim.opt.completeopt = "fuzzy,menuone,popup,noselect"
vim.opt.autocomplete = true
vim.opt.complete = "o,F"
vim.o.completefunc = "v:lua.snippet_complete"

-- 'pumborder' only covers the menu; give the info popup a matching border
vim.api.nvim_create_autocmd("CompleteChanged", {
	callback = function()
		local winid = vim.fn.complete_info({ "selected" }).preview_winid
		if winid and vim.api.nvim_win_is_valid(winid) then
			vim.api.nvim_win_set_config(winid, { border = vim.o.pumborder })
		end
	end,
})

vim.api.nvim_create_autocmd("CompleteDone", {
	callback = function()
		local item = vim.v.completed_item
		local body = type(item.user_data) == "table" and item.user_data.snippet
		if not body or vim.v.event.reason ~= "accept" then
			return
		end
		-- replace the inserted prefix with the expanded snippet
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, col, {})
		vim.api.nvim_win_set_cursor(0, { row, start_col })
		vim.snippet.expand(body)
	end,
})

vim.api.nvim_create_user_command("SnippetsReload", function()
	cache = {}
end, { desc = "Reload snippets from disk" })
