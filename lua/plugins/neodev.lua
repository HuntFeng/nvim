return {
	"folke/neodev.nvim",
	cond = function()
		return not vim.g.vscode
	end,
	opts = {},
}
