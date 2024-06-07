local colors = require("tokyonight.colors").setup()
local Ruler = {
	condition = function(self)
		return vim.api.nvim_get_option_value("buftype", { buf = self.bufnr }) ~= "terminal"
	end,
	provider = " %l:%c %P ",
	hl = { fg = colors.bg_dark, bg = colors.blue },
}
return Ruler
