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
			e = { "<cmd>Neotree toggle<cr>", "NeoTree" },
			-- lazy
			L = { "<cmd>Lazy<cr>", "Lazy" },
			-- telescope
			f = {
				name = "File",
				f = { "<cmd>Telescope find_files<cr>", "Find Files" },
				F = {
					function()
						require("telescope.builtin").find_files({ no_ignore = true })
					end,
					"Find All Files",
				},
				w = { "<cmd>Telescope live_grep<cr>", "Live Grep" },
			},
			-- lsp
			l = {
				name = "LSP",
				i = { "<cmd>LspInfo<cr>", "LSP Info" },
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
				d = { "<cmd>Telescope diagnostics", "Diagnostics" },
			},
			-- save file
			w = { "<cmd>w<cr>", "Save File" },
		}, { prefix = "<leader>" })

		wk.register({
			l = { name = "VimTex", "VimTex", "VimTex" },
		}, { prefix = "<localleader>" })
	end,
}
