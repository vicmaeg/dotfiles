local map = vim.keymap.set

-- fzf-lua
map("n", "<leader>ff", function()
	require("fzf-lua").files()
end, { desc = "Find files" })
map("n", "<leader>fg", function()
	require("fzf-lua").live_grep()
end, { desc = "Live grep" })
map("n", "<leader>fb", function()
	require("fzf-lua").buffers()
end, { desc = "Buffers" })

-- org
map("n", "<leader>of", function()
	require("fzf-lua").files({ cwd = "~/org" })
end, { desc = "Find org files" })

-- git
map("n", "<leader>gg", ":Git<cr>", { desc = "Git status (fugitive)" })

-- oil
map("n", "-", function()
	require("oil").open()
end, { desc = "Oil: parent of current file" })
map("n", "<leader>e", function()
	local root = vim.fs.root(0, { ".git" }) or vim.uv.cwd()
	require("oil").open(root)
end, { desc = "Oil: project root" })

-- diagnostics
map("n", "<leader>d", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end, { desc = "Diagnostics to quickfix" })

-- window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
