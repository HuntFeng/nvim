return {
	"echasnovski/mini.pairs",
	version = false,
	event = "VeryLazy",
	opts = {
		mappings = {
			["\\("] = { action = "open", pair = "\\(\\)", neigh_pattern = "[^\\]" },
			["\\["] = { action = "open", pair = "\\[\\]", neigh_pattern = "[^\\]" },
		},
	},
}
