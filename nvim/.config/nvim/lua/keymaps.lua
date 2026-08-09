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

-- git
map("n", "<leader>gg", ":Git<cr>", { desc = "Git status (fugitive)" })
map("n", "<leader>gd", ":DiffviewToggle<cr>", { desc = "Diff view (diffview+)" })
map("n", "<leader>gR", function()
	vim.cmd("silent! checktime") -- reload buffers changed on disk
	pcall(vim.cmd, "DiffviewRefresh") -- no-op outside a diffview
end, { desc = "Refresh diff view + reload changed files" })

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
