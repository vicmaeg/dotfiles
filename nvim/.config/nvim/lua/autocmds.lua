local augroup = vim.api.nvim_create_augroup("yank-highlight-restore-cursor", { clear = true })

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup,
	callback = function()
		vim.hl.on_yank({ timeout = 200, visual = true })
	end,
})

-- Wrap markdown so long lines stay on screen
vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("markdown-wrap", { clear = true }),
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false

		local opts = { buffer = true }
		vim.keymap.set({ "n", "x" }, "j", "gj", opts)
		vim.keymap.set({ "n", "x" }, "k", "gk", opts)
	end,
})

-- Restore cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup,
	callback = function(args)
		local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
		local line_count = vim.api.nvim_buf_line_count(args.buf)
		if mark[1] > 0 and mark[1] <= line_count then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
			vim.schedule(function()
				vim.cmd("normal! zz")
			end)
		end
	end,
})
