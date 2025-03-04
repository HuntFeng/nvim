return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		cond = function()
			return not vim.g.vscode
		end,
		cmd = { "ToggleTerm", "TermExec" },
		config = true,
	},
}
