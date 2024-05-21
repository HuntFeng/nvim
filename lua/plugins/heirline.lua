return {
	"rebelot/heirline.nvim",
	-- You can optionally lazy-load heirline on UiEnter
	-- to make sure all required plugins and colorschemes are loaded before setup
	-- event = "UiEnter",
	config = function()
		local conditions = require("heirline.conditions")
		local Git = {
			condition = conditions.is_git_repo,
			init = function(self)
				self.status_dict = vim.b.gitsigns_status_dict
				print("hear", self.status_dict.removed)
			end,

			{ -- git branch name
				provider = function(self)
					return " " .. self.status_dict.head
				end,
				hl = { bold = true },
			},
		}
		local LSPActive = {
			condition = conditions.lsp_attached,
			update = { "LspAttach", "LspDetach" },
			provider = function()
				local names = {}
				for i, server in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
					table.insert(names, server.name)
				end
				return "LSP [" .. table.concat(names, " ") .. "]"
			end,
			hl = { fg = "green", bold = true },
		}

		-- We're getting minimalist here!
		local Ruler = {
			provider = "%7%l:%2c %P",
		}

		local Diagnostics = {

			condition = conditions.has_diagnostics,

			static = {
				error_icon = "E",
				warn_icon = "W",
				info_icon = "I",
				hint_icon = "H",
			},

			init = function(self)
				self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
				self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
				self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
				self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
			end,

			update = { "DiagnosticChanged", "BufEnter" },

			{
				provider = function(self)
					-- 0 is just another output, we can decide to print it or not!
					return self.errors > 0 and (self.error_icon .. self.errors .. " ")
				end,
				hl = { fg = "red" },
			},
			{
				provider = function(self)
					return self.warnings > 0 and (self.warn_icon .. self.warnings .. " ")
				end,
				hl = { fg = "yellow" },
			},
			{
				provider = function(self)
					return self.info > 0 and (self.info_icon .. self.info .. " ")
				end,
				hl = { fg = "green" },
			},
			{
				provider = function(self)
					return self.hints > 0 and (self.hint_icon .. self.hints)
				end,
				hl = { fg = "cyan" },
			},
		}

		local Space = { provider = " " }
		require("heirline").setup({
			statusline = {
				Git,
				Space,
				Diagnostics,
				Space,
				LSPActive,
				Space,
				Ruler,
			},
		})
	end,
}
