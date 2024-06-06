-- better UI for command line, search, and messages
return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
	},
	config = function()
		require("noice").setup({
			-- make messages blends into the background
			views = {
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
			presets = {
				bottom_search = false, -- a popup floating window for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				lsp_doc_border = true, -- use border on documentation
			},
			health = {
				checker = false,
			},
		})
	end,
}
