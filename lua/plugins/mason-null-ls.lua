return {
	"jay-babu/mason-null-ls.nvim",
	dependencies = {
		"williamboman/mason.nvim",
		"nvimtools/none-ls.nvim",
		"williamboman/mason-lspconfig.nvim",
	},
	event = "BufReadPre",
	config = function()
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
					end
					lspconfig[server_name].setup(opts)
				end,
			},
		})

		-- null-ls for formatting
		require("null-ls").setup({})
	end,
}
