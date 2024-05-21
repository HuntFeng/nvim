local conditions = require("heirline.conditions")
local colors = require("tokyonight.colors").setup()
local Git = {
	condition = conditions.is_git_repo,
	init = function(self)
		self.status_dict = vim.b.gitsigns_status_dict
	end,
	{
		provider = function(self)
			return "  " .. self.status_dict.head .. " "
		end,
		hl = { fg = colors.blue, bg = colors.fg_gutter, bold = true },
	},
}

return Git
