-- A small, dependency-free project picker.  It deliberately uses jobs instead
-- of :grep so a new keystroke can cancel work started by the previous one.
local api = vim.api

local state = { files = {}, entries = {}, grep_entries = {}, grep_partial = "", request = 0, windows = {}, bufs = {} }
local list_namespace = api.nvim_create_namespace("grep_float_list")
local preview_namespace = api.nvim_create_namespace("grep_float_preview")

local function valid(win)
	return win and api.nvim_win_is_valid(win)
end

local function stop(job)
	if state[job] then
		vim.fn.jobstop(state[job])
		state[job] = nil
	end
end

local function close()
	stop("grep_job")
	stop("file_job")
	for _, win in pairs(state.windows) do
		if valid(win) then
			api.nvim_win_close(win, true)
		end
	end
	vim.cmd("stopinsert")
	state.windows, state.bufs = {}, {}
end

local function set_lines(buf, lines)
	vim.bo[buf].modifiable = true
	api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
end

-- Matched text is drawn as a virtual line below its entry, so buffer rows stay
-- one-to-one with state.entries and cursor/selection logic is unaffected.
local function set_detail(row, hl)
	local entry = row and state.entries[row]
	if entry and entry.kind == "content" then
		local detail = string.format("  %d:%d   %s", entry.lnum, entry.col, entry.text)
		state.detail_marks[row] = api.nvim_buf_set_extmark(state.bufs.list, list_namespace, row - 1, 0, {
			id = state.detail_marks[row],
			virt_lines = { { { detail, hl } } },
		})
	end
end

-- rg --vimgrep reports where a match starts but not how long it is, so
-- re-match the query at that column.  A literal comparison covers most
-- searches; otherwise try it as a very-magic Vim regex, which agrees with rg's
-- syntax for common patterns.  Returns 0 when the length can't be determined.
local function match_length(line, start, query)
	local ignorecase = not query:find("%u")
	local subject, needle = line:sub(start + 1), query
	if ignorecase then
		subject, needle = subject:lower(), needle:lower()
	end
	if subject:sub(1, #needle) == needle then
		return #needle
	end
	local ok, regex = pcall(vim.regex, (ignorecase and "\\c" or "\\C") .. "\\v" .. query)
	if ok then
		local s, e = regex:match_str(line:sub(start + 1))
		return s == 0 and e or 0
	end
	return 0
end

local function selected_entry()
	return state.entries[api.nvim_win_get_cursor(state.windows.list)[1]]
end

local function preview()
	if not valid(state.windows.list) or not valid(state.windows.preview) then
		return
	end
	local row = api.nvim_win_get_cursor(state.windows.list)[1]
	local entry = state.entries[row]
	if not entry then
		return
	end
	-- cursorline does not cover virtual lines, so highlight the detail manually.
	if state.selected ~= row then
		set_detail(state.selected, nil)
		set_detail(row, "Visual")
		state.selected = row
	end

	local buf, path = state.bufs.preview, entry.file
	local ok, lines = pcall(vim.fn.readfile, path, "", 2000)
	lines = ok and lines or { "Unable to read " .. path }
	set_lines(buf, lines)
	api.nvim_buf_set_name(buf, "grep-preview://" .. path)
	vim.bo[buf].filetype = vim.filetype.match({ filename = path }) or ""
	local lnum, start = math.min(math.max(entry.lnum, 1), math.max(#lines, 1)), entry.col - 1
	api.nvim_buf_clear_namespace(buf, preview_namespace, 0, -1)
	-- readfile() is capped, so a match past the limit has no line to highlight.
	if entry.kind == "content" and entry.lnum <= #lines then
		api.nvim_buf_set_extmark(buf, preview_namespace, lnum - 1, 0, { line_hl_group = "CursorLine" })
		local length = match_length(lines[lnum], start, entry.query)
		if length > 0 then
			-- Outrank treesitter (priority 100) so the match stays visible.
			api.nvim_buf_set_extmark(buf, preview_namespace, lnum - 1, start, {
				end_col = start + length,
				hl_group = "MatchParen",
				priority = 200,
			})
		end
	end
	api.nvim_win_set_cursor(state.windows.preview, { lnum, start })
	api.nvim_win_call(state.windows.preview, function()
		vim.cmd("normal! zz")
	end)
end

local function move_selection(delta)
	if valid(state.windows.list) and #state.entries > 0 then
		local row = api.nvim_win_get_cursor(state.windows.list)[1] + delta
		api.nvim_win_set_cursor(state.windows.list, { math.min(math.max(row, 1), #state.entries), 0 })
		preview()
	end
end

local function render_list()
	local buf = state.bufs.list
	if not api.nvim_buf_is_valid(buf) then
		return
	end
	local lines = vim.tbl_map(function(entry)
		return vim.fn.fnamemodify(entry.file, ":t") .. "  " .. vim.fn.fnamemodify(entry.file, ":h")
	end, state.entries)
	set_lines(buf, #lines > 0 and lines or { "No matches" })
	api.nvim_buf_clear_namespace(buf, list_namespace, 0, -1)
	state.detail_marks, state.selected = {}, nil
	for row, entry in ipairs(state.entries) do
		local parent_start = #vim.fn.fnamemodify(entry.file, ":t") + 2
		api.nvim_buf_set_extmark(buf, list_namespace, row - 1, parent_start, { hl_group = "Comment", end_col = #lines[row] })
		set_detail(row, nil)
	end
	preview()
end

local function refresh_entries(query)
	local names = query == "" and state.files or vim.fn.matchfuzzy(state.files, query)
	state.entries = vim.tbl_map(function(file)
		return { kind = "file", file = file, lnum = 1, col = 1 }
	end, names)
	vim.list_extend(state.entries, state.grep_entries)
	render_list()
end

local function current_query()
	return api.nvim_buf_get_lines(state.bufs.input, 0, 1, false)[1] or ""
end

local function add_grep_entry(line, query)
	local file, lnum, col, text = line:match("^(.*):(%d+):(%d+):(.*)$")
	if file then
		table.insert(state.grep_entries, {
			kind = "content",
			file = file,
			lnum = tonumber(lnum),
			col = tonumber(col),
			text = text,
			query = query,
		})
	end
	return file ~= nil
end

local function start_grep(query)
	state.request = state.request + 1
	local request = state.request
	stop("grep_job")
	state.grep_entries, state.grep_partial = {}, ""
	refresh_entries(query)
	if query == "" then
		return
	end

	state.grep_job = vim.fn.jobstart({ "rg", "--vimgrep", "--smart-case", "--color", "never", "--", query }, {
		cwd = vim.fn.getcwd(),
		-- Without a path argument rg searches stdin when it is not a tty, and
		-- jobstart() connects stdin to a pipe by default, so rg would block forever.
		stdin = "null",
		on_stdout = function(_, data)
			local output = vim.deepcopy(data)
			vim.schedule(function()
				if request ~= state.request or not valid(state.windows.list) then
					return
				end
				-- jobstart() may split a vimgrep record across callbacks.  Its last
				-- item is always the unfinished portion of the stream, so retain it
				-- until the next callback instead of trying to parse it prematurely.
				output[1] = state.grep_partial .. (output[1] or "")
				state.grep_partial = table.remove(output) or ""
				for _, line in ipairs(output) do
					add_grep_entry(line, query)
				end
				refresh_entries(query)
			end)
		end,
		on_exit = function()
			vim.schedule(function()
				if request == state.request then
					-- Normally rg terminates every record with a newline.  Parsing
					-- this final fragment also handles commands that do not.
					if add_grep_entry(state.grep_partial, query) then
						refresh_entries(query)
					end
					state.grep_partial, state.grep_job = "", nil
				end
			end)
		end,
	})
end

local function open_selected()
	local entry = selected_entry()
	if entry then
		close()
		vim.cmd.edit(vim.fn.fnameescape(entry.file))
		api.nvim_win_set_cursor(0, { entry.lnum, entry.col - 1 })
	end
end

local function float(buf, enter, title, row, col, width, height)
	return api.nvim_open_win(buf, enter, {
		relative = "editor",
		row = row,
		col = col,
		width = width,
		height = height,
		style = "minimal",
		border = "single",
		title = " " .. title .. " ",
		title_pos = "left",
	})
end

local function open()
	close()
	local columns, lines = vim.o.columns, vim.o.lines
	local width = math.min(math.max(70, math.floor(columns * 0.85)), columns - 4)
	local height = math.min(math.max(16, math.floor(lines * 0.75)), lines - 4)
	local row, col = math.floor((lines - height) / 2), math.floor((columns - width) / 2)
	local list_width = math.floor(width * 0.48)

	for _, name in ipairs({ "input", "list", "preview" }) do
		state.bufs[name] = api.nvim_create_buf(false, true)
		vim.bo[state.bufs[name]].bufhidden = "wipe"
	end
	local input, list = state.bufs.input, state.bufs.list
	vim.bo[list].modifiable = false
	vim.bo[state.bufs.preview].modifiable = false

	state.windows.input = float(input, true, "Input", row, col, width, 1)
	state.windows.list = float(list, false, "Files / Matches", row + 3, col, list_width, height - 3)
	state.windows.preview =
		float(state.bufs.preview, false, "Preview", row + 3, col + list_width + 2, width - list_width - 2, height - 3)
	vim.wo[state.windows.list].cursorline = true
	vim.wo[state.windows.list].winhighlight = "CursorLine:Visual"
	vim.wo[state.windows.preview].wrap = false

	api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		buffer = input,
		callback = function()
			if api.nvim_buf_is_valid(input) then
				start_grep(current_query())
			end
		end,
	})
	api.nvim_create_autocmd("CursorMoved", { buffer = list, callback = preview })
	api.nvim_create_autocmd("BufWipeout", { buffer = input, once = true, callback = close })

	local function map(buf, mode, lhs, rhs)
		vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true })
	end
	local down, up = function() move_selection(1) end, function() move_selection(-1) end
	map(input, "i", "<Esc>", close)
	map(input, "i", "<C-n>", down)
	map(input, "i", "<Down>", down)
	map(input, "i", "<C-p>", up)
	map(input, "i", "<Up>", up)
	map(list, "n", "q", close)
	map(list, "n", "<C-n>", "j")
	map(list, "n", "<C-p>", "k")
	for _, lhs in ipairs({ "<CR>", "<C-y>" }) do
		map(input, "i", lhs, open_selected)
		map(list, "n", lhs, open_selected)
	end

	state.files = {}
	state.file_job = vim.fn.jobstart({ "rg", "--files" }, {
		cwd = vim.fn.getcwd(),
		stdout_buffered = true,
		on_stdout = function(_, data)
			local output = vim.deepcopy(data)
			vim.schedule(function()
				if valid(state.windows.input) then
					state.files = vim.tbl_filter(function(line)
						return line ~= ""
					end, output)
					-- The file-index job can complete after the user has started a
					-- content search.  Preserve that query (and its grep entries)
					-- instead of replacing the list with unfiltered filenames.
					refresh_entries(current_query())
				end
			end)
		end,
		on_exit = function()
			vim.schedule(function()
				state.file_job = nil
			end)
		end,
	})
	vim.cmd("startinsert")
end

api.nvim_create_user_command("GrepFloat", open, {})
vim.keymap.set("n", "<leader>g", open, { desc = "Floating grep" })
