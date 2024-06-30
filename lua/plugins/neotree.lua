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
			init = function()
				package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
				package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"
			end,
			opts = {
				backend = "kitty",
				max_width = 100,
				max_height = 12,
				max_height_window_percentage = math.huge,
				max_width_window_percentage = math.huge,
				window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
				window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
			},
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
