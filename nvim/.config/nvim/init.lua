vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.loader.enable()

require("options")
require("keymaps")
require("autocmds")
require("diagnostics")
require("colors")
require("pack")
require("plugins")
require("formatting")
require("lsp")
