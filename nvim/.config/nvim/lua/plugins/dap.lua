vim.pack.add({
	"https://github.com/mfussenegger/nvim-dap",
	"https://github.com/rcarriga/nvim-dap-ui",
	"https://github.com/nvim-neotest/nvim-nio",
}, { confirm = false })

local dap = require("dap")
local dapui = require("dapui")

dap.adapters.netcoredbg = function(callback)
	local command = vim.fn.exepath("netcoredbg")
	if command == "" then
		vim.notify(
			"netcoredbg is required to debug .NET tests; install it and ensure it is on PATH",
			vim.log.levels.ERROR
		)
		return
	end

	callback({
		type = "executable",
		command = command,
		args = { "--interpreter=vscode" },
	})
end

dapui.setup()
dap.listeners.after.event_initialized["dapui_config"] = dapui.open
dap.listeners.before.event_terminated["dapui_config"] = dapui.close
dap.listeners.before.event_exited["dapui_config"] = dapui.close

vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: start/continue" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Debug: step into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: step out" })
vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, { desc = "Debug: toggle breakpoint" })
vim.keymap.set("n", "<leader>B", function()
	dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: conditional breakpoint" })
vim.keymap.set("n", "<leader>dq", dap.terminate, { desc = "Debug: terminate" })
vim.keymap.set("n", "<leader>dr", dap.repl.toggle, { desc = "Debug: toggle REPL" })
vim.keymap.set("n", "<leader>du", dapui.toggle, { desc = "Debug: toggle UI" })
