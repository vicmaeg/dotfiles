vim.pack.add({ "https://github.com/stevearc/oil.nvim" }, { confirm = false })

require("oil").setup({
	default_file_explorer = true,
	view_options = { show_hidden = true },
})

vim.keymap.set("n", "-", function()
	require("oil").open()
end, { desc = "Oil: parent of current file" })

vim.keymap.set("n", "<leader>e", function()
	local root = vim.fs.root(0, { ".git" }) or vim.uv.cwd()
	require("oil").open(root)
end, { desc = "Oil: project root" })
