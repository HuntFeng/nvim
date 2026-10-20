vim.pack.add({ "https://github.com/HuntFeng/filebuf.nvim" })

require("filebuf").setup()
vim.keymap.set("n", "<leader>e", "<cmd>Filebuf<cr>", { desc = "Open filebuf" })
