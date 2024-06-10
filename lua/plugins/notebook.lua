return {
	{
		"GCBallesteros/jupytext.nvim",
		config = true,
	},
	{
		-- navigate, manipulate and run cells
		-- "HuntFeng/NotebookNavigator.nvim",
		dir = "~/projects/NotebookNavigator.nvim",
		dependencies = {
			"benlubas/molten-nvim",
			"anuvyklack/hydra.nvim",
		},
		event = "VeryLazy",
		ft = "python",
		keys = {
			{
				"]h",
				function()
					require("notebook-navigator").move_cell("d")
				end,
			},
			{
				"[h",
				function()
					require("notebook-navigator").move_cell("u")
				end,
			},
			{ "<leader>X", "<cmd>lua require('notebook-navigator').run_cell()<cr>" },
			{ "<leader>x", "<cmd>lua require('notebook-navigator').run_and_move()<cr>" },
		},
		config = function()
			local nn = require("notebook-navigator")
			nn.setup({ activate_hydra_keys = "<leader>h", repl_provider = "molten", syntax_highlight = true })
		end,
	},
	{
		-- molten as a code executer to run cells
		"benlubas/molten-nvim",
		version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
		build = ":UpdateRemotePlugins",
		dependencies = { "3rd/image.nvim" },
		event = "VeryLazy",
		ft = "python",
		init = function()
			package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
			package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"
			-- these are examples, not defaults. Please see the readme
			vim.g.molten_image_provider = "image.nvim"
			vim.g.molten_virt_text_output = true
			vim.g.molten_virt_lines_off_by_1 = false
			vim.g.molten_auto_open_output = false
		end,
	},
	{
		-- display image in neovim
		"3rd/image.nvim",
		opts = {
			backend = "kitty",
			max_width = 100,
			max_height = 12,
			max_height_window_percentage = math.huge,
			max_width_window_percentage = math.huge,
			window_overlap_clear_enabled = true, -- toggles images when windows are overlapped
			window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
		},
		ft = { "markdown", "python" },
	},
}
