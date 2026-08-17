vim.pack.add({ "https://github.com/tpope/vim-fugitive" }, { confirm = false })

vim.keymap.set("n", "<leader>gg", "<cmd>Git<cr>", { desc = "Git status (fugitive)" })
