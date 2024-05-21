return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
		{
			"jay-babu/mason-null-ls.nvim",
			event = { "BufReadPre", "BufNewFile" },
			dependencies = {
				"williamboman/mason.nvim",
				"nvimtools/none-ls.nvim",
			},
		},
		"williamboman/mason-lspconfig.nvim",
		"neovim/nvim-lspconfig",
		-- autocomplete
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/nvim-cmp",
		{ "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
	},
	config = function()
		local lsp_zero = require("lsp-zero")
		lsp_zero.extend_lspconfig() -- must call this before the language server is manged by mason rather than manual config
		lsp_zero.on_attach(function(client, bufnr)
			-- use default keymaps for lsp functions
			lsp_zero.default_keymaps({ buffer = bufnr })
		end)

		-- use mason to manage language servers
		require("mason").setup({})
		require("mason-null-ls").setup({
			handlers = {},
		})
		require("mason-lspconfig").setup({
			ensure_installed = {},
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,
			},
		})

		-- null-ls for formatting
		require("null-ls").setup({})
		lsp_zero.format_on_save({
			servers = {
				["null-ls"] = { "javascript", "typescript", "lua" },
			},
		})

		-- define keymaps for autocomplete
		local cmp = require("cmp")
		local cmp_format = require("lsp-zero").cmp_format({ details = true })
		require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } })
		-- require("luasnip.loaders.from_vscode").lazy_load()
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
				{ name = "luasnip" },
				{ name = "nvim_lsp" },
				{ name = "buffer" },
				{ name = "path" },
			},
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			--- (Optional) Show source name in completion menu
			formatting = cmp_format,
		})
	end,
}
