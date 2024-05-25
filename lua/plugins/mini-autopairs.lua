return {
	"echasnovski/mini.pairs",
	version = false,
	events = "VeryLazy",
	config = function()
		require("mini.pairs").setup({
			mappings = {
				["\\["] = { action = "open", pair = "\\[\\]", neigh_pattern = "[^\\]" },
			},
		})
	end,
}
