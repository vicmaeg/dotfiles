vim.pack.add({
	"https://github.com/rebelot/kanagawa.nvim",
}, { confirm = false })

require("kanagawa").setup({})
vim.cmd.colorscheme("kanagawa-wave")
