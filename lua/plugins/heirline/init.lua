return {
	"rebelot/heirline.nvim",
	-- You can optionally lazy-load heirline on UiEnter
	-- to make sure all required plugins and colorschemes are loaded before setup
	-- event = "UiEnter",
	config = function()
		local Git = require("plugins.heirline.git")
		local Diagnostics = require("plugins.heirline.diagnostics")
		local LSPActive = require("plugins.heirline.lsp")
		local Ruler = require("plugins.heirline.ruler")
		local Align = { provider = "%=" }
		local BufferLine = require("plugins.heirline.tabline")

		require("heirline").setup({
			statusline = {
				Git,
				Diagnostics,
				Align,
				LSPActive,
				Ruler,
			},
			tabline = { BufferLine },
		})
	end,
}
