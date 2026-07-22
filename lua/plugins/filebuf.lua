return {
  "HuntFeng/filebuf.nvim",
	config = function()
		require("filebuf").setup()
		vim.keymap.set("n", "<leader>e", "<cmd>Filebuf<cr>", { desc = "Open filebuf" })
	end,
}
