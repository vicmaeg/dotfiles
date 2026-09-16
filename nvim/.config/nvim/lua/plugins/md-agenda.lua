vim.pack.add({ "https://github.com/zenarvus/md-agenda.nvim" }, { confirm = false })

local notebook_dir = vim.fs.normalize("~/org")

require("md-agenda").setup({
	agendaFiles = {
		notebook_dir .. "/tasks.md",
		notebook_dir .. "/projects",
		notebook_dir .. "/areas",
	},
	dashboard = {
		{
			"Overdue",
			{
				{ type = { "TODO" }, tags = {}, deadline = "past", scheduled = "" },
			},
		},
		{
			"Today",
			{
				{ type = { "TODO" }, tags = {}, deadline = "today", scheduled = "" },
				{ type = { "TODO" }, tags = {}, deadline = "", scheduled = "today" },
			},
		},
		{
			"All open tasks",
			{
				{ type = { "TODO" }, tags = {}, deadline = "", scheduled = "" },
			},
		},
	},
})

local map = vim.keymap.set

map("n", "<leader>at", function()
	vim.cmd.edit(vim.fn.fnameescape(notebook_dir .. "/tasks.md"))
end, { desc = "Agenda: global tasks" })
map("n", "<leader>aa", "<cmd>AgendaView<cr>", { desc = "Agenda: timeline" })
map("n", "<leader>ad", "<cmd>AgendaDashboard<cr>", { desc = "Agenda: dashboard" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("md-agenda-keymaps", { clear = true }),
	pattern = "markdown",
	callback = function(args)
		local path = vim.api.nvim_buf_get_name(args.buf)
		if path:sub(1, #notebook_dir + 1) ~= notebook_dir .. "/" then
			return
		end

		local opts = { buffer = args.buf }
		map("n", "<leader>ac", "<cmd>CheckTask<cr>",
			vim.tbl_extend("force", opts, { desc = "Agenda: complete task" }))
		map("n", "<leader>ax", "<cmd>CancelTask<cr>",
			vim.tbl_extend("force", opts, { desc = "Agenda: cancel task" }))
		map("n", "<leader>as", "<cmd>TaskScheduled<cr>",
			vim.tbl_extend("force", opts, { desc = "Agenda: schedule task" }))
		map("n", "<leader>aD", "<cmd>TaskDeadline<cr>",
			vim.tbl_extend("force", opts, { desc = "Agenda: set deadline" }))
		map("n", "<leader>ap", "<cmd>UpdateProgress<cr>",
			vim.tbl_extend("force", opts, { desc = "Agenda: update progress" }))
	end,
})
