local M = {}

M.external = {
	lua = { "stylua", "-" },
}

local function apply_diff(bufnr, before, after)
	local hunks = vim.text.diff(table.concat(before, "\n") .. "\n", table.concat(after, "\n") .. "\n", {
		algorithm = "histogram",
		result_type = "indices",
	})

	for i = #hunks, 1, -1 do
		local start_before, count_before, start_after, count_after = unpack(hunks[i])
		local first = count_before == 0 and start_before or start_before - 1
		local replacement = count_after == 0 and {} or vim.list_slice(after, start_after, start_after + count_after - 1)
		vim.api.nvim_buf_set_lines(bufnr, first, first + count_before, false, replacement)
	end
end

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("format-on-save", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local ft = vim.bo[bufnr].filetype
		local cmd = M.external[ft]

		if cmd and vim.fn.executable(cmd[1]) == 1 then
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local result = vim.system(cmd, { stdin = table.concat(lines, "\n"), text = true }):wait(5000)
			if result.code == 0 then
				local formatted = vim.split(result.stdout or "", "\n", { plain = true })
				if formatted[#formatted] == "" then
					table.remove(formatted)
				end
				apply_diff(bufnr, lines, formatted)
			else
				local message = vim.trim(result.stderr or "")
				vim.notify(message ~= "" and message or ("Formatter failed: " .. cmd[1]), vim.log.levels.WARN)
			end
			return
		end

		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client:supports_method("textDocument/formatting") then
				vim.lsp.buf.format({ bufnr = bufnr, id = client.id, async = false, timeout_ms = 3000 })
				return
			end
		end
	end,
})

return M
