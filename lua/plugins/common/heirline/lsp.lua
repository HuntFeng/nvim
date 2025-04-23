local conditions = require("heirline.conditions")
local colors = require("tokyonight.colors").setup()
local LSPActive = {
	condition = conditions.lsp_attached,
	update = { "LspAttach", "LspDetach" },
	provider = "  LSP ",
	on_click = {
		callback = function()
			vim.defer_fn(function()
				vim.cmd("LspInfo")
			end, 100)
		end,
		name = "heirline_LSP",
	},
	hl = { fg = colors.blue, bg = colors.fg_gutter },
}
return LSPActive
