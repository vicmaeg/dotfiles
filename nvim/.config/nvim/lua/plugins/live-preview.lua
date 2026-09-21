vim.pack.add({ "https://github.com/brianhuster/live-preview.nvim" }, { confirm = false })

require("livepreview.config").set({ picker = "fzf-lua" })

vim.keymap.set("n", "<leader>mp", "<cmd>LivePreview start<cr>", { desc = "Markdown: preview" })
vim.keymap.set("n", "<leader>ms", "<cmd>LivePreview close<cr>", { desc = "Markdown: stop preview" })
vim.keymap.set("n", "<leader>mf", "<cmd>LivePreview pick<cr>", { desc = "Markdown: pick preview file" })
