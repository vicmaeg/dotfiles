vim.g.diffs = {
	integrations = {
		fugitive = true,
		gitsigns = true,
	},
}

vim.pack.add({ "https://github.com/barrettruth/diffs.nvim" }, { confirm = false })
