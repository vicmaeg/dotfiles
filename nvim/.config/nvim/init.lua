vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Disable optional remote providers that are not used by this config.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

vim.loader.enable()

require("options")
require("keymaps")
require("autocmds")
require("cmdline")
require("diagnostics")
require("pack")
require("plugins")
require("formatting")
require("lsp")
