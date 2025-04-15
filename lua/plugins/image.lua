return {
	{
		"vhyrro/luarocks.nvim",
		priority = 1001, -- this plugin needs to run before anything else
		opts = {
			rocks = { "magick" },
		},
	},
	{
		"3rd/image.nvim",
		dependencies = { "luarocks.nvim" },
		opts = {},
		config = function()
			require("image").setup({
				backend = "kitty",
				max_width_window_percentage = 100,
				max_height_window_percentage = 100,
				window_overlap_clear_enabled = true,
				scale_factor = 2.0,
				integrations = {
					typst = {
						enabled = false,
					},
				},
			})
		end,
	},
}
