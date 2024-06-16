local port = os.getenv("GDScript_Port") or "6005"
local cmd = vim.lsp.rpc.connect("127.0.0.1", port)
local pipe = "/tmp/godot.pipe" -- I use /tmp/godot.pipe
vim.lsp.start({
	name = "gdscript",
	cmd = cmd,
	root_dir = vim.fs.dirname(vim.fs.find({ "project.godot", ".git" }, { upward = true })[1]),
})

-- In Godot, set Exec Flags of external editor to this
-- server /tmp/godot.pipe --remote-send"<esc>:n {file}<CR>:call cursor({line},{col})<CR>"
if not vim.loop.fs_stat(pipe) then
	vim.fn.serverstart(pipe)
end
