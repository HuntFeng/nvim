local colors = require("tokyonight.colors").setup()
local Ruler = {
	provider = " %l:%c %P ",
	hl = { fg = colors.bg_dark, bg = colors.blue },
}
return Ruler
