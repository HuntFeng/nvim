return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "williamboman/mason.nvim", config = true },
			{ "williamboman/mason-lspconfig.nvim" },
		},
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("mason").setup({
				ui = {
					border = "single",
				},
			})

			require("mason-lspconfig").setup({
				ensure_installed = {
					-- lsps
					"lua_ls",
					"pyright",
					"ts_ls",
					"volar",
					"rust_analyzer",
					"clangd",
					"cmake",
					"tinymist",
					"marksman",
				},
			})

			local lspconfig = require("lspconfig")

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
				ts_ls = {},
				volar = {},
				rust_analyzer = {},
				clangd = {},
				tinymist = {},
				marksman = {},
			}

			for name, config in pairs(servers) do
				lspconfig[name].setup(config)
			end

			-- Keymaps
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "LSP Hover" })
			vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { desc = "LSP Signature Help" })
			vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Go to Defininition" })
			vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { desc = "Code Action" })
			vim.keymap.set("n", "<leader>lR", vim.lsp.buf.rename, { desc = "Rename Symbol" })
			vim.keymap.set("n", "<leader>lf", function()
				require("conform").format({ async = true, lsp_fallback = true })
			end, { desc = "Format code" })

			vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
			vim.lsp.handlers["textDocument/signatureHelp"] =
				vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		opts = {
			ensure_installed = {
				-- Formatters:
				"stylua",
				"black",
				"isort",
				"prettierd",
				"clang-format",
				"cmakelang",
				"typstfmt",
				"taplo",
			},
			auto_update = true,
			run_on_start = true,
		},
	},
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
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
					typst = { "typstfmt" },
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
