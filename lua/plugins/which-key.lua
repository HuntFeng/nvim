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
					require("neo-tree.command").execute({ toggle = true })
				end,
				desc = "Neotree Toggle",
			},
			{ "<leader>f", group = "Fuzzy Find" },
			{
				"<leader>fF",
				function()
					require("telescope.builtin").find_files({ no_ignore = true })
				end,
				desc = "Find All Files",
			},
			{
				"<leader>fb",
				function()
					require("telescope.builtin").buffers()
				end,
				desc = "Find Buffers",
			},
			{
				"<leader>ff",
				function()
					require("telescope.builtin").find_files()
				end,
				desc = "Find Files",
			},
			{
				"<leader>fw",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live Grep",
			},
			{ "<leader>l", group = "LSP" },
			{ "<leader>lR", "<cmd>LspRestart<cr>", desc = "LSP Restart" },
			{
				"<leader>la",
				function()
					vim.lsp.buf.code_action()
				end,
				desc = "LSP Action",
			},
			{
				"<leader>ld",
				function()
					require("telescope.builtin").diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>lf",
				function()
					vim.lsp.buf.format()
				end,
				desc = "Format Code",
			},
			{ "<leader>li", "<cmd>LspInfo<cr>", desc = "LSP Info" },
			{ "<leader>ll", "<cmd>LspLog<cr>", desc = "LSP Log" },
			{
				"<leader>lr",
				function()
					vim.lsp.buf.rename()
				end,
				desc = "Rename Symbol",
			},
			{ "<leader>lR", "<cmd>LspRestart<cr>", desc = "Rename Symbol" },
			{ "<leader>w", "<cmd>w<cr>", desc = "Save File" },
			{ "<localleader>l", "VimTex", group = "VimTex" },
		})
	end,
}
