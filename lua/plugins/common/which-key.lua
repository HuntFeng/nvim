return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		local wk = require("which-key")
		wk.add({
			{ "<leader>L", "<cmd>Lazy<cr>", desc = "Lazy" },
			{
				"<leader>e",
				function()
					require("neo-tree.command").execute({ toggle = true, reveal = true })
				end,
				desc = "Neotree Toggle",
			},
			{ "<leader>l", group = "LSP" },
			{
				"<leader>lR",
				function()
					vim.lsp.buf.rename()
				end,
				desc = "LSP Rename",
			},
			{
				"<leader>la",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "LSP Action",
			},
			{
				"<leader>lf",
				function()
					vim.lsp.buf.format()
				end,
				desc = "Format Code",
			},
			{
				"<leader>li",
				function()
					vim.lsp.buf.incoming_calls()
				end,
				desc = "LSP Incoming Calls",
			},
			{
				"<leader>lr",
				function()
					vim.lsp.buf.references()
				end,
				desc = "LSP References",
			},
			{ "<leader>lI", "<cmd>LspInfo<cr>", desc = "LSP Info" },
			{ "<leader>ll", "<cmd>LspLog<cr>", desc = "LSP Log" },
			{
				"<leader>lR",
				function()
					vim.lsp.buf.rename()
				end,
				desc = "Rename Symbol",
			},
			{ "<leader>w", "<cmd>w<cr>", desc = "Save File" },
			{ "<localleader>l", "VimTex", group = "VimTex" },
			{ "<leader>n", group = "neogen" },
			{
				"<leader>nf",
				function()
					require("neogen").generate({ type = "func" })
				end,
				desc = "Function Doc String",
			},
			{
				"<leader>nc",
				function()
					require("neogen").generate({ type = "class" })
				end,
				desc = "Class Doc String",
			},
			{
				"<leader>nt",
				function()
					require("neogen").generate({ type = "type" })
				end,
				desc = "Type Doc String",
			},
			{
				"<leader>nm",
				function()
					require("neogen").generate({ type = "file" })
				end,
				desc = "Module/File Doc String",
			},
		})
	end,
}
