return {
	"kiyoon/jupynium.nvim",
	opts = {
		auto_attach_to_server = {
			enable = true,
			file_pattern = { "*.ju.*" },
		},
		auto_start_sync = {
			enable = true,
			file_pattern = { "*.ju.*" },
		},
		use_default_keybindings = false,
		textobjects = { use_default_keymaps = false },
	},
	config = function()
		vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
			pattern = "*.ju.py",
			callback = function(event)
				local buf_id = event.buf
				vim.keymap.set(
					{ "n", "x" },
					"<leader>x",
					"<cmd>JupyniumExecuteSelectedCells<CR>",
					{ buffer = buf_id, desc = "Jupynium execute selected cells" }
				)
				vim.keymap.set(
					{ "n", "x" },
					"zz",
					"<cmd>JupyniumScrollToCell<cr>",
					{ buffer = buf_id, desc = "Jupynium scroll to cell" }
				)
				vim.keymap.set(
					{ "n", "x" },
					"zo",
					"<cmd>JupyniumToggleSelectedCellsOutputsScroll<cr>",
					{ buffer = buf_id, desc = "Jupynium toggle selected cell output scroll" }
				)
				vim.keymap.set(
					{ "n", "i", "x" },
					"zu",
					"<cmd>JupyniumScrollUp<cr>",
					{ buffer = buf_id, desc = "Jupynium scroll up" }
				)
				vim.keymap.set(
					{ "n", "i", "x" },
					"zd",
					"<cmd>JupyniumScrollDown<cr>",
					{ buffer = buf_id, desc = "Jupynium scroll down" }
				)
				-- text objects
				vim.keymap.set(
					{ "n", "x", "o" },
					"[c",
					"<cmd>lua require'jupynium.textobj'.goto_previous_cell_separator()<cr>",
					{ buffer = buf_id, desc = "Go to previous Jupynium cell" }
				)
				vim.keymap.set(
					{ "n", "x", "o" },
					"]c",
					"<cmd>lua require'jupynium.textobj'.goto_next_cell_separator()<cr>",
					{ buffer = buf_id, desc = "Go to next Jupynium cell" }
				)
				vim.keymap.set(
					{ "x", "o" },
					"ac",
					"<cmd>lua require'jupynium.textobj'.select_cell(true, false)<cr>",
					{ buffer = buf_id, desc = "Select around Jupynium cell" }
				)
				vim.keymap.set(
					{ "x", "o" },
					"ic",
					"<cmd>lua require'jupynium.textobj'.select_cell(false, false)<cr>",
					{ buffer = buf_id, desc = "Select inside Jupynium cell" }
				)
				vim.keymap.set(
					{ "x", "o" },
					"aC",
					"<cmd>lua require'jupynium.textobj'.select_cell(true, true)<cr>",
					{ buffer = buf_id, desc = "Select around Jupynium cell (include next cell separator)" }
				)
				vim.keymap.set(
					{ "x", "o" },
					"iC",
					"<cmd>lua require'jupynium.textobj'.select_cell(false, true)<cr>",
					{ buffer = buf_id, desc = "Select inside Jupynium cell (include next cell separator)" }
				)
			end,
		})
	end,
}
