local config = {
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
	grep_include_patterns = {},
	use_fd = true,
	use_ripgrep = true,
	max_results = 50,
	finder_width = 0.7,
	finder_height = 0.6,
	show_preview = true,
	preview_width = 0.5,
}

local finder_state = {
	mode = nil,
	buf = nil,
	win = nil,
	results_buf = nil,
	results_win = nil,
	preview_buf = nil,
	preview_win = nil,
	results = {},
	current_query = "",
	selected_idx = 1,
	selectable_items = {},
	results_width = 0,
	preview_height = 0,
	preview_start_line = 1,
	ns_id = vim.api.nvim_create_namespace("fuzzyfind_results"),
	closing = false,
}

local function build_find_command(pattern)
	pattern = pattern or ""
	local has_fd = vim.fn.executable("fd") == 1
	local cmd

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

local function build_grep_command(pattern)
	if not pattern or pattern == "" then
		return nil
	end
	local has_rg = vim.fn.executable("rg") == 1
	local cmd

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

local function fuzzy_match(str, pattern)
	if pattern == "" then
		return true, 0
	end
	str, pattern = str:lower(), pattern:lower()
	local score, str_idx, pat_idx = 0, 1, 1

	while pat_idx <= #pattern and str_idx <= #str do
		if str:sub(str_idx, str_idx) == pattern:sub(pat_idx, pat_idx) then
			score = score + 1
			pat_idx = pat_idx + 1
		end
		str_idx = str_idx + 1
	end
	return pat_idx > #pattern, score
end

local function parse_grep_line(line)
	local filename, lnum, col, text = line:match("^(.+):(%d+):(%d+):(.*)$")
	if not filename then
		filename, lnum, text = line:match("^(.+):(%d+):(.*)$")
		col = 1
	end
	if filename and lnum then
		return { filename = filename, lnum = tonumber(lnum), col = tonumber(col) or 1, text = text or "" }
	end
end

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
		return a.score ~= b.score and a.score > b.score or a.path < b.path
	end)
	return results
end

local function search_grep(pattern)
	local cmd = build_grep_command(pattern)
	if not cmd then
		return {}
	end

	local raw_results = {}
	for _, line in ipairs(vim.fn.systemlist(cmd)) do
		local parsed = parse_grep_line(line)
		if parsed then
			table.insert(raw_results, parsed)
			if #raw_results >= config.max_results then
				break
			end
		end
	end

	local grouped, file_order = {}, {}
	for _, result in ipairs(raw_results) do
		if not grouped[result.filename] then
			grouped[result.filename] = { filename = result.filename, matches = {} }
			table.insert(file_order, result.filename)
		end
		table.insert(grouped[result.filename].matches, {
			lnum = result.lnum,
			col = result.col,
			text = result.text,
		})
	end

	local results = {}
	for _, filename in ipairs(file_order) do
		table.insert(results, grouped[filename])
	end
	return results
end

local function search_combined(pattern)
	if not pattern or #pattern < 1 then
		return {}
	end

	local results = {}
	for _, file_result in ipairs(search_files(pattern)) do
		table.insert(results, { type = "file", path = file_result.path, score = file_result.score })
		if #results >= config.max_results then
			return results
		end
	end

	if #pattern >= 2 then
		for _, grep_group in ipairs(search_grep(pattern)) do
			table.insert(results, { type = "grep_group", filename = grep_group.filename, matches = grep_group.matches })
			if #results >= config.max_results then
				return results
			end
		end
	end
	return results
end

local function format_result(filepath, is_selected, is_match)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	local dir_path = vim.fn.fnamemodify(filepath, ":h")
	local prefix = is_selected and (is_match and "  ❯ " or "❯ ") or (is_match and "    " or "  ")
	return string.format("%s%s (%s)", prefix, filename, dir_path), filename
end

local function format_grep_match(match, is_selected)
	local text = match.text:gsub("^%s+", ""):gsub("%s+$", "")
	local prefix = is_selected and "  ❯ " or "    "
	local max_len = math.max(40, finder_state.results_width - 5)
	local line_num_str = string.format("%d: ", match.lnum)
	local max_text = max_len - vim.fn.strdisplaywidth(prefix .. line_num_str)

	if vim.fn.strdisplaywidth(text) > max_text then
		local cut_len, display_len = 0, 0
		for i = 1, #text do
			local char_width = vim.fn.strdisplaywidth(text:sub(i, i))
			if display_len + char_width > max_text - 3 then
				break
			end
			display_len, cut_len = display_len + char_width, i
		end
		text = text:sub(1, cut_len) .. "..."
	end
	return string.format("%s%d: %s", prefix, match.lnum, text)
end

local function get_selected_item()
	for _, item in ipairs(finder_state.selectable_items) do
		if item.selectable_idx == finder_state.selected_idx then
			return item
		end
	end
end

local function update_preview()
	if
		not config.show_preview
		or not finder_state.preview_buf
		or not vim.api.nvim_buf_is_valid(finder_state.preview_buf)
	then
		return
	end

	local set_buf_content = function(lines)
		vim.api.nvim_set_option_value("modifiable", true, { buf = finder_state.preview_buf })
		vim.api.nvim_buf_set_lines(finder_state.preview_buf, 0, -1, false, lines)
		vim.api.nvim_set_option_value("modifiable", false, { buf = finder_state.preview_buf })
	end

	local selected_item = get_selected_item()
	if not selected_item then
		set_buf_content({ "No preview available" })
		return
	end

	local filepath = selected_item.filepath or selected_item.filename
	if vim.fn.filereadable(filepath) ~= 1 then
		set_buf_content({ "File not readable: " .. filepath })
		return
	end

	local max_lines = finder_state.preview_height
	local highlight_line = selected_item.lnum
	local start_line, end_line

	if highlight_line and (selected_item.type == "grep_match" or selected_item.type == "grep_header") then
		local half_height = math.floor(max_lines / 2)
		start_line = math.max(1, highlight_line - half_height)
		end_line = start_line + max_lines - 1
	else
		start_line = 1
		end_line = max_lines
	end

	local file_handle = io.open(filepath, "r")
	if not file_handle then
		set_buf_content({ "Cannot open file: " .. filepath })
		return
	end

	local lines = {}
	local current_line = 0
	for line in file_handle:lines() do
		current_line = current_line + 1
		if current_line >= start_line and current_line <= end_line then
			lines[#lines + 1] = line:gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "  ")
		end
		if current_line > end_line then break end
	end
	file_handle:close()

	if #lines == 0 then
		lines = { "Empty file" }
	end

	set_buf_content(lines)

	finder_state.preview_start_line = start_line

	local filetype = vim.filetype.match({ filename = filepath })
	if filetype then
		vim.api.nvim_set_option_value("filetype", filetype, { buf = finder_state.preview_buf })
	end

	vim.api.nvim_buf_clear_namespace(finder_state.preview_buf, finder_state.ns_id, 0, -1)

	if highlight_line and finder_state.preview_win and vim.api.nvim_win_is_valid(finder_state.preview_win) then
		local relative_line = highlight_line - start_line + 1
		if relative_line >= 1 and relative_line <= #lines then
			vim.hl.range(
				finder_state.preview_buf,
				finder_state.ns_id,
				"CursorLine",
				{ relative_line - 1, 0 },
				{ relative_line - 1, -1 },
				{}
			)
			vim.api.nvim_win_set_cursor(finder_state.preview_win, { relative_line, 0 })
		else
			vim.api.nvim_win_set_cursor(finder_state.preview_win, { 1, 0 })
		end
	elseif finder_state.preview_win and vim.api.nvim_win_is_valid(finder_state.preview_win) then
		vim.api.nvim_win_set_cursor(finder_state.preview_win, { 1, 0 })
	end
end

local function add_selectable_item(lines, selectable_items, line_data, selectable_idx, result_idx, item_type, data)
	local line_idx = #lines - 1
	table.insert(
		selectable_items,
		vim.tbl_extend("force", {
			selectable_idx = selectable_idx,
			line_idx = line_idx,
			result_idx = result_idx,
			type = item_type,
		}, data)
	)
	table.insert(
		line_data,
		vim.tbl_extend("force", {
			type = item_type,
			line_idx = line_idx,
			is_selected = selectable_idx == finder_state.selected_idx,
		}, data.line_data or {})
	)
end

local function update_results_display()
	if not finder_state.results_buf or not vim.api.nvim_buf_is_valid(finder_state.results_buf) then
		return
	end

	local lines, line_data, selectable_items, selectable_idx = {}, {}, {}, 0

	for i, result in ipairs(finder_state.results) do
		if result.type == "file" or finder_state.mode == "file" then
			selectable_idx = selectable_idx + 1
			local filepath = result.path or result.filename
			local line, filename = format_result(filepath, selectable_idx == finder_state.selected_idx, false)
			table.insert(lines, line)
			add_selectable_item(lines, selectable_items, line_data, selectable_idx, i, "file", {
				filepath = filepath,
				line_data = { filename = filename, prefix_len = 2 },
			})
		elseif result.type == "grep_group" or finder_state.mode == "grep" then
			selectable_idx = selectable_idx + 1
			local line, filename = format_result(result.filename, selectable_idx == finder_state.selected_idx, false)
			table.insert(lines, line)
			add_selectable_item(lines, selectable_items, line_data, selectable_idx, i, "grep_header", {
				filename = result.filename,
				line_data = { filename = filename, prefix_len = 2 },
			})

			for _, match in ipairs(result.matches) do
				selectable_idx = selectable_idx + 1
				table.insert(lines, format_grep_match(match, selectable_idx == finder_state.selected_idx))
				add_selectable_item(lines, selectable_items, line_data, selectable_idx, i, "grep_match", {
					filename = result.filename,
					lnum = match.lnum,
					col = match.col,
					line_data = { prefix_len = 4 },
				})
			end
		end
	end

	finder_state.selectable_items = selectable_items

	if #lines == 0 then
		lines = { finder_state.mode == "file" and "  No files found" or "  No results found" }
		line_data = {}
	end

	vim.api.nvim_set_option_value("modifiable", true, { buf = finder_state.results_buf })
	vim.api.nvim_buf_set_lines(finder_state.results_buf, 0, -1, false, lines)
	vim.api.nvim_set_option_value("modifiable", false, { buf = finder_state.results_buf })
	vim.api.nvim_buf_clear_namespace(finder_state.results_buf, finder_state.ns_id, 0, -1)

	for _, data in ipairs(line_data) do
		local line_idx, line, is_selected = data.line_idx, lines[data.line_idx + 1], data.is_selected

		if data.type == "file" or data.type == "grep_header" then
			local prefix = is_selected and "❯ " or "  "
			local fn_start, fn_end = #prefix, #prefix + #data.filename

			if is_selected then
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"Visual",
					{ line_idx, 0 },
					{ line_idx, -1 },
					{}
				)
			end
			vim.hl.range(
				finder_state.results_buf,
				finder_state.ns_id,
				"Bold",
				{ line_idx, fn_start },
				{ line_idx, fn_end },
				{}
			)
			vim.hl.range(
				finder_state.results_buf,
				finder_state.ns_id,
				"Directory",
				{ line_idx, fn_start },
				{ line_idx, fn_end },
				{}
			)

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
		elseif data.type == "grep_match" then
			if is_selected then
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"Visual",
					{ line_idx, 0 },
					{ line_idx, -1 },
					{}
				)
			end

			local prefix = is_selected and "  ❯ " or "    "
			local lnum_start, lnum_end = #prefix, line:find(":", #prefix + 1)
			if lnum_end then
				vim.hl.range(
					finder_state.results_buf,
					finder_state.ns_id,
					"LineNr",
					{ line_idx, lnum_start },
					{ line_idx, lnum_end },
					{}
				)
			end

			if finder_state.current_query ~= "" then
				local query_lower = finder_state.current_query:lower()
				local text_start = (line:find(": ") or 0) + 2
				local text_part = line:sub(text_start)
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
						{ line_idx, text_start + match_start - 2 },
						{ line_idx, text_start + match_end - 1 },
						{}
					)
					search_pos = match_end + 1
				end
			end
		end
	end

	if
		#finder_state.selectable_items > 0
		and finder_state.results_win
		and vim.api.nvim_win_is_valid(finder_state.results_win)
	then
		for _, selectable in ipairs(finder_state.selectable_items) do
			if selectable.selectable_idx == finder_state.selected_idx then
				vim.api.nvim_win_set_cursor(finder_state.results_win, { selectable.line_idx + 1, 0 })
				break
			end
		end
	end

	update_preview()
end

local function update_results()
	if not finder_state.buf or not vim.api.nvim_buf_is_valid(finder_state.buf) then
		return
	end

	local query = (vim.api.nvim_buf_get_lines(finder_state.buf, 0, -1, false)[1] or ""):gsub("^❯%s*", "")
	finder_state.current_query = query

	local results
	if finder_state.mode == "file" then
		results = search_files(query)
	elseif finder_state.mode == "grep" then
		if query == "" or #query < 2 then
			finder_state.results, finder_state.selected_idx = {}, 1
			update_results_display()
			return
		end
		results = search_grep(query)
	elseif finder_state.mode == "combined" then
		if query == "" then
			finder_state.results, finder_state.selected_idx = {}, 1
			update_results_display()
			return
		end
		results = search_combined(query)
	end

	finder_state.results = results

	if #results == 0 then
		finder_state.selected_idx, finder_state.selectable_items = 1, {}
		update_results_display()
		return
	end

	if finder_state.selected_idx == 0 then
		finder_state.selected_idx = 1
	end
	update_results_display()

	if finder_state.selected_idx > #finder_state.selectable_items then
		finder_state.selected_idx = #finder_state.selectable_items
		update_results_display()
	end
end

local function move_selection(delta)
	if #finder_state.selectable_items == 0 then
		return
	end
	finder_state.selected_idx = finder_state.selected_idx + delta
	if finder_state.selected_idx < 1 then
		finder_state.selected_idx = #finder_state.selectable_items
	elseif finder_state.selected_idx > #finder_state.selectable_items then
		finder_state.selected_idx = 1
	end
	update_results_display()
end

local function close_finder()
	if finder_state.closing then
		return
	end
	finder_state.closing = true

	local preview_win, results_win, input_win = finder_state.preview_win, finder_state.results_win, finder_state.win
	local preview_buf, results_buf, input_buf = finder_state.preview_buf, finder_state.results_buf, finder_state.buf

	finder_state.mode, finder_state.win, finder_state.buf = nil, nil, nil
	finder_state.results_win, finder_state.results_buf = nil, nil
	finder_state.preview_win, finder_state.preview_buf = nil, nil
	finder_state.results, finder_state.selected_idx, finder_state.closing = {}, 1, false

	vim.schedule(function()
		if preview_win and vim.api.nvim_win_is_valid(preview_win) then
			pcall(vim.api.nvim_win_close, preview_win, true)
		end
		if results_win and vim.api.nvim_win_is_valid(results_win) then
			pcall(vim.api.nvim_win_close, results_win, true)
		end
		if input_win and vim.api.nvim_win_is_valid(input_win) then
			pcall(vim.api.nvim_win_close, input_win, true)
		end
		
		if preview_buf and vim.api.nvim_buf_is_valid(preview_buf) then
			pcall(vim.api.nvim_buf_delete, preview_buf, { force = true })
		end
		if results_buf and vim.api.nvim_buf_is_valid(results_buf) then
			pcall(vim.api.nvim_buf_delete, results_buf, { force = true })
		end
		if input_buf and vim.api.nvim_buf_is_valid(input_buf) then
			pcall(vim.api.nvim_buf_delete, input_buf, { force = true })
		end
	end)
end

local function accept_selection()
	local selected_item = get_selected_item()
	if not selected_item then
		close_finder()
		return
	end

	local filepath = selected_item.filepath or selected_item.filename
	local lnum, col = selected_item.lnum, selected_item.col or 1
	close_finder()

	vim.schedule(function()
		vim.cmd("edit " .. vim.fn.fnameescape(filepath))
		if lnum then
			vim.api.nvim_win_set_cursor(0, { lnum, col - 1 })
			vim.cmd("normal! zz")
		end
	end)
end

local function open_finder(mode)
	local width = math.floor(vim.o.columns * config.finder_width)
	local height = math.floor(vim.o.lines * config.finder_height)
	local row, col = math.floor((vim.o.lines - height) / 2), math.floor((vim.o.columns - width) / 2)

	local results_width = width
	local preview_width = 0
	if config.show_preview then
		preview_width = math.floor(width * config.preview_width)
		results_width = width - preview_width - 1
	end
	finder_state.results_width = results_width

	local title = mode == "file" and " Find File " or mode == "grep" and " Live Grep " or " Search "

	local input_buf = vim.api.nvim_create_buf(false, true)
	local input_win = vim.api.nvim_open_win(input_buf, true, {
		relative = "editor",
		width = results_width,
		height = 1,
		row = row,
		col = col,
		style = "minimal",
		title = title,
		title_pos = "center",
	})

	local results_buf = vim.api.nvim_create_buf(false, true)
	local results_win = vim.api.nvim_open_win(results_buf, false, {
		relative = "editor",
		width = results_width,
		height = height - 2,
		row = row + 2,
		col = col,
		style = "minimal",
	})

	local preview_buf, preview_win
	if config.show_preview then
		preview_buf = vim.api.nvim_create_buf(false, true)
		preview_win = vim.api.nvim_open_win(preview_buf, false, {
			relative = "editor",
			width = preview_width,
			height = height,
			row = row,
			col = col + results_width + 1,
			style = "minimal",
			title = " Preview ",
			title_pos = "center",
		})
		local opts_map = {
			{ "buftype", "nofile", { buf = preview_buf } },
			{ "bufhidden", "wipe", { buf = preview_buf } },
			{ "swapfile", false, { buf = preview_buf } },
			{ "modifiable", false, { buf = preview_buf } },
			{ "wrap", false, { win = preview_win } },
			{ "number", false, { win = preview_win } },
			{ "relativenumber", false, { win = preview_win } },
			{ "statuscolumn", "%{v:lua.require('core.fuzzyfind').get_preview_line_num()}", { win = preview_win } },
		}
		for _, opt in ipairs(opts_map) do
			vim.api.nvim_set_option_value(opt[1], opt[2], opt[3])
		end
	end

	for _, opt in ipairs({
		{ "buftype", "prompt", { buf = input_buf } },
		{ "bufhidden", "wipe", { buf = input_buf } },
		{ "swapfile", false, { buf = input_buf } },
		{ "buftype", "nofile", { buf = results_buf } },
		{ "bufhidden", "wipe", { buf = results_buf } },
		{ "swapfile", false, { buf = results_buf } },
		{ "modifiable", false, { buf = results_buf } },
	}) do
		vim.api.nvim_set_option_value(opt[1], opt[2], opt[3])
	end

	finder_state.mode, finder_state.buf, finder_state.win = mode, input_buf, input_win
	finder_state.results_buf, finder_state.results_win = results_buf, results_win
	finder_state.preview_buf, finder_state.preview_win = preview_buf, preview_win
	finder_state.preview_height = height
	finder_state.results, finder_state.selected_idx = {}, 1

	vim.fn.prompt_setprompt(input_buf, "❯ ")

	local opts = { buffer = input_buf, noremap = true, silent = true }
	local keymaps = {
		{ "i", "<CR>", accept_selection },
		{ "i", "<C-y>", accept_selection },
		{ "i", "<C-c>", close_finder },
		{ "i", "<Esc>", close_finder },
		{
			"i",
			"<C-n>",
			function()
				move_selection(1)
			end,
		},
		{
			"i",
			"<C-p>",
			function()
				move_selection(-1)
			end,
		},
		{
			"i",
			"<Down>",
			function()
				move_selection(1)
			end,
		},
		{
			"i",
			"<Up>",
			function()
				move_selection(-1)
			end,
		},
		{ "n", "<CR>", accept_selection },
		{ "n", "q", close_finder },
		{ "n", "<Esc>", close_finder },
		{
			"n",
			"j",
			function()
				move_selection(1)
			end,
		},
		{
			"n",
			"k",
			function()
				move_selection(-1)
			end,
		},
	}
	for _, km in ipairs(keymaps) do
		vim.keymap.set(km[1], km[2], km[3], opts)
	end

	vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, { buffer = input_buf, callback = update_results })
	vim.api.nvim_create_autocmd("BufWipeout", {
		buffer = input_buf,
		callback = function()
			if not finder_state.closing then
				close_finder()
			end
		end,
	})

	if mode == "file" or mode == "combined" then
		update_results()
	end
	vim.cmd("startinsert")
end

local function get_preview_line_num()
	return string.format("%4d ", finder_state.preview_start_line + vim.v.lnum - 1)
end

vim.keymap.set("n", "<leader>f", function()
	open_finder("combined")
end, { desc = "Find (Files & Content)" })

return {
	open_finder = open_finder,
	get_preview_line_num = get_preview_line_num,
}
