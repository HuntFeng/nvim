return {
	{
		"neovim/nvim-lspconfig",
		event = "VeryLazy",
		config = function()
			local servers = {
				lua_ls = {
					settings = {
						Lua = {
							diagnostics = {
								globals = { "vim" },
							},
							workspace = {
								checkThirdParty = false,
								library = vim.api.nvim_get_runtime_file("", true),
							},
							telemetry = { enable = false },
							runtime = { version = "LuaJIT" },
						},
					},
				},
				pyright = {},
				ts_ls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
						"vue",
					},
				},
				vue_ls = {},
				rust_analyzer = {},
				clangd = {},
				tinymist = {},
				marksman = {},
			}

			for name, config in pairs(servers) do
				-- vim.lsp.config finds configs in nvim-lspconfig and merge them with our custom config
				-- this includes filetypes so we don't need to worry about all lsp being enabled
				vim.lsp.config(name, config)
				vim.lsp.enable(name)
			end

			-- Keymaps
			vim.keymap.set("n", "K", vim.lsp.buf.hover)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition)
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration)
			vim.keymap.set("n", "grr", vim.lsp.buf.references)
			vim.keymap.set("n", "gri", vim.lsp.buf.implementation)
			vim.keymap.set("n", "gra", vim.lsp.buf.code_action)
			vim.keymap.set("n", "grn", vim.lsp.buf.rename)
			vim.keymap.set("n", "gO", vim.lsp.buf.outgoing_calls)
			vim.keymap.set("n", "gI", vim.lsp.buf.incoming_calls)
			vim.keymap.set("n", "gl", vim.diagnostic.open_float)
			vim.keymap.set("n", "<C-s>", vim.lsp.buf.signature_help)
		end,
	},
	-- mason and mason-tool-installer for easier installation of lsp servers and formatters
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim", config = true },
		opts = {
			auto_update = true,
			run_on_start = true,
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		config = function()
			require("conform").setup({
				format_on_save = {
					timeout_ms = 1000,
					lsp_fallback = true,
				},
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "black", "isort" },
					rust = { "rustfmt" },
					javascript = { "prettierd" },
					typescript = { "prettierd" },
					javascriptreact = { "prettierd" },
					typescriptreact = { "prettierd" },
					vue = { "prettierd" },
					css = { "prettierd" },
					html = { "prettierd" },
					json = { "prettierd" },
					yaml = { "prettierd" },
					markdown = { "prettierd" },
					cpp = { "clang_format" },
					c = { "clang_format" },
					typst = { "typstyle" },
					toml = { "taplo" },
				},
				formatters = {
					isort = {
						prepend_args = { "--profile", "black" },
					},
				},
			})
		end,
	},
}
