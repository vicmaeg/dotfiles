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
		-- Roslyn, ProjX, project mappings, and debugger setup are owned by the
		-- dedicated LSP, Neotest, and nvim-dap configurations.
		lsp = { enabled = false },
		projx_lsp = { enabled = false },
		debugger = { auto_register_dap = false },
		test_runner = {
			auto_start_testrunner = false,
			neotest_integration = true,
		},
		csproj_mappings = false,
		fsproj_mappings = false,
		enable_filetypes = false,
		auto_bootstrap_namespace = { enabled = false },
	})

	initialized = true
	vim.notify("easy-dotnet initialized; use :Dotnet testrunner", vim.log.levels.INFO)
end, { desc = "Initialize easy-dotnet on demand" })
