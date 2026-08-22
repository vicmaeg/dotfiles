-- Cmdline autocompletion + extras (fuzzy :find, live :Grep)
-- https://neovim.io/doc/user/cmdline/#cmdline-autocompletion
-- https://neovim.io/doc/user/cmdline/#fuzzy-file-picker
-- https://neovim.io/doc/user/cmdline/#live-grep

local M = {}

local files_cache = {}
local selected = nil
local previous_pumheight = nil

local function system_lines(cmd, quiet)
	local result = vim.system(cmd, { text = true }):wait()
	if result.code ~= 0 and result.code ~= 1 then
		if not quiet then
			vim.notify(result.stderr or (cmd[1] .. " failed"), vim.log.levels.WARN)
		end
		return {}
	end

	return vim.split(result.stdout or "", "\n", { plain = true, trimempty = true })
end

function M.find(arg, _)
	if vim.tbl_isempty(files_cache) then
		if vim.fn.executable("rg") == 1 then
			files_cache = system_lines({ "rg", "--files", "--hidden", "--glob", "!.git" })
		else
			files_cache = vim.fn.globpath(".", "**", true, true)
			files_cache = vim.tbl_filter(function(path)
				return vim.fn.isdirectory(path) == 0
			end, files_cache)
			files_cache = vim.tbl_map(function(path)
				return vim.fn.fnamemodify(path, ":.")
			end, files_cache)
		end
	end
	if arg == "" then
		return files_cache
	end
	return vim.fn.matchfuzzy(files_cache, arg)
end

function M.grep(_, cmdline, cursorpos)
	local query = cmdline:sub(1, cursorpos - 1):match("^%s*Grep%s+(.+)$") or ""
	if #query <= 1 or vim.fn.executable("rg") ~= 1 then
		return {}
	end

	return system_lines({ "rg", "--vimgrep", "--smart-case", "--hidden", "--glob", "!.git", "--", query }, true)
end

function M.visit_file()
	if not selected then
		return
	end
	local items = vim.fn.getqflist({ lines = { selected } }).items
	if not items or not items[1] then
		return
	end
	local item = items[1]
	vim.cmd.buffer(item.bufnr)
	vim.bo[item.bufnr].buflisted = true
	pcall(vim.api.nvim_win_set_cursor, 0, { item.lnum, math.max(item.col - 1, 0) })
end

vim.o.findfunc = "v:lua.require'cmdline'.find"

vim.api.nvim_create_user_command("Grep", function()
	M.visit_file()
end, {
	nargs = "+",
	complete = function(arglead, cmdline, cursorpos)
		return M.grep(arglead, cmdline, cursorpos)
	end,
})

local augroup = vim.api.nvim_create_augroup("cmdline", { clear = true })

vim.api.nvim_create_autocmd("CmdlineChanged", {
	group = augroup,
	pattern = { ":", "/", "?" },
	callback = function()
		vim.fn.wildtrigger()
	end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = augroup,
	pattern = { "/", "?" },
	callback = function()
		previous_pumheight = vim.o.pumheight
		vim.o.pumheight = 8
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeave", {
	group = augroup,
	pattern = { "/", "?" },
	callback = function()
		if previous_pumheight ~= nil then
			vim.o.pumheight = previous_pumheight
			previous_pumheight = nil
		end
	end,
})

vim.api.nvim_create_autocmd("CmdlineEnter", {
	group = augroup,
	pattern = ":",
	callback = function()
		files_cache = {}
		selected = nil
	end,
})

vim.api.nvim_create_autocmd("CmdlineLeavePre", {
	group = augroup,
	pattern = ":",
	callback = function()
		local info = vim.fn.cmdcomplete_info()
		local matches = info.matches or {}
		local cmdline = vim.fn.getcmdline()

		if cmdline:match("^%s*Grep%s") then
			selected = nil
			if vim.tbl_isempty(matches) then
				return
			end

			-- Vim is 0-based for selected; Lua lists are 1-based.
			selected = matches[(info.selected == -1 and 0 or info.selected) + 1]
			vim.fn.setcmdline(info.cmdline_orig)
			return
		end

		if vim.tbl_isempty(matches) then
			return
		end

		if cmdline:match("^%s*fin[d]?%s") and info.selected == -1 then
			vim.fn.setcmdline("find " .. matches[1])
		end
	end,
})

return M
