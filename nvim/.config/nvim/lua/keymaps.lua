local map = vim.keymap.set

-- LSP
map("n", "grd", "<C-]>", { desc = "Go to definition" })
map("n", "<leader>ld", function()
	vim.diagnostic.setqflist()
	vim.cmd("copen")
end, { desc = "Diagnostics to quickfix" })

-- window navigation
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("n", "<C-h>", "<C-w>h", { desc = "Move to the left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to the lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to the upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to the right window" })
