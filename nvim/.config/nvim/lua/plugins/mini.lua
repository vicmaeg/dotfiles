vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" }, { confirm = false })

require("mini.icons").setup()
require("mini.ai").setup()
require("mini.surround").setup()
require("mini.completion").setup({
	window = {
		info = { border = "rounded" },
		signature = { border = "rounded" },
	},
})
require("mini.diff").setup()
vim.keymap.set("n", "<leader>gd", function()
	MiniDiff.toggle_overlay()
end, { desc = "Git: toggle diff overlay" })
require("mini.jump").setup()
require("mini.jump2d").setup()
require("mini.statusline").setup({ use_icons = true })
require("mini.files").setup({
	options = {
		use_as_default_explorer = true,
	},
})

vim.keymap.set("n", "<leader>e", function()
	local path = vim.api.nvim_buf_get_name(0)
	require("mini.files").open(path ~= "" and path or vim.uv.cwd())
end, { desc = "Files: current file" })

vim.keymap.set("n", "<leader>E", function()
	local root = vim.fs.root(0, { ".git" }) or vim.uv.cwd()
	require("mini.files").open(root)
end, { desc = "Files: project root" })
