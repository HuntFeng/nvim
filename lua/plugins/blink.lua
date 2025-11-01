return {
	{
		"github/copilot.vim",
		event = "BufWinEnter",
		init = function()
			vim.g.copilot_no_maps = true
		end,
		config = function()
			-- block the normal copilot suggestions
			vim.api.nvim_create_augroup("github_copilot", { clear = true })
			vim.api.nvim_create_autocmd({ "FileType", "BufUnload" }, {
				group = "github_copilot",
				callback = function(args)
					vim.fn["copilot#On" .. args.event]()
				end,
			})
			vim.fn["copilot#OnFileType"]()
		end,
	},
	{
		"saghen/blink.cmp",
		dependencies = {
			"rafamadriz/friendly-snippets",
			"fang2hou/blink-copilot",
		},
		event = "VeryLazy",
		version = "1.*",
		opts = {
			-- All presets have the following mappings:
			-- C-space: Open menu or open docs
			-- C-n/C-p or Up/Down or Tab/S-Tab: Select next/previous item
			-- C-e: Hide menu
			-- C-k: Toggle signature help
			-- C-y/<CR> to accept
			-- See :h blink-cmp-config-keymap for defining your own keymap
			keymap = {
				preset = "default",
				["<CR>"] = { "accept", "fallback" },
				["<C-u>"] = { "scroll_documentation_up", "fallback" },
				["<C-d>"] = { "scroll_documentation_down", "fallback" },
				["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
				["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			},
			completion = {
				documentation = { auto_show = true },
				list = { selection = { preselect = false, auto_insert = false } },
			},
			signature = { enabled = true },
			sources = {
				default = { "lsp", "buffer", "snippets", "path", "copilot" },
				providers = {
					copilot = {
						name = "copilot",
						module = "blink-copilot",
						score_offset = 100,
						async = true,
					},
				},
			},
		},
		opts_extend = { "sources.default" },
	},
}
