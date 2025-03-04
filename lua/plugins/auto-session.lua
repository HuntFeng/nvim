return {
	"rmagatti/auto-session",
	cond = function()
		return not vim.g.vscode
	end,
	config = function()
		vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal,localoptions"
		require("auto-session").setup({
			log_level = "error",
			auto_session_suppress_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
			session_lens = {
				load_on_setup = false,
			},
		})
	end,
}
