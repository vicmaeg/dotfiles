vim.pack.add({
	{ src = "https://github.com/bjarneo/aether.nvim", name = "aether", version = "v3" },
	"https://github.com/bjarneo/hackerman.nvim",
	"https://github.com/EdenEast/nightfox.nvim",
	"https://github.com/ellisonleao/gruvbox.nvim",
	"https://github.com/ficcdaf/ashen.nvim",
	"https://github.com/folke/tokyonight.nvim",
	"https://github.com/kepano/flexoki-neovim",
	"https://github.com/neanias/everforest-nvim",
	"https://github.com/omacom-io/lumon.nvim",
	"https://github.com/OldJobobo/retro-82.nvim",
	"https://github.com/rebelot/kanagawa.nvim",
	"https://github.com/ribru17/bamboo.nvim",
	{ src = "https://github.com/rose-pine/neovim", name = "rose-pine" },
	"https://github.com/tahayvr/matteblack.nvim",
}, { confirm = false, load = false })

require("kanagawa").setup({})

require("omarchy_theme").setup({
	fallback = "kanagawa-wave",
})
