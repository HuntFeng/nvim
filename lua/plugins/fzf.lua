return {
	"ibhagwan/fzf-lua",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	event = "VeryLazy",
	config = function()
		require("fzf-lua").setup({
			grep = {
				formatter = "path.filename_first",
				hls = { dir_part = "Comment" },
				fzf_opts = {
					["--delimiter"] = "[\t:]",
					["--with-nth"] = "1..3", -- only show icon, filename, path and line
				},
			},
			files = {
				formatter = "path.filename_first",
				hls = { dir_part = "Comment" },
				winopts = {
					height = 0.5,
					width = 0.3,
					preview = {
						hidden = true,
					},
				},
			},
			args = {
				formatter = "path.filename_first",
				hls = { dir_part = "Comment" },
				winopts = {
					height = 0.5,
					width = 0.3,
					preview = {
						hidden = true,
					},
				},
			},
			buffers = {
				formatter = "path.filename_first",
				hls = { dir_part = "Comment" },
				sort_lastused = false,
				fzf_opts = {
					["--delimiter"] = "[\t ]+",
					["--with-nth"] = "3..", -- only show icon, filename and path
				},
				winopts = {
					height = 0.5,
					width = 0.3,
					preview = {
						hidden = true,
					},
				},
			},
			lsp = {
				formatter = "path.filename_first",
				hls = { dir_part = "Comment" },
				fzf_opts = {
					["--delimiter"] = "[\t:]",
					["--with-nth"] = "1..3", -- only show icon, filename, path and line
				},
			},
		})

		vim.keymap.set("n", "<leader>fw", "<cmd>FzfLua live_grep<cr>", { desc = "Grep (rg)" })
		vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
		vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Files" })
		vim.keymap.set("n", "<leader>fm", "<cmd>FzfLua marks<cr>", { desc = "Marks" })
		vim.keymap.set("n", "<leader>fq", "<cmd>FzfLua quickfix<cr>", { desc = "Quickfix List" })
		vim.keymap.set("n", "<leader>fr", "<cmd>FzfLua lsp_references<cr>", { desc = "LSP References" })
		vim.keymap.set("n", "<leader>fi", "<cmd>FzfLua lsp_incoming_calls<cr>", { desc = "LSP Incoming Calls" })
		vim.keymap.set("n", "<leader>fo", "<cmd>FzfLua lsp_outgoing_calls<cr>", { desc = "LSP Outgoing Calls" })
		vim.keymap.set("n", "<leader>fs", "<cmd>FzfLua lsp_workspace_symbols<cr>", { desc = "LSP Workspace Symbols" })
		vim.keymap.set("n", "<leader>fd", "<cmd>FzfLua lsp_workspace_diagnostics<cr>", { desc = "LSP Diagnostics" })
		-- vim.keymap.set("n", "<Tab>", "<cmd>FzfLua args<cr>", { desc = "Args list" })
		vim.keymap.set("n", "<Tab>", "<cmd>FzfLua buffers<cr>", { desc = "Buffer list" })
	end,
}
