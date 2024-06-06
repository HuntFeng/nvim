return {
	"VonHeikemen/lsp-zero.nvim",
	branch = "v3.x",
	dependencies = {
		"neovim/nvim-lspconfig",
	},
	event = "BufReadPre",
	config = function()
		local lsp_zero = require("lsp-zero")
		lsp_zero.extend_lspconfig() -- must call this before the language server is manged by mason rather than manual config
		lsp_zero.on_attach(function(client, bufnr)
			lsp_zero.default_keymaps({ buffer = bufnr })
		end)
		lsp_zero.set_sign_icons({
			error = "",
			warn = "",
			info = "",
			hint = "",
		})
		lsp_zero.format_on_save({
			servers = {
				["null-ls"] = {
					"html",
					"css",
					"javascript",
					"less",
					"json",
					"vue",
					"javascriptreact",
					"typescriptreact",
					"jsonc",
					"yaml",
					"markdown.mdx",
					"graphql",
					"handlebars",
					"svelte",
					"astro",
					"markdown",
					"typescript",
					"scss",
					"lua",
					"luau",
					"c",
					"cs",
					"java",
					"cuda",
					"proto",
					"cpp",
					"python",
				},
			},
		})
	end,
}
