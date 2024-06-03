local colors = require("tokyonight.colors").setup()
local ViMode = {
	init = function(self)
		self.mode = vim.fn.mode(1) -- :h mode()
	end,
	static = {
		mode_names = {
			n = "Normal",
			v = "Visual",
			V = "Visual",
			i = "Insert",
			R = "Replace",
			c = "Command",
			s = "Select",
		},
	},
	provider = function(self)
		print("mode = ", self.mode)
		local mode = self.mode:sub(1, 1)
		return " " .. self.mode_names[mode] .. " "
	end,
	hl = { bg = colors.blue, fg = colors.bg_dark, bold = true },
	update = {
		"ModeChanged",
		pattern = "*:*",
		callback = vim.schedule_wrap(function()
			vim.cmd("redrawstatus")
		end),
	},
}
return ViMode
