vim.pack.add({
	"https://github.com/tpope/vim-fugitive",
	"https://github.com/tpope/vim-surround",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/stevearc/oil.nvim",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/dlyongemallo/diffview-plus.nvim",
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { confirm = false })

require("fzf-lua").setup({ fzf_colors = true })

require("oil").setup({
	default_file_explorer = true, -- take over directory buffers (netrw's job)
	view_options = { show_hidden = true },
})

require("gitsigns").setup({
	on_attach = function(bufnr)
		local g = require("gitsigns")
		local map = function(mode, lhs, rhs)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr })
		end
		map("n", "]h", function()
			g.nav_hunk("next")
		end)
		map("n", "[h", function()
			g.nav_hunk("prev")
		end)
	end,
})

require("diffview").setup({
	use_icons = false, -- no devicons/mini.icons installed
})

require("nvim-treesitter").setup({
	ensure_install = {
		"lua",
		"c_sharp",
		"json",
		"markdown",
		"markdown_inline",
		"query",
		"vim",
		"vimdoc",
	},
	highlight = { enable = true },
})
