return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local npairs = require("nvim-autopairs")
		local Rule = require("nvim-autopairs.rule")
		npairs.setup({})
		npairs.add_rules({
			Rule("$", "$", "tex"),
			Rule("```", "```", "quarto"),
		})
	end,
}
