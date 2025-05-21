return {
	"leath-dub/snipe.nvim",
	keys = {
		{
			"<leader>b",
			function()
				require("snipe").open_buffer_menu()
			end,
			desc = "Open Snipe buffer menu",
		},
	},
	opts = {
		ui = {
			position = "center",
			text_align = "file-first",
		},
		hints = {
			-- Charaters to use for hints (NOTE: make sure they don't collide with the navigation keymaps)
			dictionary = "qwertyuiop",
		},
	},
}
