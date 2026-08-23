vim.pack.add({
	"https://github.com/GustavEikaas/easy-dotnet.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
}, { confirm = false })

local initialized = false

vim.api.nvim_create_user_command("EasyDotnet", function()
	if initialized then
		vim.notify("easy-dotnet is already initialized; use :Dotnet testrunner", vim.log.levels.INFO)
		return
	end

	require("easy-dotnet").setup({
		picker = "fzf",
		-- Roslyn, ProjX, project mappings, and debugger registration are owned by
		-- the dedicated LSP and nvim-dap configurations.
		lsp = { enabled = false },
		projx_lsp = { enabled = false },
		debugger = { auto_register_dap = false },
		test_runner = {
			auto_start_testrunner = false,
			mappings = {
				debug_test_from_buffer = { lhs = "<leader>td", desc = "Tests: debug nearest" },
				-- vim-test owns test execution; park easy-dotnet's buffer-local
				-- run/peek mappings on untypable <Plug> keys.
				run_test_from_buffer = { lhs = "<Plug>(easy-dotnet-run-test)" },
				run_all_tests_from_buffer = { lhs = "<Plug>(easy-dotnet-run-all-tests)" },
				peek_stack_trace_from_buffer = { lhs = "<Plug>(easy-dotnet-peek-stacktrace)" },
			},
		},
		csproj_mappings = false,
		fsproj_mappings = false,
		enable_filetypes = false,
		auto_bootstrap_namespace = { enabled = false },
	})

	initialized = true
	vim.notify("easy-dotnet initialized; use :Dotnet testrunner", vim.log.levels.INFO)
end, { desc = "Initialize easy-dotnet on demand" })

-- Lazy-initialize easy-dotnet (starts its server + discovery) only when the
-- testrunner or test debugging is actually needed.
vim.keymap.set("n", "<leader>tt", function()
	if not initialized then
		vim.cmd("EasyDotnet")
	end
	require("easy-dotnet").testrunner()
end, { desc = "Tests: toggle easy-dotnet testrunner" })
