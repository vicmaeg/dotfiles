vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" }, { confirm = false })

require("fzf-lua").setup({
	"ivy",
	fzf_colors = true,
	winopts = {
		preview = { hidden = true },
	},
})

local fzf = require("fzf-lua")
vim.keymap.set("n", "<leader>ff", fzf.files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>of", function()
	fzf.files({ cwd = "~/org" })
end, { desc = "Find org files" })
