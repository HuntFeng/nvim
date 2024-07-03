return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		{
			"L3MON4D3/LuaSnip",
			dependencies = { "rafamadriz/friendly-snippets" },
		},
	},
	event = "InsertEnter",
	config = function()
		-- define keymaps for autocomplete
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } }) -- load custom snippets
		require("luasnip.loaders.from_vscode").lazy_load() -- load friendly-snippets
		local cmp = require("cmp")
		local cmp_format = require("lsp-zero").cmp_format({ details = true })
		cmp.setup({
			window = {
				completion = cmp.config.window.bordered(),
			},
			mapping = {
				["<cr>"] = cmp.mapping.confirm({ select = false }),
				["<esc>"] = cmp.mapping.abort(),
				["<Up>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
				["<Down>"] = cmp.mapping.select_next_item({ behavior = "select" }),
				["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
				["<Tab>"] = cmp.mapping.select_next_item({ behavior = "select" }),
			},
			sources = {
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
				{ name = "buffer" },
				{ name = "path" },
			},
			snippet = {
				-- required - must specify a snippet engine
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			--- (Optional) Show source name in completion menu
			formatting = cmp_format,
			experimental = {
				ghost_text = true,
			},
		})
	end,
}
