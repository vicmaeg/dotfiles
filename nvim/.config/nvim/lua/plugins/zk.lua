vim.pack.add({ "https://github.com/zk-org/zk-nvim" }, { confirm = false })

local notebook_dir = vim.fs.normalize("~/org")
vim.env.ZK_NOTEBOOK_DIR = notebook_dir

require("zk").setup({
	picker = "fzf_lua",
	lsp = {
		config = {
			name = "zk",
			cmd = { "zk", "lsp" },
			filetypes = { "markdown" },
		},
		auto_attach = {
			enabled = true,
		},
	},
	tags = {
		multi_select_strategy = "AND",
	},
})

local commands = require("zk.commands")
local completion = require("mini.completion")
local map = vim.keymap.set

local function process_completion_items(items, base)
	-- zk's text edit replaces the opening wiki-link delimiters, so mini.completion
	-- includes them in `base`. Remove them before filtering against note titles.
	local query = base:gsub("^%[%[", ""):gsub("^%(%(", "")
	return completion.default_process_items(items, query)
end

local function prompt_for_title()
	local title = vim.trim(vim.fn.input("Title: "))
	if title == "" then
		return nil
	end
	return title
end

local function new_note(dir)
	local title = prompt_for_title()
	if not title then
		return
	end
	commands.get("ZkNew")({ notebook_path = notebook_dir, dir = dir, title = title })
end

map("n", "<leader>nn", function()
	new_note(nil)
end, { desc = "Notes: new general note" })
map("n", "<leader>np", function()
	new_note("projects")
end, { desc = "Notes: new project" })
map("n", "<leader>na", function()
	new_note("areas")
end, { desc = "Notes: new area" })
map("n", "<leader>nd", function()
	commands.get("ZkNew")({ notebook_path = notebook_dir, dir = "daily" })
end, { desc = "Notes: today's daily note" })
map("n", "<leader>nf", function()
	commands.get("ZkNotes")({ notebook_path = notebook_dir, sort = { "modified" } })
end, { desc = "Notes: find" })
map("n", "<leader>ns", function()
	local query = vim.trim(vim.fn.input("Search notes: "))
	if query ~= "" then
		commands.get("ZkNotes")({
			notebook_path = notebook_dir,
			sort = { "modified" },
			match = { query },
		})
	end
end, { desc = "Notes: search" })
map("n", "<leader>nt", function()
	commands.get("ZkTags")({ notebook_path = notebook_dir })
end, { desc = "Notes: tags" })

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("zk-notebook-keymaps", { clear = true }),
	pattern = "markdown",
	callback = function(args)
		if not require("zk.util").notebook_root(vim.api.nvim_buf_get_name(args.buf)) then
			return
		end

		vim.b[args.buf].minicompletion_config = {
			lsp_completion = {
				process_items = process_completion_items,
			},
		}

		local opts = { buffer = args.buf }
		map("n", "<leader>ni", "<cmd>ZkInsertLink<cr>", vim.tbl_extend("force", opts, { desc = "Notes: insert link" }))
		map("x", "<leader>ni", ":'<,'>ZkInsertLinkAtSelection { matchSelected = true }<cr>",
			vim.tbl_extend("force", opts, { desc = "Notes: link selection" }))
		map("x", "<leader>ns", ":'<,'>ZkMatch<cr>",
			vim.tbl_extend("force", opts, { desc = "Notes: search selection" }))
		map("n", "<leader>nb", "<cmd>ZkBacklinks<cr>",
			vim.tbl_extend("force", opts, { desc = "Notes: backlinks" }))
		map("n", "<leader>nl", "<cmd>ZkLinks<cr>",
			vim.tbl_extend("force", opts, { desc = "Notes: outgoing links" }))
	end,
})
