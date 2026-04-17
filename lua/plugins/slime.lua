return {
	"jpalardy/vim-slime",
	config = function()
		vim.g.slime_target = "wezterm"
		vim.g.slime_default_config = {
			pane_direction = "right",
		}
		vim.g.slime_bracketed_paste = 1
	end,
}
