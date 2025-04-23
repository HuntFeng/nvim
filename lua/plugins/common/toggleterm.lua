return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cmd = { "ToggleTerm", "TermExec" },
		init = function()
			vim.keymap.set(
				{ "n", "t" },
				"<C-/>",
				"<cmd>ToggleTerm size=10 direction=horizontal<CR>",
				{ desc = "ToggleTerm horizontal split" }
			)
		end,
		config = true,
	},
}
