vim.pack.add({ "https://github.com/lewis6991/gitsigns.nvim" }, { confirm = false })

require("gitsigns").setup({
	on_attach = function(bufnr)
		local gitsigns = require("gitsigns")

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
		end

		map("n", "]h", function()
			gitsigns.nav_hunk("next")
		end, "Git: next hunk")
		map("n", "[h", function()
			gitsigns.nav_hunk("prev")
		end, "Git: previous hunk")
	end,
})
