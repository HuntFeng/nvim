return {
	{
		"nvim-flutter/flutter-tools.nvim",
		lazy = false,
		dependencies = {
			"nvim-lua/plenary.nvim",
		},
		opts = {
			lsp = {
				settings = { lineLength = 120 },
			},
			debugger = {
				enabled = true,
			},
			dev_log = {
				enabled = false,
			},
		},
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
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
	},
	{
		"vim-test/vim-test",
		config = function()
			local dap = require("dap")

			vim.g["test#custom_strategies"] = {
				dart_dap = function(cmd)
					-- Extract the test file and test name from the command
					local test_file = string.match(cmd, "test/[%w_/]+%.dart")
					local test_name = string.match(cmd, "%-%-plain%-name%s+'([^']+)'")

					if test_file == nil then
						print("Could not determine test file from command: " .. cmd)
						return
					end

					-- Configure the DAP adapter for Dart tests
					dap.adapters.flutter = {
						type = "executable",
						command = "flutter",
						args = { "debug-adapter", "--test" },
					}

					-- Set up the DAP configuration for the test
					dap.configurations.dart = {
						{
							type = "flutter",
							request = "launch",
							name = "Debug Flutter Test",
							program = test_file,
							args = {
								"--machine",
								"--start-paused",
								"--plain-name",
								test_name,
							},
							cwd = vim.fn.getcwd(),
						},
					}

					-- Start the debugging session
					dap.run(dap.configurations.dart[1])
				end,
			}

			-- Set the custom strategy as the default for Dart tests
			vim.g["test#strategy"] = "dart_dap"

			vim.keymap.set("n", "<leader>tn", ":TestNearest<CR>", { desc = "Run nearest test" })
			vim.keymap.set("n", "<leader>tf", ":TestFile<CR>", { desc = "Run tests in current file" })
			vim.keymap.set("n", "<leader>ts", ":TestSuite<CR>", { desc = "Run entire test suite" })
			vim.keymap.set("n", "<leader>tl", ":TestLast<CR>", { desc = "Run last test" })
			vim.keymap.set("n", "<leader>tv", ":TestVisit<CR>", { desc = "Visit test file" })
		end,
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"antoinemadec/FixCursorHold.nvim",
			"nvim-neotest/neotest-vim-test",
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-vim-test"),
				},
			})
		end,
	},
}
