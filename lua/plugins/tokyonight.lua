return {
	"folke/tokyonight.nvim",
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
			on_highlights = function(hl)
				-- tokyonight doesn't define PmenuBorder; match the info popup's border
				hl.PmenuBorder = hl.FloatBorder
			end,
		})
		vim.cmd("colorscheme tokyonight")
	end,
}
