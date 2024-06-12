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
				f = { "<cmd>Telescope git_files<cr>", "Find Git Files" },
				F = { "<cmd>Telescope find_files<cr>", "Find All Files" },
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
						vim.lsp.buf.format()
					end,
					"Rename Symbol",
				},
			},
			-- save file
			w = { "<cmd>w<cr><esc>", "Save File" },
		}, { prefix = "<leader>" })
	end,
}
