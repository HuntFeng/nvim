return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
		{
			-- display image in neovim
			"3rd/image.nvim",
			config = function()
				package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
				package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"
				require("image").setup({
					backend = "kitty",
					max_width_window_percentage = 100,
					max_height_window_percentage = 100,
				})
			end,
		},
	},
	lazy = true,
	config = function()
		require("neo-tree").setup({
			window = {
				position = "float",
				-- use popup to set width since it's floating window
				popup = {
					size = {
						width = 35,
					},
				},
				mappings = {
					["h"] = "close_node",
					["l"] = "open",
				},
			},
			default_component_configs = {
				git_status = {
					symbols = {
						added = "N",
						modified = "M",
						deleted = "D",
						untracked = "",
						ignored = "",
						unstaged = "",
						staged = "",
						conflict = "",
					},
				},
			},
		})
	end,
}
