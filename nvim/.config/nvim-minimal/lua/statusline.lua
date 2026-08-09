local modes = {
	n = "NORMAL",
	i = "INSERT",
	v = "VISUAL",
	V = "V-LINE",
	["\22"] = "V-BLOCK",
	c = "COMMAND",
	t = "TERMINAL",
	R = "REPLACE",
	s = "SELECT",
	S = "S-LINE",
	["\19"] = "S-BLOCK",
}

local function git_info()
	local branch = vim.b.gitsigns_head
	if not branch then
		local dir = vim.fn.expand("%:p:h")
		if dir == "" then
			return nil, nil
		end
		local out = vim.fn.systemlist({
			"git",
			"-C",
			dir,
			"branch",
			"--show-current",
		})
		branch = vim.v.shell_error == 0 and out[1] or nil
	end
	if not branch or branch == "" then
		return nil, nil
	end
	local root_out = vim.fn.systemlist({
		"git",
		"-C",
		vim.fn.expand("%:p:h"),
		"rev-parse",
		"--show-toplevel",
	})
	local root = vim.v.shell_error == 0 and root_out[1] or nil
	return branch, root
end

function _G.render_statusline()
	local mode = modes[vim.fn.mode()] or vim.fn.mode():upper()
	local branch, root = git_info()
	local git = branch and (" %#StlGit# " .. branch .. " %*") or ""

	local path
	if root and root ~= "" then
		local full = vim.fn.expand("%:p")
		path = full:sub(1, #root + 1) == (root .. "/") and full:sub(#root + 2) or vim.fn.expand("%:~")
	else
		path = vim.fn.expand("%:~")
	end

	local diag = ""
	local counts = vim.diagnostic.count(0) or {}
	local labels = { "E", "W", "I", "H" }
	local hls = { "DiagnosticError", "DiagnosticWarn", "DiagnosticInfo", "DiagnosticHint" }
	for i = 1, 4 do
		if counts[i] and counts[i] > 0 then
			diag = diag .. "%#" .. hls[i] .. "#" .. labels[i] .. counts[i] .. "%* "
		end
	end

	return "%#StatusLineMode# " .. mode .. " %*" .. git .. " " .. path .. "%=" .. diag .. vim.bo.filetype .. " %l:%c"
end

vim.o.statusline = "%!v:lua.render_statusline()"

vim.api.nvim_create_autocmd("DiagnosticChanged", {
	callback = function()
		vim.cmd("redrawstatus!")
	end,
})
