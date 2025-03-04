return {
	"chomosuke/typst-preview.nvim",
	cond = function()
		return not vim.g.vscode
	end,
	ft = "typst",
	version = "0.3.*",
	build = function()
		require("typst-preview").update()
	end,
}
