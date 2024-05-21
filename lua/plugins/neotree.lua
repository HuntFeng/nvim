return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
	},
	config = function()
		require("neo-tree").setup({
			window = {
				position = "float",
				width = 10,
				mappings = {
					["h"] = "close_node",
					["l"] = "open",
				},
			},
		})
	end,
}
