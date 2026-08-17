local map = vim.keymap.set

-- fzf-lua
map("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "Buffers" })

-- org
map("n", "<leader>of", function()
	require("fzf-lua").files({ cwd = "~/org" })
end, { desc = "Find org files" })

-- git
map("n", "<leader>gg", ":Git<cr>", { desc = "Git status (fugitive)" })

-- oil
map("n", "-", function()
	require("oil").open()
end, { desc = "Oil: parent of current file" })
map("n", "<leader>e", function()
	local root = vim.fs.root(0, { ".git" }) or vim.uv.cwd()
	require("oil").open(root)
end, { desc = "Oil: project root" })

-- LSP
map("n", "grd", "<C-]>", { desc = "Go to definition" })
map("n", "<leader>ld", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end, { desc = "Diagnostics to quickfix" })

-- dap
map("n", "<F5>", function()
	require("dap").continue()
end, { desc = "Debug: start/continue" })
map("n", "<F10>", function()
	require("dap").step_over()
end, { desc = "Debug: step over" })
map("n", "<F11>", function()
	require("dap").step_into()
end, { desc = "Debug: step into" })
map("n", "<F12>", function()
	require("dap").step_out()
end, { desc = "Debug: step out" })
map("n", "<leader>b", function()
	require("dap").toggle_breakpoint()
end, { desc = "Debug: toggle breakpoint" })
map("n", "<leader>B", function()
	require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: conditional breakpoint" })
map("n", "<leader>dq", function()
	require("dap").terminate()
end, { desc = "Debug: terminate" })
map("n", "<leader>dr", function()
	require("dap").repl.toggle()
end, { desc = "Debug: toggle REPL" })
map("n", "<leader>du", function()
	require("dapui").toggle()
end, { desc = "Debug: toggle UI" })

-- easy-dotnet
map("n", "<leader>tt", function()
	vim.cmd("Dotnet testrunner")
end, { desc = "Dotnet: toggle test runner" })

-- window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
