return {
	-- "HuntFeng/filebuf.nvim",
	dir = "~/projects/filebuf.nvim",
	config = function()
		require("filebuf").setup()
		vim.keymap.set("n", "<leader>e", "<cmd>Filebuf<cr>", { desc = "Open filebuf" })
	end,
}
