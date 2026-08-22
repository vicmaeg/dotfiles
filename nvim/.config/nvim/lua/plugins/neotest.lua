vim.pack.add({
	{ src = "https://github.com/nvim-neotest/neotest" },
	{ src = "https://github.com/nsidorenco/neotest-vstest" },
}, { confirm = false })

vim.g.neotest_vstest = {
	-- Avoid recursive solution scans when Neovim is opened from a broad directory.
	broad_recursive_discovery = false,
	dap_settings = { type = "netcoredbg" },
}

local neotest = require("neotest")
neotest.setup({
	adapters = {
		require("neotest-vstest"),
	},
})

vim.keymap.set("n", "<leader>tt", neotest.summary.toggle, { desc = "Tests: toggle summary" })
vim.keymap.set("n", "<leader>tr", function()
	neotest.run.run()
end, { desc = "Tests: run nearest" })
vim.keymap.set("n", "<leader>tf", function()
	neotest.run.run(vim.fn.expand("%"))
end, { desc = "Tests: run file" })
vim.keymap.set("n", "<leader>td", function()
	neotest.run.run({ strategy = "dap" })
end, { desc = "Tests: debug nearest" })
vim.keymap.set("n", "<leader>to", neotest.output.open, { desc = "Tests: show output" })
