return {
	-- display image in neovim
	"3rd/image.nvim",
	build = false,
	opts = {},
	config = function()
		package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua"
		package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua"
		require("image").setup({
			backend = "kitty",
			max_width_window_percentage = 100,
			max_height_window_percentage = 100,
			window_overlap_clear_enabled = true,
			integrations = {
				typst = {
					enabled = false,
				},
			},
		})
	end,
}
