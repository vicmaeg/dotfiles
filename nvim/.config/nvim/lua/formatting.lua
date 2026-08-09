local M = {}

M.external = {
	lua = "stylua -",
}

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("format-on-save", { clear = true }),
	callback = function(args)
		local bufnr = args.buf
		local ft = vim.bo[bufnr].filetype
		local cmd = M.external[ft]

		if cmd and vim.fn.executable(vim.split(cmd, " ")[1]) == 1 then
			local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
			local output = vim.fn.system(cmd, table.concat(lines, "\n"))
			if vim.v.shell_error == 0 then
				local formatted = vim.split(output, "\n", { plain = true })
				if formatted[#formatted] == "" then
					table.remove(formatted)
				end
				vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
			else
				vim.notify("Formatter failed: " .. cmd, vim.log.levels.WARN)
			end
			return
		end

		for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
			if client:supports_method("textDocument/formatting") then
				vim.lsp.buf.format({ bufnr = bufnr, async = false })
				return
			end
		end
	end,
})

return M
