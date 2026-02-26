return {
	"yetone/avante.nvim",
	build = "make",
	event = "VeryLazy",
	version = false, -- Never set this value to "*"! Never!
	---@module 'avante'
	---@type avante.Config
	opts = {
		mode = "agentic",
		provider = "copilot",
		providers = {
			copilot = {
				endpoint = "https://api.githubcopilot.com",
				model = "gpt-4.1",
				timeout = 30000, -- Timeout in milliseconds
			},
		},
		behaviour = {
			support_paste_from_clipboard = true,
			auto_approve_tool_permissions = false,
			confirmation_ui_style = "popup",
		},
		selector = {
			---@param selector avante.ui.Selector
			provider = "telescope",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
}
