return {
	"rebelot/heirline.nvim",
	-- You can optionally lazy-load heirline on UiEnter
	-- to make sure all required plugins and colorschemes are loaded before setup
	-- event = "UiEnter",
	config = function()
		local Vimode = require("plugins.common.heirline.vimode")
		local Git = require("plugins.common.heirline.git")
		local Diagnostics = require("plugins.common.heirline.diagnostics")
		local LSPActive = require("plugins.common.heirline.lsp")
		local Ruler = require("plugins.common.heirline.ruler")
		local Align = { provider = "%=" }
		local BufferLine = require("plugins.common.heirline.tabline")
		local FileNameBlock = require("plugins.common.heirline.file")
		local SearchCount = require("plugins.common.heirline.search-count")

		require("heirline").setup({
			statusline = {
				Vimode,
				-- Git,
				FileNameBlock,
				Align,
				-- Diagnostics,
				-- LSPActive,
				SearchCount,
				Ruler,
			},
			-- tabline = { BufferLine },
		})
	end,
}
