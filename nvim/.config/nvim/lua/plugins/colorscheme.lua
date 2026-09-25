vim.pack.add({
	{ src = "https://github.com/bjarneo/aether.nvim", name = "aether", version = "v3" },
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
}, { confirm = false, load = false })

require("kanagawa").setup({})

require("omarchy_theme").setup({
	fallback = "kanagawa-wave",
})
