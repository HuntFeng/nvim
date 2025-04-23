return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
	},
	event = "VeryLazy",
	config = function()
		local dap, dapui = require("dap"), require("dapui")
		dapui.setup()
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated.dapui_config = function()
			dapui.close()
		end
		dap.listeners.before.event_exited.dapui_config = function()
			dapui.close()
		end

		vim.keymap.set("n", "<leader>dt", function()
			dapui.toggle()
		end, { desc = "Toggle DAP UI" })
		vim.keymap.set("n", "<leader>db", function()
			dap.toggle_breakpoint()
		end, { desc = "Dap Toggle Breakpoint" })
		vim.keymap.set("n", "<leader>dC", function()
			dap.clear_breakpoints()
		end, { desc = "Dap Clear Breakpoints" })
		vim.keymap.set("n", "<leader>di", function()
			dap.step_into()
		end, { desc = "Dap Step Into" })
		vim.keymap.set("n", "<leader>do", function()
			dap.step_out()
		end, { desc = "Dap Step Out" })
		vim.keymap.set("n", "<leader>dc", function()
			dap.continue()
		end, { desc = "Dap Continue" })
	end,
}
