vim.pack.add({ "https://github.com/craftzdog/solarized-osaka.nvim" }, { confirm = false })

require("solarized-osaka").setup({
	transparent = false,
	terminal_colors = true,
})

vim.cmd.colorscheme("solarized-osaka")
