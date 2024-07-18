-- better UI for command line, search, and messages
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("noice").setup({
			cmdline = {
				view = "cmdline",
				format = {
					cmdline = false,
					filter = false,
					lua = false,
					help = false,
					input = false,
					search_up = false,
					search_down = false,
				},
			},
			-- make messages blends into the background
			views = {
				-- hover documentation / signature
				hover = {
					size = {
						max_width = 50,
						max_height = 10,
					},
				},
				mini = {
					win_options = {
						winblend = 0,
					},
				},
			},
			-- better lsp documentation
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			health = {
				checker = false,
			},
		})
	end,
}
