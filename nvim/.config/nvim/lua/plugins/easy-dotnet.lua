vim.pack.add({
	"https://github.com/GustavEikaas/easy-dotnet.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
}, { confirm = false })

require("easy-dotnet").setup({
	picker = "fzf",
	test_runner = {
		mappings = {
			run_test_from_buffer = { lhs = "<leader>tr", desc = "run test from buffer" },
			run_all_tests_from_buffer = { lhs = "<leader>tf", desc = "run all tests in file" },
			debug_test_from_buffer = { lhs = "<leader>td", desc = "debug test from buffer" },
			peek_stack_trace_from_buffer = { lhs = "<leader>tp", desc = "peek stack trace from buffer" },
			get_build_errors = { lhs = "<leader>te", desc = "get build errors" },
		},
	},
})

vim.keymap.set("n", "<leader>tt", "<cmd>Dotnet testrunner<cr>", { desc = "Dotnet: toggle test runner" })
