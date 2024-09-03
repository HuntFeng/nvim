return {
	"numToStr/Comment.nvim",
	lazy = true,
	init = function()
		require("Comment").setup()
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
