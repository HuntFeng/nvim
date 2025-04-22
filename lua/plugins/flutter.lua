return {
	"nvim-flutter/flutter-tools.nvim",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"mfussenegger/nvim-dap",
	},
	opts = {
		lsp = { settings = { lineLength = 120 } },
	},
	config = true,
}
