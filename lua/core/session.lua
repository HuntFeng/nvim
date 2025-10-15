local M = {}

local config = {
	-- directory to store session files
	session_dir = vim.fn.stdpath("data") .. "/sessions",
	-- events that trigger session save
	save_events = { "BufWrite", "BufAdd", "BufEnter", "VimLeavePre" },
}

-- create session directory if it doesn't exist
local function ensure_session_dir()
	if vim.fn.isdirectory(config.session_dir) == 0 then
		vim.fn.mkdir(config.session_dir, "p")
	end
end

local function path_to_session_name(path)
	-- remove any leading/trailing whitespace
	path = vim.fn.trim(path)
	-- replace path separators with %2F
	path = path:gsub("[/]", "%%2F")
	-- replace dots with %2E
	path = path:gsub("[.]", "%%2E")
	-- replace spaces with underscores
	path = path:gsub("%s+", "_")
	-- add extension
	return path .. ".vim"
end

local function get_session_file()
	local cwd = vim.fn.getcwd()
	local session_filename = path_to_session_name(cwd)
	return config.session_dir .. "/" .. session_filename
end

function M.save_session()
	ensure_session_dir()
	local session_file = get_session_file()

	-- don't save if in a git diff, merge, or rebase
	if
		vim.fn.filereadable(".git/MERGE_HEAD") == 1
		or vim.fn.filereadable(".git/REBASE_HEAD") == 1
		or vim.fn.filereadable(".git/rebase-merge/git-rebase-todo") == 1
	then
		return
	end

	vim.cmd("mksession! " .. vim.fn.fnameescape(session_file))
end

function M.load_session()
	local session_file = get_session_file()
	if vim.fn.filereadable(session_file) == 1 then
		-- clear existing buffers before loading session
		vim.cmd("silent! %bwipeout!")
		-- load session
		vim.cmd("silent! source " .. vim.fn.fnameescape(session_file))
		-- refresh to trigger lsp
		vim.schedule(function()
			vim.cmd("silent! e!")
		end)
	end
end

function M.setup()
	local augroup = vim.api.nvim_create_augroup("SessionManagement", { clear = true })

	vim.api.nvim_create_autocmd(config.save_events, {
		group = augroup,
		callback = function()
			if vim.v.this_session ~= "" then
				M.save_session()
			end
		end,
	})

	vim.api.nvim_create_autocmd("VimEnter", {
		group = augroup,
		callback = function()
			if vim.fn.argc() == 0 then
				M.load_session()
			end
		end,
	})

	if vim.v.this_session == "" then
		-- load or create session on startup
		M.load_session()
		if vim.v.this_session == "" then
			M.save_session()
		end
	end
end

M.setup()
