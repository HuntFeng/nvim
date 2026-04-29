return {
	"kiyoon/jupynium.nvim",
	build = "pip3 install --user .",
	event = { "BufReadPre *.ipynb", "BufReadPre *.ju.py" },
	config = function()
		require("jupynium").setup({
			auto_download_ipynb = false,
			use_default_keybindings = false,
			autoscroll = { focus = "output" },
		})
		vim.api.nvim_create_user_command("JupyniumStart", function()
			local filename_wo_ext = vim.fs.basename(vim.fn.expand("%:r:r"))
			vim.cmd([[JupyniumStartSync ]] .. filename_wo_ext)
		end, {})

		vim.api.nvim_create_autocmd("BufReadPost", {
			pattern = { "*.ipynb", "*.ju.py" },
			callback = function(args)
				local buf_id = args.buf

				vim.keymap.set(
					{ "n", "x" },
					"<space>x",
					"<cmd>JupyniumExecuteSelectedCells<CR>",
					{ buffer = buf_id, desc = "Jupynium execute selected cells" }
				)
				vim.keymap.set(
					{ "n", "x" },
					"zz",
					"zz:JupyniumScrollToCell<cr>",
					{ buffer = buf_id, desc = "Jupynium scroll to cell", noremap = true }
				)
				vim.keymap.set(
					{ "n", "x" },
					"zo",
					"<cmd>JupyniumScrollToOutput<cr>",
					{ buffer = buf_id, desc = "Jupynium scroll to cell output" }
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
			end,
		})
	end,
}
