return {
	"numToStr/Comment.nvim",
	dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
	lazy = true,
	init = function()
		require("Comment").setup({
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})
		vim.keymap.set("n", "<leader>/", function()
			return require("Comment.api").call(
				"toggle.linewise." .. (vim.v.count == 0 and "current" or "count_repeat"),
				"g@$"
			)()
		end, { silent = true, expr = true, desc = "Toggle Comment Line" })
		vim.keymap.set(
			"x",
			"<leader>/",
			"<Esc><Cmd>lua require('Comment.api').locked('toggle.linewise')(vim.fn.visualmode())<CR>",
			{ desc = "Toggle comment for selection" }
		)
	end,
}
