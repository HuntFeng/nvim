vim.g.netrw_liststyle = 3
vim.g.netrw_keepdir = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 30
vim.g.netrw_fastbrowse = 2
vim.g.netrw_hide = 1

--- Build g:netrw_list_hide from .gitignore files
---@return string comma-separated Vim regex patterns
local function build_netrw_hide_patterns()
  local patterns = {
    [[\(^\|\s\s\)\zs\.\S\+]], -- dotfiles (netrw default)
  }

  -- Walk up from cwd to find all .gitignore files
  local dir = vim.fn.getcwd()
  local seen = {}
  while dir and dir ~= "/" do
    local gitignore = dir .. "/.gitignore"
    if not seen[gitignore] and vim.fn.filereadable(gitignore) == 1 then
      seen[gitignore] = true
      for line in io.lines(gitignore) do
        -- strip leading/trailing whitespace
        line = line:match("^%s*(.-)%s*$")
        if line ~= "" and not line:match("^#") then
          -- Remove leading /
          line = line:gsub("^/", "")
          -- Remove trailing /
          line = line:gsub("/$", "")
          -- Skip negation patterns (too complex for netrw)
          if line ~= "" and not line:match("^!") then
            -- Convert gitignore glob to vim regex
            -- Escape regex metacharacters except * and ?
            line = vim.fn.escape(line, ".~[]\\^$")
            -- ** -> .* (globstar)
            line = line:gsub("%*%*", ".*")
            -- * -> [^/]* (match anything except path separator)
            line = line:gsub("%*", "[^/]*")
            -- ? -> .
            line = line:gsub("%?", ".")
            table.insert(patterns, line)
          end
        end
      end
    end
    -- Go up one directory
    dir = vim.fn.fnamemodify(dir, ":h")
    if dir == vim.fn.getcwd() then break end
  end

  return table.concat(patterns, ",")
end

vim.g.netrw_list_hide = build_netrw_hide_patterns()

MaxDiagSeverityByFileCache = {}
-- Returns a lookup table where, if a file has diagnostics,
-- it will be an entry in the table, and the most severe diagnostic
-- message is displayed.
local function max_diag_severity_by_file(diagnostics)
  local lookup = {}
  for _, d in ipairs(diagnostics or vim.diagnostic.get()) do
    local fname = vim.api.nvim_buf_get_name(d.bufnr)
    if fname ~= "" then
      local full_root = "/"
      for root in string.gmatch(fname, "([^/]+/?)") do
        full_root = full_root .. root
        local severity = lookup[full_root] or vim.diagnostic.severity.HINT + 1
        if d.severity < severity then
          lookup[full_root] = d.severity
        end
      end
    end
  end
  return lookup
end

local function dirname_if_directory(filename)
  return string.match(filename, "[^%s|]*/$")
end

local function is_netrw_tree(buf)
  return not not string.find(buf.name, "NetrwTreeListing$")
end

local function netrw_tree_get_root(_)
  -- TODO: Currently there is no way of getting the root of the tree based on what is displaying.
  -- This means this script does not support changing the root of the tree with gn or ../
  return nil
end

local function parent_dir(dir)
  local result, _ = string.gsub(dir, "[^/]*/$", "")
  return result
end

local NETRW_INDENT_WIDTH = 2

-- Returns a mapping of the line number in the netrw tree
-- to the full filename at that line number
---@param bufnr integer buffer number of the neovim window
---@return { [integer]: table } 
local function netrw_tree_line_number_to_file_info(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local running_dirpath = netrw_tree_get_root(bufnr) or vim.fs.normalize(vim.fn.getcwd()) .. "/"
  local prev_indent_level = 0
  local prev_was_dir = false
  local filenames = {}
  for i, line in ipairs(lines) do
    local string_whitespace = string.match(line, "^[%s|]*") or ""
    local curr_indent_level = string.len(string_whitespace)
    -- tree has 
    -- ../
    -- cwd/
    -- | first_dir/
    -- at the top. So only lines one level down are relevant to us.
    if curr_indent_level ~= 0 then
      local indent_difference = prev_indent_level - curr_indent_level
      while (indent_difference > 0 or prev_was_dir and indent_difference >= 0) do
        if prev_was_dir then
          filenames[i - 2].expanded = false
        end
        indent_difference = indent_difference - NETRW_INDENT_WIDTH
        running_dirpath = parent_dir(running_dirpath)
      end
      local maybe_curr_dirname = dirname_if_directory(line)
      if maybe_curr_dirname then
        running_dirpath = running_dirpath .. maybe_curr_dirname
      end
      local filename = maybe_curr_dirname and "" or string.match(line, "[^%s|]*$")
      if not filename then
        error("unreachable: netrw line " .. filename .. " without filename")
      end
      filenames[i - 1] = {
        filename = running_dirpath .. filename,
        directory = not not maybe_curr_dirname,
        expanded = maybe_curr_dirname and true or nil
      }
      prev_was_dir = maybe_curr_dirname and true or false
      prev_indent_level = curr_indent_level
    end
  end
  return filenames
end

local netrw_tree_buffers = {}

local function get_netrw_tree_buffers()
  local buffers_to_remove = {}
  for bufnr, _ in pairs(netrw_tree_buffers) do
    if not vim.api.nvim_buf_is_valid(bufnr) then
      buffers_to_remove[bufnr] = true
    end
  end
  for bufnr, _ in pairs(buffers_to_remove) do
    netrw_tree_buffers[bufnr] = nil
  end
  return netrw_tree_buffers
end


local netrw_extmark_diagnostic_namespace = vim.api.nvim_create_namespace("netrw_extmark_diagnostic_namespace")

local severity_to_hl_group = {
  [vim.diagnostic.severity.HINT] = vim.api.nvim_get_hl_id_by_name("DiagnosticHint"),
  [vim.diagnostic.severity.INFO] = vim.api.nvim_get_hl_id_by_name("DiagnosticInfo"),
  [vim.diagnostic.severity.WARN] = vim.api.nvim_get_hl_id_by_name("DiagnosticWarn"),
  [vim.diagnostic.severity.ERROR] = vim.api.nvim_get_hl_id_by_name("DiagnosticError"),
}

-- local severity_to_underline_hl_group = {
--   [vim.diagnostic.severity.HINT] = vim.api.nvim_get_hl_id_by_name("DiagnosticUnderlineHint"),
--   [vim.diagnostic.severity.INFO] = vim.api.nvim_get_hl_id_by_name("DiagnosticUnderlineInfo"),
--   [vim.diagnostic.severity.WARN] = vim.api.nvim_get_hl_id_by_name("DiagnosticUnderlineWarn"),
--   [vim.diagnostic.severity.ERROR] = vim.api.nvim_get_hl_id_by_name("DiagnosticUnderlineError"),
-- }


local function append_extmark(bufnr, line, ns, text, hl_group)
  vim.api.nvim_buf_set_extmark(bufnr, ns, line, 0, {
    virt_text={
      {text, hl_group}
    },
    priority=2
  })
end

local function draw_diagnostic(bufnr, line, severity)
  append_extmark(bufnr, line, netrw_extmark_diagnostic_namespace, vim.diagnostic.config().signs.text[severity], severity_to_hl_group[severity])
end

vim.api.nvim_set_hl(0, "GitUnstaged", { fg = "#FFFF00" })
vim.api.nvim_set_hl(0, "GitUnmerged", { fg = "#FF0000" })
vim.api.nvim_set_hl(0, "GitUntracked", { fg = "#00FF00" })

local netrw_extmark_git_namespace = vim.api.nvim_create_namespace("netrw_extmark_git_namespace")

local function draw_git_icons(bufnr, line, is_unstaged, is_unmerged, is_untracked)
  if is_unstaged then
    append_extmark(bufnr, line, netrw_extmark_git_namespace, "M", vim.api.nvim_get_hl_id_by_name("GitUnstaged"))
  end
  if is_untracked then
    append_extmark(bufnr, line, netrw_extmark_git_namespace, "A", vim.api.nvim_get_hl_id_by_name("GitUntracked"))
  end
  if is_unmerged then
    append_extmark(bufnr, line, netrw_extmark_git_namespace, "󰘭", vim.api.nvim_get_hl_id_by_name("GitUnmerged"))
  end
end

---@param bufnr integer? buffer to populate diagnostics on. nil for all netrw bufs.
local function populate_netrw_diagnostics(bufnr)
  if not bufnr then
    for netrw_bufnr, _ in pairs(get_netrw_tree_buffers()) do
      populate_netrw_diagnostics(netrw_bufnr)
    end
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, netrw_extmark_diagnostic_namespace, 0, -1)
  local diagnostics = MaxDiagSeverityByFileCache
  local line_number_to_file_info = netrw_tree_line_number_to_file_info(bufnr)

  for line_num, file_info in pairs(line_number_to_file_info) do
    local filename = file_info.filename
    if not file_info.expanded and diagnostics[filename] then
      draw_diagnostic(bufnr, line_num, diagnostics[filename])
    end
  end
end


--- Run git status --porcelain and return categorized absolute paths.
--- This handles repos with no commits, untracked files, staged new files, etc.
---@return table unstaged, table staged, table unmerged, table untracked
local function git_status_sets()
  local unstaged = {}
  local staged = {}
  local unmerged = {}
  local untracked = {}
  local output = vim.fn.system("git status --porcelain 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return unstaged, staged, unmerged, untracked
  end
  for line in string.gmatch(output, "[^\n]+") do
    local xy = string.sub(line, 1, 2)
    local file = string.sub(line, 4)
    -- Handle rename: "R  old -> new" → take the new name
    if string.sub(xy, 1, 1) == "R" then
      file = string.match(file, ".* %-> (.*)") or file
    end
    local abs = vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))
    local x = string.sub(xy, 1, 1) -- index status
    local y = string.sub(xy, 2, 2) -- working-tree status

    if x == "?" then
      table.insert(untracked, abs)
    else
      if x == "M" or x == "A" or x == "D" or x == "R" or x == "C" then
        table.insert(staged, abs)
      end
      if y == "M" or y == "D" then
        table.insert(unstaged, abs)
      end
      if x == "U" or y == "U" then
        table.insert(unmerged, abs)
      end
    end
  end
  return unstaged, staged, unmerged, untracked
end

local function list_to_set(list)
  local set = {}
  for _, val in ipairs(list) do
    set[val] = true
  end
  return set
end

local function get_all_roots(fname)
  local full_root = "/"
  local result = {}
  for root in string.gmatch(fname, "([^/]+/?)") do
    full_root = full_root .. root
    table.insert(result, full_root)
  end
  return result
end

local function map(func, tbl)
  local result = {}
  for i, val in ipairs(tbl) do
    result[i] = func(val)
  end
  return result
end

local function flatten(nestedTable)
    local flatTable = {}

    local function deepFlatten(currentTable)
        for _, value in ipairs(currentTable) do
            if type(value) == "table" then
                deepFlatten(value) -- Recursively flatten sub-tables
            else
                table.insert(flatTable, value) -- Add non-table elements to the flat table
            end
        end
    end

    deepFlatten(nestedTable)
    return flatTable
end

local git_cache = { unstaged = {}, unmerged = {}, untracked = {} }

local function refresh_git_cache()
  local unstaged, _, unmerged, untracked = git_status_sets()
  git_cache.unstaged  = list_to_set(flatten(map(get_all_roots, unstaged)))
  git_cache.unmerged  = list_to_set(flatten(map(get_all_roots, unmerged)))
  git_cache.untracked = list_to_set(flatten(map(get_all_roots, untracked)))
end
-- call on load so it's populated before first draw
refresh_git_cache()

local function populate_netrw_git_icons(bufnr)
  if not bufnr then
    for netrw_bufnr, _ in pairs(get_netrw_tree_buffers()) do
      populate_netrw_git_icons(netrw_bufnr)
    end
    return
  end

  vim.api.nvim_buf_clear_namespace(bufnr, netrw_extmark_git_namespace, 0, -1)

  local line_number_to_file_info = netrw_tree_line_number_to_file_info(bufnr)

  for line_num, file_info in pairs(line_number_to_file_info) do
    local filename = file_info.filename
    if not file_info.expanded then
      draw_git_icons(bufnr, line_num, git_cache.unstaged[filename], git_cache.unmerged[filename], git_cache.untracked[filename])
    end
  end
end



local function populate_netrw_icons(bufnr)
  populate_netrw_diagnostics(bufnr)
  populate_netrw_git_icons(bufnr)
end

local diag_timer
local function update_max_diag_severity()
  if diag_timer then
    diag_timer:stop()
    diag_timer:close()
  end
  diag_timer = vim.defer_fn(function()
    MaxDiagSeverityByFileCache = max_diag_severity_by_file()
    populate_netrw_icons()
    diag_timer = nil
  end, diag_timer and 100 or 0)
end

vim.api.nvim_create_autocmd("DiagnosticChanged", {
  callback = function()
    update_max_diag_severity()
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern="netrw",
  callback = function(args)
    local bufnr = args.buf
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if not netrw_tree_buffers[bufnr] then
      if is_netrw_tree({
        name = bufname
      }) then
        netrw_tree_buffers[bufnr] = true
        populate_netrw_icons(bufnr)
        setup_netrw_toggle_hooks(bufnr)
      end
    else
      populate_netrw_icons(bufnr)
    end

  end
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern="*",
  callback = function()
    refresh_git_cache()
    populate_netrw_git_icons()
  end
})

-- Per-buffer timers for debounced redraws after folder toggles.
local netrw_redraw_timers = {}

--- Schedule a debounced icon redraw for a netrw buffer.
--- Uses vim.schedule + defer_fn to ensure netrw has finished
--- modifying the buffer before we re-parse it.
local function schedule_netrw_redraw(bufnr)
  -- vim.schedule defers to after the current event loop iteration
  -- (which includes any keys we just fed via nvim_feedkeys)
  vim.schedule(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if netrw_redraw_timers[bufnr] then
      netrw_redraw_timers[bufnr]:stop()
      netrw_redraw_timers[bufnr]:close()
    end
    netrw_redraw_timers[bufnr] = vim.defer_fn(function()
      if vim.api.nvim_buf_is_valid(bufnr) and netrw_tree_buffers[bufnr] then
        populate_netrw_icons(bufnr)
      end
      netrw_redraw_timers[bufnr] = nil
    end, 100)
  end)
end

--- Wrap netrw's built-in toggle keys so icons are redrawn
--- after the tree structure changes. Each keypress feeds the
--- original netrw <Plug> mapping, then schedules a redraw.
function setup_netrw_toggle_hooks(bufnr)
  -- Keys that change the tree structure in netrw
  local toggle_keys = { '<CR>', 'o', '-', 'u', 'gn' }
  for _, key in ipairs(toggle_keys) do
    local ok, orig = pcall(vim.fn.maparg, key, 'n', false, true, bufnr)
    if ok and orig and type(orig) == 'table' and orig.rhs and orig.rhs ~= '' then
      local rhs = orig.rhs
      pcall(vim.keymap.set, 'n', key, function()
        -- Feed the original netrw mapping rhs as keys.
        -- When this function returns, the fed keys are processed,
        -- then vim.schedule fires, then defer_fn runs the redraw.
        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes(rhs, true, false, true),
          'n', false
        )
        schedule_netrw_redraw(bufnr)
      end, { buffer = bufnr, remap = false })
    end
  end
end
