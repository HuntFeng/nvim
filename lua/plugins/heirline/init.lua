return {
	"rebelot/heirline.nvim",
	-- You can optionally lazy-load heirline on UiEnter
	-- to make sure all required plugins and colorschemes are loaded before setup
	-- event = "UiEnter",
	config = function()
		local Vimode = require("plugins.heirline.vimode")
		local Git = require("plugins.heirline.git")
		local Diagnostics = require("plugins.heirline.diagnostics")
		local LSPActive = require("plugins.heirline.lsp")
		local Ruler = require("plugins.heirline.ruler")
		local Align = { provider = "%=" }
		local BufferLine = require("plugins.heirline.tabline")
		local FileNameBlock = require("plugins.heirline.file")

		require("heirline").setup({
			-- statusline = {
			-- 	Vimode,
			-- 	Git,
			-- 	FileNameBlock,
			-- 	Align,
			-- 	Diagnostics,
			-- 	LSPActive,
			-- 	Ruler,
			-- },
			tabline = { BufferLine },
		})
	end,
}
