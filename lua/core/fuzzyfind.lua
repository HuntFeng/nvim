local config = {
	-- Directories to exclude from search
	exclude_patterns = {
		".git",
		".venv",
		"venv",
		"node_modules",
		"dist",
		"build",
		".next",
		".cache",
		"__pycache__",
		"*.pyc",
		".DS_Store",
		"*.min.js",
		"*.min.css",
		"lazy-lock.json",
		"package-lock.json",
		"yarn.lock",
	},
	-- File types to include for grep (empty means all files)
	grep_include_patterns = {},
	-- Use fd/ripgrep if available
	use_fd = true,
	use_ripgrep = true,
	-- Max results to show
	max_results = 200,
}

-- Store current finder state
local finder_state = {
	mode = nil, -- "file" or "grep"
	buf = nil,
	win = nil,
	results_buf = nil,
	results_win = nil,
	results = {},
	current_query = "",
	selected_idx = 1,
	ns_id = vim.api.nvim_create_namespace("fuzzyfind_results"),
	closing = false,
}

-- Build find command for file search
local function build_find_command(pattern)
	if pattern == "" or pattern == nil then
		pattern = ""
	end

	local cmd
	local has_fd = vim.fn.executable("fd") == 1

	if has_fd and config.use_fd then
		cmd = { "fd", "--type", "f", "--color", "never", "--hidden" }
		for _, exclude in ipairs(config.exclude_patterns) do
			table.insert(cmd, "--exclude")
			table.insert(cmd, exclude)
		end
		if pattern ~= "" then
			table.insert(cmd, pattern)
		end
	else
		cmd = { "find", ".", "-type", "f" }
		for _, exclude in ipairs(config.exclude_patterns) do
			table.insert(cmd, "!")
			table.insert(cmd, "-path")
			table.insert(cmd, "*/" .. exclude .. "/*")
		end
		if pattern ~= "" then
			table.insert(cmd, "-iname")
			table.insert(cmd, "*" .. pattern .. "*")
		end
	end

	return cmd
end

-- Build grep command for text search
local function build_grep_command(pattern)
	if pattern == "" or pattern == nil then
		return nil
	end

	local cmd
	local has_rg = vim.fn.executable("rg") == 1

	if has_rg and config.use_ripgrep then
		cmd = { "rg", "--vimgrep", "--no-heading", "--smart-case" }
		for _, exclude in ipairs(config.exclude_patterns) do
			table.insert(cmd, "--glob")
			table.insert(cmd, "!" .. exclude)
		end
		for _, include in ipairs(config.grep_include_patterns) do
			table.insert(cmd, "--glob")
			table.insert(cmd, include)
		end
		table.insert(cmd, "--")
		table.insert(cmd, pattern)
	else
		cmd = { "grep", "-rn", "--exclude-dir=" .. table.concat(config.exclude_patterns, ","), pattern, "." }
	end

	return cmd
end

-- Simple fuzzy match scoring for file search
local function fuzzy_match(str, pattern)
	if pattern == "" then
		return true, 0
	end

	str = str:lower()
	pattern = pattern:lower()

	local score = 0
	local str_idx = 1
	local pat_idx = 1

	while pat_idx <= #pattern and str_idx <= #str do
		if str:sub(str_idx, str_idx) == pattern:sub(pat_idx, pat_idx) then
			score = score + 1
			pat_idx = pat_idx + 1
		end
		str_idx = str_idx + 1
	end

	if pat_idx <= #pattern then
		return false, 0
	end

	return true, score
end

-- Parse grep output line into structured data
local function parse_grep_line(line)
	local filename, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
	if not filename then
		filename, lnum, text = line:match("^(.+):(%d+):(.*)$")
		col = 1
	end

	if filename and lnum then
		return {
			filename = filename,
			lnum = tonumber(lnum),
			col = tonumber(col) or 1,
			text = text or "",
		}
	end
	return nil
end

-- Find files and return results
local function search_files(pattern)
	local cmd = build_find_command(pattern)
	if not cmd then
		return {}
	end

	local results = {}
	local output = vim.fn.systemlist(cmd)
	local has_fd = vim.fn.executable("fd") == 1

	for _, filepath in ipairs(output) do
		filepath = filepath:gsub("^%./", "")

		if has_fd or pattern == "" then
			table.insert(results, { path = filepath, score = 0 })
		else
			local filename = vim.fn.fnamemodify(filepath, ":t")
			local matches, score = fuzzy_match(filename, pattern)
			if matches then
				table.insert(results, { path = filepath, score = score })
			end
		end

		if #results >= config.max_results then
			break
		end
	end

	table.sort(results, function(a, b)
		if a.score ~= b.score then
			return a.score > b.score
		end
		return a.path < b.path
	end)

	return results
end

-- Search text with grep and return results
local function search_grep(pattern)
	local cmd = build_grep_command(pattern)
	if not cmd then
		return {}
	end

	local results = {}
	local output = vim.fn.systemlist(cmd)

	for _, line in ipairs(output) do
		local parsed = parse_grep_line(line)
		if parsed then
			table.insert(results, parsed)
			if #results >= config.max_results then
				break
			end
		end
	end

	return results
end

-- Format a file search result line for display
local function format_file_result(result, idx, is_selected)
	local filename = vim.fn.fnamemodify(result.path, ":t")
	local dir_path = vim.fn.fnamemodify(result.path, ":h")
	local prefix = is_selected and "❯ " or "  "
	return string.format("%s%s (%s)", prefix, filename, dir_path), filename
end

-- Format a grep result line for display
local function format_grep_result(result, idx, is_selected)
	local filename_only = vim.fn.fnamemodify(result.filename, ":t")
	local dir_path = vim.fn.fnamemodify(result.filename, ":h")
	local text = result.text:gsub("^%s+", ""):gsub("%s+$", "")
	local prefix = is_selected and "❯ " or "  "
	local file_line = string.format("%s%s (%s)", prefix, filename_only, dir_path)
	local text_line = string.format("    %d: %s", result.lnum, text)
	return file_line, text_line, filename_only
end

-- Update the results window with current results
local function update_results_display()
	if not finder_state.results_buf or not vim.api.nvim_buf_is_valid(finder_state.results_buf) then
		return
	end

	local lines = {}
	local line_data = {}

	if finder_state.mode == "file" then
		for i, result in ipairs(finder_state.results) do
			local line, filename = format_file_result(result, i, i == finder_state.selected_idx)
			table.insert(lines, line)
			table.insert(line_data, {
				type = "file",
				line_idx = #lines - 1,
				filename = filename,
				prefix_len = 2,
				result = result,
			})
		end
	elseif finder_state.mode == "grep" then
		for i, result in ipairs(finder_state.results) do
			local file_line, text_line, filename = format_grep_result(result, i, i == finder_state.selected_idx)
			table.insert(lines, file_line)
			table.insert(lines, text_line)
			table.insert(line_data, {
				type = "grep",
				file_line_idx = #lines - 2,
				text_line_idx = #lines - 1,
				filename = filename,
				prefix_len = 2,
				result = result,
			})
		end
	end

	if #lines == 0 then
		lines = { finder_state.mode == "file" and "  No files found" or "  No results found" }
		line_data = {}
	end

	vim.api.nvim_set_option_value("modifiable", true, { buf = finder_state.results_buf })
	vim.api.nvim_buf_set_lines(finder_state.results_buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = finder_state.results_buf })

	-- Clear all highlights
	vim.api.nvim_buf_clear_namespace(finder_state.results_buf, finder_state.ns_id, 0, -1)

	-- Apply highlights
	for i, data in ipairs(line_data) do
		if data.type == "file" then
			local line_idx = data.line_idx
			local line = lines[line_idx + 1]
			local filename_start = data.prefix_len
			local filename_end = filename_start + #data.filename + 2

			-- Highlight selected line background
			if i == finder_state.selected_idx then
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"Visual",
					{ line_idx, 0 },
					{ line_idx, -1 },
					{}
				)
			end

			-- Bold filename
			vim.hl.range(
				finder_state.results_buf,
				finder_state.ns_id,
				"Bold",
				{ line_idx, filename_start },
				{ line_idx, filename_end },
				{}
			)
			vim.hl.range(
				finder_state.results_buf,
				finder_state.ns_id,
				"Directory",
				{ line_idx, filename_start },
				{ line_idx, filename_end },
				{}
			)

			-- Comment style for path
			local path_start = line:find(" %(")
			if path_start then
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"Comment",
					{ line_idx, path_start },
					{ line_idx, -1 },
					{}
				)
			end
		elseif data.type == "grep" then
			local file_line_idx = data.file_line_idx
			local text_line_idx = data.text_line_idx
			local file_line = lines[file_line_idx + 1]
			local text_line = lines[text_line_idx + 1]
			local filename_start = data.prefix_len
			local filename_end = filename_start + #data.filename + 2

			-- Highlight selected line background
			if i == finder_state.selected_idx then
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"Visual",
					{ file_line_idx, 0 },
					{ file_line_idx, -1 },
					{}
				)
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"Visual",
					{ text_line_idx, 0 },
					{ text_line_idx, -1 },
					{}
				)
			end

			-- Bold filename
			vim.hl.range(
				finder_state.results_buf,
				finder_state.ns_id,
				"Bold",
				{ file_line_idx, filename_start },
				{ file_line_idx, filename_end },
				{}
			)
			vim.hl.range(
				finder_state.results_buf,
				finder_state.ns_id,
				"Directory",
				{ file_line_idx, filename_start },
				{ file_line_idx, filename_end },
				{}
			)

			-- Comment style for path
			local path_start = file_line:find(" %(")
			if path_start then
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"Comment",
					{ file_line_idx, path_start },
					{ file_line_idx, -1 },
					{}
				)
			end

			-- Line number style
			if text_line then
				local lnum_end = text_line:find(":")
				if lnum_end then
					vim.hl.range(
						finder_state.results_buf,
						finder_state.ns_id,
						"LineNr",
						{ text_line_idx, 0 },
						{ text_line_idx, lnum_end },
						{}
					)
				end
			end

			-- Highlight matching text
			if finder_state.current_query ~= "" and text_line then
				local query_lower = finder_state.current_query:lower()
				local text_start = (text_line:find(": ") or 0) + 2
				local text_part = text_line:sub(text_start)
				local search_pos = 1
				while search_pos <= #text_part do
					local match_start, match_end = text_part:lower():find(query_lower, search_pos, true)
					if not match_start then
						break
					end
					vim.hl.range(
						finder_state.results_buf,
						finder_state.ns_id,
						"IncSearch",
						{ text_line_idx, text_start + match_start - 2 },
						{ text_line_idx, text_start + match_end - 1 },
						{}
					)
					search_pos = match_end + 1
				end
			end
		end
	end

	-- Scroll to show selected line
	if #finder_state.results > 0 and finder_state.selected_idx > 0 then
		if finder_state.results_win and vim.api.nvim_win_is_valid(finder_state.results_win) then
			local cursor_line
			if finder_state.mode == "file" then
				cursor_line = line_data[finder_state.selected_idx] and line_data[finder_state.selected_idx].line_idx
					or 0
			else
				cursor_line = line_data[finder_state.selected_idx]
						and line_data[finder_state.selected_idx].file_line_idx
					or 0
			end
			vim.api.nvim_win_set_cursor(finder_state.results_win, { cursor_line + 1, 0 })
		end
	end
end

-- Update results based on current input
local function update_results()
	if not finder_state.buf or not vim.api.nvim_buf_is_valid(finder_state.buf) then
		return
	end

	local lines = vim.api.nvim_buf_get_lines(finder_state.buf, 0, -1, false)
	local query = lines[1] or ""
	query = query:gsub("^❯%s*", "")

	finder_state.current_query = query

	-- Perform search based on mode
	local results = {}
	if finder_state.mode == "file" then
		results = search_files(query)
	elseif finder_state.mode == "grep" then
		if query == "" or #query < 2 then
			finder_state.results = {}
			finder_state.selected_idx = 1
			update_results_display()
			return
		end
		results = search_grep(query)
	end

	finder_state.results = results
	finder_state.selected_idx = math.min(finder_state.selected_idx, #results)
	if finder_state.selected_idx == 0 and #results > 0 then
		finder_state.selected_idx = 1
	end

	update_results_display()
end

-- Move selection
local function move_selection(delta)
	if #finder_state.results == 0 then
		return
	end

	finder_state.selected_idx = finder_state.selected_idx + delta
	if finder_state.selected_idx < 1 then
		finder_state.selected_idx = #finder_state.results
	elseif finder_state.selected_idx > #finder_state.results then
		finder_state.selected_idx = 1
	end

	update_results_display()
end

-- Close finder interface
local function close_finder()
	if finder_state.closing then
		return
	end
	finder_state.closing = true

	-- Close windows and buffers safely
	if finder_state.results_win and vim.api.nvim_win_is_valid(finder_state.results_win) then
		pcall(vim.api.nvim_win_close, finder_state.results_win, true)
	end
	if finder_state.results_buf and vim.api.nvim_buf_is_valid(finder_state.results_buf) then
		pcall(vim.api.nvim_buf_delete, finder_state.results_buf, { force = true })
	end
	if finder_state.win and vim.api.nvim_win_is_valid(finder_state.win) then
		pcall(vim.api.nvim_win_close, finder_state.win, true)
	end
	if finder_state.buf and vim.api.nvim_buf_is_valid(finder_state.buf) then
		pcall(vim.api.nvim_buf_delete, finder_state.buf, { force = true })
	end

	-- Reset state
	finder_state.mode = nil
	finder_state.win = nil
	finder_state.buf = nil
	finder_state.results_win = nil
	finder_state.results_buf = nil
	finder_state.results = {}
	finder_state.selected_idx = 1
	finder_state.closing = false
end

-- Accept current selection and close
local function accept_selection()
	if #finder_state.results == 0 or finder_state.selected_idx < 1 then
		close_finder()
		return
	end

	local result = finder_state.results[finder_state.selected_idx]
	local mode = finder_state.mode

	-- Close the interface first
	close_finder()

	-- Open the file
	vim.schedule(function()
		if mode == "file" then
			vim.cmd("edit " .. vim.fn.fnameescape(result.path))
		elseif mode == "grep" then
			vim.cmd("edit " .. vim.fn.fnameescape(result.filename))
			vim.api.nvim_win_set_cursor(0, { result.lnum, result.col - 1 })
			vim.cmd("normal! zz")
		end
	end)
end

-- Main finder function
local function open_finder(mode)
	-- Calculate dimensions
	local width = math.floor(vim.o.columns * 0.7)
	local height = math.floor(vim.o.lines * 0.6)
	local input_height = 1
	local results_height = height - input_height - 1
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	-- Set title based on mode
	local title = mode == "file" and " Find File " or " Live Grep "

	-- Create input buffer and window
	local input_buf = vim.api.nvim_create_buf(false, true)
	local input_win = vim.api.nvim_open_win(input_buf, true, {
		relative = "editor",
		width = width,
		height = input_height,
		row = row,
		col = col,
		style = "minimal",
		title = title,
		title_pos = "center",
	})

	-- Create results buffer and window
	local results_buf = vim.api.nvim_create_buf(false, true)
	local results_win = vim.api.nvim_open_win(results_buf, false, {
		relative = "editor",
		width = width,
		height = results_height,
		row = row + input_height + 1,
		col = col,
		style = "minimal",
	})

	-- Set buffer options
	vim.api.nvim_set_option_value("buftype", "prompt", { buf = input_buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = input_buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = input_buf })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = results_buf })
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = results_buf })
	vim.api.nvim_set_option_value("swapfile", false, { buf = results_buf })
	vim.api.nvim_set_option_value("modifiable", false, { buf = results_buf })

	-- Store state
	finder_state.mode = mode
	finder_state.buf = input_buf
	finder_state.win = input_win
	finder_state.results_buf = results_buf
	finder_state.results_win = results_win
	finder_state.results = {}
	finder_state.selected_idx = 1

	-- Set up prompt
	vim.fn.prompt_setprompt(input_buf, "❯ ")

	-- Set up keymaps
	local opts = { buffer = input_buf, noremap = true, silent = true }
	vim.keymap.set("i", "<CR>", accept_selection, opts)
	vim.keymap.set("i", "<C-y>", accept_selection, opts)
	vim.keymap.set("i", "<C-c>", close_finder, opts)
	vim.keymap.set("i", "<Esc>", close_finder, opts)
	vim.keymap.set("i", "<C-n>", function()
		move_selection(1)
	end, opts)
	vim.keymap.set("i", "<C-p>", function()
		move_selection(-1)
	end, opts)
	vim.keymap.set("i", "<Down>", function()
		move_selection(1)
	end, opts)
	vim.keymap.set("i", "<Up>", function()
		move_selection(-1)
	end, opts)
	vim.keymap.set("n", "<CR>", accept_selection, opts)
	vim.keymap.set("n", "q", close_finder, opts)
	vim.keymap.set("n", "<Esc>", close_finder, opts)
	vim.keymap.set("n", "j", function()
		move_selection(1)
	end, opts)
	vim.keymap.set("n", "k", function()
		move_selection(-1)
	end, opts)

	-- Set up autocmd to update results on text change
	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = input_buf,
		callback = update_results,
	})

	-- Clean up when buffer is closed
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = input_buf,
		callback = function()
			if not finder_state.closing then
				close_finder()
			end
		end,
	})

	-- Load initial results (for file mode)
	if mode == "file" then
		update_results()
	end

	-- Enter insert mode
	vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>f", function()
	open_finder("file")
end, { desc = "Find File" })
vim.keymap.set("n", "<leader>g", function()
	open_finder("grep")
end, { desc = "Live Grep" })
