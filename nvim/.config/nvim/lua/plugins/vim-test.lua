vim.pack.add({
	{ src = "https://github.com/vim-test/vim-test" },
}, { confirm = false })

-- Run the real `dotnet test` CLI in a reusable terminal split: full raw output,
-- searchable, and `gf`-friendly on stack-trace paths.
vim.g["test#strategy"] = "neovim_sticky"
vim.g["test#csharp#runner"] = "dotnettest"

vim.keymap.set("n", "<leader>tr", "<cmd>TestNearest<cr>", { desc = "Tests: run nearest" })
vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<cr>", { desc = "Tests: run last" })
vim.keymap.set("n", "<leader>ts", "<cmd>TestSuite<cr>", { desc = "Tests: run suite" })
