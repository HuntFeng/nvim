local function goto_function(next)
	local parser = vim.treesitter.get_parser(0, "lua")
	local tree = parser:parse()[1]
	local root = tree:root()

	local row = vim.api.nvim_win_get_cursor(0)[1] - 1

	local target

	local function walk(node)
		if node:type() == "function_declaration" or node:type() == "function_definition" then
			local sr = node:range()

			if next then
				if sr > row and (not target or sr < target) then
					target = sr
				end
			else
				if sr < row and (not target or sr > target) then
					target = sr
				end
			end
		end

		for child in node:iter_children() do
			walk(child)
		end
	end

	walk(root)

	if target then
		vim.api.nvim_win_set_cursor(0, { target + 1, 0 })
	end
end

vim.keymap.set("n", "]m", function()
	goto_function(true)
end)

vim.keymap.set("n", "[m", function()
	goto_function(false)
end)
