return {
	{
		"github/copilot.vim",
		event = "BufWinEnter",
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			"rafamadriz/friendly-snippets",
		},
		event = "VeryLazy",
		version = "1.*",
		opts = {
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs
			-- C-n/C-p or Up/Down
			-- C-e: Hide menu
			-- C-k: Toggle signature help
			-- C-y/<CR> to accept
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<Tab>"] = { "snippet_forward", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "fallback" },
			},
			completion = {
				documentation = { auto_show = true },
				list = { selection = { preselect = false, auto_insert = false } },
			},
			signature = { enabled = true },
			sources = {
				default = { "lsp", "buffer", "snippets", "path" },
			},
		},
		opts_extend = { "sources.default" },
	},
}
