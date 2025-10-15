local brackets = {
	["'"] = "'",
	['"'] = '"',
	["("] = ")",
	["["] = "]",
	["{"] = "}",
	["`"] = "`",
	["$"] = "$",
	["```"] = "```",
}

local function is_closing_char_valid()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2] + 1
	local next_char = line:sub(col, col)
	local is_closing_char = vim.tbl_contains(brackets, next_char)
	return next_char == "" or next_char == " " or next_char == "\t" or is_closing_char
end

local function handle_pair(opener)
	if is_closing_char_valid() then
		if opener == "```" then
			return "``````\x1bhhi"
		else
			return opener .. brackets[opener] .. "\x1bi"
		end
	end
	return opener
end

for opener, _ in pairs(brackets) do
	vim.keymap.set("i", opener, function()
		return handle_pair(opener)
	end, { expr = true, noremap = true })
end
