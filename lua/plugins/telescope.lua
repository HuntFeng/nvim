return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	event = "VeryLazy",
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")

		telescope.setup({
			defaults = {
				path_display = { "filename_first" },
				mappings = {
					i = {
						["<C-k>"] = actions.move_selection_previous,
						["<C-j>"] = actions.move_selection_next,
						["<C-y>"] = actions.select_default,
					},
				},
				borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						preview_width = 0.5,
						width = 0.8,
						height = 0.8,
						prompt_position = "top",
					},
				},
				sorting_strategy = "ascending",
			},
		})

		vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>", { desc = "Find files" })
		vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>", { desc = "Live grep" })
		vim.keymap.set("n", "<tab>", "<cmd>Telescope buffers<cr>", { desc = "Buffers" })
	end,
}
