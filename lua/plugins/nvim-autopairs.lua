return {
	"windwp/nvim-autopairs",
	event = "InsertEnter",
	config = function()
		local npairs = require("nvim-autopairs")
		local Rule = require("nvim-autopairs.rule")
		npairs.setup({
			-- remove %$ from default so autopairs works normally in $$ in tex file
			ignored_next_char = [=[[%w%%%'%[%"%.%`]]=],
		})
		npairs.add_rules({
			Rule("$", "$", "tex"),
			Rule("\\(", "\\)", "tex"),
			Rule("\\[", "\\]", "tex"),
			Rule("```", "```", "quarto"),
		})
	end,
}
