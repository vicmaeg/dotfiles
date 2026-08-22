vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
}, { confirm = false })

vim.lsp.enable({ "lua_ls", "roslyn_ls" })
