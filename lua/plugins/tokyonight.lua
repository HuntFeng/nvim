return {
	"folke/tokyonight.nvim",
	cond = function()
		return not vim.g.vscode
	end,
	lazy = false,
	priority = 1000,
	config = function()
		require("tokyonight").setup({
			style = "night",
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		})
		vim.cmd("colorscheme tokyonight")
	end,
}
