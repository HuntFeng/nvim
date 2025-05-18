return {
	"olimorris/codecompanion.nvim",
	opts = {},
	dependencies = {
		"github/copilot.vim",
	},
	config = function()
		require("codecompanion").setup({
			adapters = {
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "claude-3.7-sonnet",
							},
						},
					})
				end,
			},
		})
	end,
}
