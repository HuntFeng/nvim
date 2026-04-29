-- local cell_mode = require("hydra")({
-- 	name = "Cell Mode",
-- 	mode = "n", -- Normal mode
-- 	body = "<Esc>", -- Keybinding to enter cell mode (can be any key combo)
-- 	config = {
-- 		invoke_on_body = true,
-- 		hint = { type = "cmdline" },
-- 	},
-- 	hint = "Cell Mode",
-- 	heads = {
-- 		{ "<Esc>", nil, { exit = true, desc = false } },
-- 		{
-- 			"j",
-- 			"<cmd>NBNextCell<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"k",
-- 			"<cmd>NBPrevCell<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"a",
-- 			"<cmd>NBAddCellAbove<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"b",
-- 			"<cmd>NBAddCellBelow<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"r",
-- 			"<cmd>NBRunCell<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"R",
-- 			function()
-- 				vim.cmd("NBRunCell")
-- 				vim.cmd("NBNextCell")
-- 			end,
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"d",
-- 			"<cmd>NBDeleteCell<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"y",
-- 			"<cmd>NBCopyCell<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"p",
-- 			"<cmd>NBPasteCell<cr>",
-- 			{ desc = false },
-- 		},
-- 		{
-- 			"o",
-- 			"<cmd>NBEnterCellOutput<cr>",
-- 			{ desc = false },
-- 		},
-- 	},
-- })
--
-- vim.keymap.set("n", "<Esc>", function()
-- 	vim.cmd("noh")
-- 	if vim.bo.filetype == "markdown" and vim.fn.expand("%:e") == "ipynb" then
-- 		cell_mode:activate()
-- 	end
-- end, { noremap = true, silent = true })

return {
	dir = "~/projects/ipynb.nvim",
	dependencies = {
		"jmbuhr/otter.nvim",
		"stevearc/conform.nvim",
		"nvimtools/hydra.nvim",
	},
	config = function()
		local otter = require("otter")
		otter.setup({
			lsp = {
				diagnostic_update_events = { "TextChanged" },
			},
		})
		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "*.ipynb",
			callback = function()
				vim.schedule(function()
					-- cell_mode:activate()
					otter.activate({ "markdown", "python" }, true, true, nil)
					vim.b.maplocalleader = ","
				end)

				require("which-key").add({
					{ "<localleader>r", "<cmd>NBRunCell<cr>", desc = "NBRunCell", buffer = true },
					{ "<localleader>R", "<cmd>NBRunAllCell<cr>", desc = "NBRunAllCell", buffer = true },
					{ "<c-enter>", "<cmd>NBRunCell<cr>", desc = "NBRunCell", buffer = true },
					{
						"<s-enter>",
						function()
							vim.cmd("NBRunCell")
							vim.cmd("NBNextCell")
						end,
						desc = "NBRunCellAndGotoNextCell",
						buffer = true,
					},
					{ "<localleader>o", "<cmd>NBEnterCellOutput<cr>", desc = "NBEnterCellOutput", buffer = true },
					{ "]c", "<cmd>NBNextCell<cr>", desc = "NBNextCell", buffer = true },
					{ "[c", "<cmd>NBPrevCell<cr>", desc = "NBPrevCell", buffer = true },
					{ "<localleader>a", "<cmd>NBAddCellAbove<cr>", desc = "NBAddCellAbove", buffer = true },
					{ "<localleader>b", "<cmd>NBAddCellBelow<cr>", desc = "NBAddCellBelow", buffer = true },
					{ "yc", "<cmd>NBCopyCell<cr>", desc = "NBCopyCell", buffer = true },
					{ "pc", "<cmd>NBPasteCell<cr>", desc = "NBPasteCell", buffer = true },
					{ "dc", "<cmd>NBDeleteCell<cr>", desc = "NBDeleteCell", buffer = true },
				})
			end,
		})

		-- vim.api.nvim_create_autocmd("BufLeave", {
		-- 	pattern = "*.ipynb",
		-- 	callback = function()
		-- 		cell_mode:exit()
		-- 	end,
		-- })

		require("ipynb").setup({
			image_scale_factor = 2.0,
		})
	end,
}
