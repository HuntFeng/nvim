local M = {}

--- highlight pattern
-- This has three parts:
-- 1. the highlight group
-- 2. text content
-- 3. special sequence to restore highlight: %*
-- Example pattern: %#SomeHighlight#some-text%*
local hi_pattern = "%%#%s#%s%%*"

function _G._statusline_component(name)
	return M[name]()
end

function M.git_branch()
	local branch = vim.fn.systemlist("git rev-parse --abbrev-ref HEAD")[1]
	if branch and branch ~= "" and not branch:match("^fatal") then
		return hi_pattern:format("Identifier", "  " .. branch .. " ")
	end
	return ""
end

function M.hlcount()
	local ok, sc = pcall(vim.fn.searchcount, { maxcount = 9999, timeout = 50 })
	if not ok or sc.incomplete ~= 0 or sc.total == 0 then
		return ""
	end
	local txt = string.format(" [%d/%d] ", sc.current, sc.total)
	return hi_pattern:format("WarningMsg", txt)
end

function M.macro_recording()
	if vim.fn.reg_recording() ~= "" then
		return hi_pattern:format("MoreMsg", "Recording @" .. vim.fn.reg_recording() .. " ")
	end
	return ""
end

local statusline = {
	'%{%v:lua._statusline_component("git_branch")%}',
	"%f", -- relative file path
	"%m", -- modified flag
	"%=", -- separator
	"%{%v:lua.vim.diagnostic.status()%} ",
	'%{%v:hlsearch ? v:lua._statusline_component("hlcount") : ""%}',
	'%{%v:lua._statusline_component("macro_recording")%}',
	"%l:%c", -- cursor position,
}

vim.o.statusline = table.concat(statusline, "")
