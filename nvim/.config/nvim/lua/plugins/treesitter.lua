vim.pack.add({
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
}, { confirm = false })

local parsers = {
	"lua",
	"c_sharp",
	"json",
	"markdown",
	"markdown_inline",
	"query",
	"vim",
	"vimdoc",
}
local treesitter = require("nvim-treesitter")
treesitter.install(parsers)

local function attach(buf, language)
	if not vim.treesitter.language.add(language) then
		return
	end

	vim.treesitter.start(buf, language)
	if vim.treesitter.query.get(language, "indents") then
		vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end
end

local available_parsers = treesitter.get_available()
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter-attach", { clear = true }),
	callback = function(args)
		local language = vim.treesitter.language.get_lang(args.match)
		if not language then
			return
		end

		local installed = treesitter.get_installed("parsers")
		if vim.tbl_contains(installed, language) then
			attach(args.buf, language)
		elseif vim.tbl_contains(available_parsers, language) then
			treesitter.install(language):await(function()
				attach(args.buf, language)
			end)
		else
			attach(args.buf, language)
		end
	end,
})
