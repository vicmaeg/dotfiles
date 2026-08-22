vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" }, { confirm = false })

vim.env.RIPGREP_CONFIG_PATH = vim.fs.joinpath(vim.fn.stdpath("config"), "ripgreprc")

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
require("mini.pick").setup({
	window = {
		config = function()
			return { width = vim.o.columns }
		end,
	},
})
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

local pick = require("mini.pick")
vim.keymap.set("n", "<leader>ff", function()
	pick.builtin.files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function()
	pick.builtin.grep_live({ tool = "rg" })
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", function()
	pick.builtin.buffers()
end, { desc = "Find buffers" })
vim.keymap.set("n", "<leader>fh", function()
	pick.builtin.help()
end, { desc = "Find help" })
vim.keymap.set("n", "<leader>fr", function()
	pick.builtin.resume()
end, { desc = "Resume picker" })
vim.keymap.set("n", "<leader>of", function()
	pick.builtin.files(nil, { source = { cwd = vim.fs.normalize("~/org") } })
end, { desc = "Find org files" })
