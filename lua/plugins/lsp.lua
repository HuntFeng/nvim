return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v3.x",
		dependencies = {
			"neovim/nvim-lspconfig",
		},
		lazy = true,
		init = function()
			-- Disable automatic setup, we are doing it manually
			vim.g.lsp_zero_extend_cmp = 0
			vim.g.lsp_zero_extend_lspconfig = 0
			require("lsp-zero").set_sign_icons({
				error = "",
				warn = "",
				info = "",
				hint = "",
			})
		end,
	},
	{
		-- mason for handling the language servers
		"jay-babu/mason-null-ls.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"nvimtools/none-ls.nvim",
			"williamboman/mason-lspconfig.nvim",
		},
		lazy = false,
		config = function()
			-- lsp zero
			local lsp_zero = require("lsp-zero")
			lsp_zero.extend_lspconfig() -- must call this before the language server is manged by mason rather than manual config
			lsp_zero.on_attach(function(client, bufnr)
				lsp_zero.default_keymaps({
					buffer = bufnr,
					exclude = { "gs" }, -- reserve this for mini.surround
					-- vim.keymap.set("n", "gS", function()
					-- 	vim.lsp.buf.signature_help()
					-- end, { desc = "Show function signature help" }),
				})
			end)
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
						"gdscript",
					},
					["texlab"] = { "tex" },
				},
			})

			-- use mason to manage language servers
			require("mason").setup({
				ui = {
					border = "rounded",
				},
			})

			-- setup prettierd formatter and eslint_d linter
			require("mason-null-ls").setup({
				handlers = {},
			})

			-- setup language servers
			require("mason-lspconfig").setup({
				ensure_installed = {},
				handlers = {
					function(server_name)
						local lspconfig = require("lspconfig")
						-- use volar only for vue file
						local opts = {}
						if server_name == "tsserver" then
							local mason_registry = require("mason-registry")
							local vue_language_server_path =
								mason_registry.get_package("vue-language-server"):get_install_path()
							opts = {
								init_options = {
									plugins = {
										{
											name = "@vue/typescript-plugin",
											location = vue_language_server_path,
											languages = { "vue" },
										},
									},
								},
							}
						elseif server_name == "volar" then
							opts = {
								init_options = {
									vue = {
										hybridMode = false,
									},
								},
							}
						elseif server_name == "clangd" then
							-- do this otherwise neovim warns about the multiple offset-encoding is not supported
							opts = {
								cmd = {
									"clangd",
									"--offset-encoding=utf-16",
								},
							}
						end
						lspconfig[server_name].setup(opts)
					end,
				},
			})

			-- null-ls for formatting
			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					null_ls.builtins.formatting.gdformat,
				},
			})
		end,
	},
}
