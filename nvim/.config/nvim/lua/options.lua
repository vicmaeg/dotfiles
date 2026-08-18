local o = vim.opt

o.number = true
o.relativenumber = true
o.mouse = "a"
o.showmode = false
o.signcolumn = "yes"
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.autoread = true
o.breakindent = true
o.updatetime = 250
o.timeoutlen = 300
o.inccommand = "split"
o.confirm = true

o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.softtabstop = -1

o.laststatus = 3
o.splitright = true
o.splitbelow = true
o.scrolloff = 4
o.wrap = false
o.cursorline = true
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

o.completeopt = { "menuone", "noselect", "fuzzy", "popup" }
o.winborder = "rounded"

o.wildmode = "noselect:lastused,full"
o.wildoptions = "pum"

if vim.fn.executable("rg") == 1 then
	o.grepprg = "rg --vimgrep"
	o.grepformat = "%f:%l:%c:%m"
end


vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)
