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

		require("which-key").add({
			{ "<leader>f", group = "Find" },
			{ "<leader>fw", "<cmd>FzfLua live_grep<cr>", desc = "Grep (rg)" },
			{ "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
			{ "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Files" },
			{ "<leader>fm", "<cmd>FzfLua marks<cr>", desc = "Marks" },
			{ "<leader>fq", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix List" },
			{ "<leader>fr", "<cmd>FzfLua lsp_references<cr>", desc = "LSP References" },
			{ "<leader>fi", "<cmd>FzfLua lsp_incoming_calls<cr>", desc = "LSP Incoming Calls" },
			{ "<leader>fo", "<cmd>FzfLua lsp_outgoing_calls<cr>", desc = "LSP Outgoing Calls" },
			{ "<leader>fs", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "LSP Workspace Symbols" },
			{ "<leader>fd", "<cmd>FzfLua lsp_workspace_diagnostics<cr>", desc = "LSP Diagnostics" },
		})
		-- vim.keymap.set("n", "<Tab>", "<cmd>FzfLua buffers<cr>", { desc = "Buffers" })
	end,
}
