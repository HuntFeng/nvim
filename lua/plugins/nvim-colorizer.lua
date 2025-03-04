return {
	"norcalli/nvim-colorizer.lua",
	cond = function()
		return not vim.g.vscode
	end,
	config = function()
		require("colorizer").setup()
	end,
	ft = { "html", "vue", "css", "scss", "less", "sass" },
}
