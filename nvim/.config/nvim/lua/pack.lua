-- Update hooks for plugins managed by Neovim's built-in vim.pack.
vim.api.nvim_create_autocmd("PackChanged", {
	group = vim.api.nvim_create_augroup("pack-changed", { clear = true }),
	callback = function(event)
		local name = event.data.spec.name
		local kind = event.data.kind
		if kind ~= "install" and kind ~= "update" then
			return
		end

		if name == "nvim-treesitter" then
			if not event.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})
