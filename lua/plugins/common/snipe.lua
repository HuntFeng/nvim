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
		hints = {
			-- Charaters to use for hints (NOTE: make sure they don't collide with the navigation keymaps)
			dictionary = "qwertyuiop",
		},
	},
}
