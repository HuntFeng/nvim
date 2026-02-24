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
			provider = function(selector)
				local picker = require("core.fuzzyfind").picker

				-- Convert avante.ui.SelectorItem to picker format
				local picker_items = {}
				for _, item in ipairs(selector.items) do
					table.insert(picker_items, {
						id = item.id,
						text = item.title,
						label = item.title,
					})
				end

				picker(picker_items, {
					title = selector.title or " Select Provider ",
					on_select = function(selected_item, index)
						if selected_item then
							local selected_id = selected_item.id
							selector.on_select({ selected_id })
						else
							selector.on_select(nil)
						end
					end,
				})
			end,
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
	},
}
