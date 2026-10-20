vim.pack.add({
	"https://github.com/williamboman/mason.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/stevearc/conform.nvim",
})

require("mason").setup()

local servers = {
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				workspace = {
					checkThirdParty = false,
					library = vim.api.nvim_get_runtime_file("", true),
				},
				telemetry = { enable = false },
				runtime = { version = "LuaJIT" },
			},
		},
	},
	basedpyright = {
		settings = {
			basedpyright = {
				analysis = {
					typeCheckingMode = "basic",
					diagnosticSeverityOverrides = {
						reportUnusedVariable = "information",
						reportUnusedImport = "information",
						reportUnusedExpression = "information",
						reportUnusedFunction = "information",
						reportUnusedClass = "information",
						reportUnusedParameter = "information",
						reportUnusedCallResult = "information",
						reportArgumentType = "warning",
						reportReturnType = "warning",
					},
				},
			},
		},
	},
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
	csharp_ls = {},
	texlab = {},
	gdscript = {},
}

for name, config in pairs(servers) do
	-- nvim-lspconfig contributes each server's defaults to vim.lsp.config().
	vim.lsp.config(name, config)
	vim.lsp.enable(name)
end

vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Goto definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Goto declaration" })
vim.keymap.set("n", "grr", vim.lsp.buf.references, { desc = "Goto references" })
vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { desc = "Goto implementation" })
vim.keymap.set("n", "gra", vim.lsp.buf.code_action, { desc = "Code action" })
vim.keymap.set("n", "grn", vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set("n", "gO", vim.lsp.buf.outgoing_calls, { desc = "Goto outgoing calls" })
vim.keymap.set("n", "gI", vim.lsp.buf.incoming_calls, { desc = "Goto incoming calls" })
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "Open diagnostic" })
vim.keymap.set("i", "<C-s>", vim.lsp.buf.signature_help, { desc = "Signature help" })

require("conform").setup({
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
		cs = { "csharppier" },
		typst = { "typstyle" },
		toml = { "taplo" },
		tex = { "latexindent" },
	},
	formatters = {
		isort = { prepend_args = { "--profile", "black" } },
	},
})

vim.keymap.set("n", "grf", function()
	require("conform").format({ lsp_fallback = true })
end, { desc = "Format code" })
