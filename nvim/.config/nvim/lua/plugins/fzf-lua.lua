vim.pack.add({ "https://github.com/ibhagwan/fzf-lua" }, { confirm = false })

require("fzf-lua").setup({
	"ivy",
	fzf_colors = true,
	winopts = {
		preview = { hidden = true },
	},
})

vim.keymap.set("n", "<leader>fz", "<cmd>FzfLua<cr>", { desc = "FzfLua: choose picker" })
