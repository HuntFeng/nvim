return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
	end,
	config = function()
		local wk = require("which-key")
		wk.register({
			-- neotree
			e = {
				function()
					require("neo-tree.command").execute({ toggle = true })
				end,
				"Neotree Toggle",
			},
			-- lazy
			L = { "<cmd>Lazy<cr>", "Lazy" },
			-- telescope
			f = {
				name = "Fuzzy Find",
				b = {
					function()
						require("telescope.builtin").buffers()
					end,
					"Find Buffers",
				},
				f = {
					function()
						require("telescope.builtin").find_files()
					end,
					"Find Files",
				},
				F = {
					function()
						require("telescope.builtin").find_files({ no_ignore = true })
					end,
					"Find All Files",
				},
				w = {
					function()
						require("telescope.builtin").live_grep()
					end,
					"Live Grep",
				},
			},
			-- lsp
			l = {
				name = "LSP",
				i = { "<cmd>LspInfo<cr>", "LSP Info" },
				l = { "<cmd>LspLog<cr>", "LSP Log" },
				R = { "<cmd>LspRestart<cr>", "LSP Restart" },
				a = {
					function()
						vim.lsp.buf.code_action()
					end,
					"LSP Action",
				},
				f = {
					function()
						vim.lsp.buf.format()
					end,
					"Format Code",
				},
				r = {
					function()
						vim.lsp.buf.rename()
					end,
					"Rename Symbol",
				},
				d = {
					function()
						require("telescope.builtin").diagnostics()
					end,
					"Diagnostics",
				},
			},
			-- save file
			w = { "<cmd>w<cr>", "Save File" },
		}, { prefix = "<leader>" })

		wk.register({
			l = { name = "VimTex", "VimTex", "VimTex" },
		}, { prefix = "<localleader>" })
	end,
}
