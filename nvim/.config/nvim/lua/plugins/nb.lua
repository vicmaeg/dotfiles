local fzf = require("fzf-lua")

local M = {}

local function run(args)
	local result = vim.system(args, { text = true }):wait()
	if result.code ~= 0 then
		local message = vim.trim(result.stderr or "")
		local command = args[1] or "Command"
		vim.notify(message ~= "" and message or command .. " command failed", vim.log.levels.ERROR)
		return nil
	end
	return vim.trim(result.stdout or "")
end

local function fields(entry)
	return vim.split(entry, "\t", { plain = true })
end

local function edit_entry(entry)
	local item = fields(entry)
	local path, line = item[1], tonumber(item[2]) or 1
	if not path or path == "" then
		return
	end
	vim.cmd.edit(vim.fn.fnameescape(path))
	vim.api.nvim_win_set_cursor(0, { math.max(line, 1), 0 })
	vim.cmd.normal({ "zz", bang = true })
end

local function picker(mode, args, opts)
	args = args or {}
	opts = opts or {}
	local command = { "nb-fzf", "__emit", mode, opts.scope or "all" }
	vim.list_extend(command, args)
	local output = run(command)
	if not output or output == "" then
		vim.notify("No matching nb items", vim.log.levels.INFO)
		return
	end

	fzf.fzf_exec(vim.split(output, "\n", { plain = true }), {
		prompt = (opts.prompt or "notes") .. "> ",
		query = opts.query,
		fzf_opts = {
			["--delimiter"] = "\t",
			["--with-nth"] = "3,4,5,6",
			["--preview"] = "nb-fzf __preview {1} {2}",
			["--preview-window"] = "right,60%,wrap",
		},
		winopts = { preview = { hidden = false } },
		actions = {
			["default"] = function(selected)
				if selected and selected[1] then
					(opts.action or edit_entry)(selected[1])
				end
			end,
		},
	})
end

local function input(prompt, callback)
	vim.ui.input({ prompt = prompt }, function(value)
		if value ~= nil then
			callback(vim.trim(value))
		end
	end)
end

function M.find()
	picker("notes", {}, { prompt = "notes" })
end

function M.search()
	input("Search notes: ", function(query)
		if query ~= "" then
			picker("search", { query }, { prompt = "search" })
		end
	end)
end

function M.tags()
	local output = run({ "nb-fzf", "__emit", "tags", "all" })
	if not output or output == "" then
		vim.notify("No nb tags found", vim.log.levels.INFO)
		return
	end
	fzf.fzf_exec(vim.split(output, "\n", { plain = true }), {
		prompt = "tags> ",
		fzf_opts = { ["--multi"] = true },
		actions = {
			["default"] = function(selected)
				if selected and #selected > 0 then
					picker("tagged", selected, { prompt = "tagged" })
				end
			end,
		},
	})
end

function M.next_items()
	picker("next", {}, { prompt = "next" })
end

function M.tasks()
	picker("tasks", {}, { prompt = "tasks" })
end

function M.new_note(kind)
	input("Title: ", function(title)
		if title == "" then
			return
		end
		local function finish(category)
			input("Extra tags (comma-separated, optional): ", function(tags)
				local command = { "nb-fzf", "new", kind, "--title", title, "--tags", tags, "--print-path" }
				if category and category ~= "" then
					vim.list_extend(command, { "--category", category })
				end
				local path = run(command)
				if path and path ~= "" then
					vim.cmd.edit(vim.fn.fnameescape(path))
				end
			end)
		end
		if kind == "project" or kind == "area" then
			input((kind == "project" and "Project" or "Area") .. " tag suffix: ", function(category)
				if category ~= "" then
					finish(category)
				end
			end)
		else
			finish(nil)
		end
	end)
end

function M.daily()
	local path = run({ "nb-fzf", "daily", "--print-path" })
	if path and path ~= "" then
		vim.cmd.edit(vim.fn.fnameescape(path))
	end
end

function M.insert_link()
	picker("notes", {}, {
		prompt = "link",
		action = function(entry)
			local item = fields(entry)
			local selector, title = item[3], item[4]
			if selector and selector ~= "" then
				local label = title and title ~= "" and "|" .. title or ""
				vim.api.nvim_put({ "[[" .. selector .. label .. "]]" }, "c", true, true)
			end
		end,
	})
end

local function link_under_cursor()
	local line = vim.api.nvim_get_current_line()
	local column = vim.api.nvim_win_get_cursor(0)[2] + 1
	local offset = 1

	while true do
		local start_column, end_column, contents = line:find("%[%[([^%]]-)%]%]", offset)
		if not start_column then
			return nil
		end
		if column >= start_column and column <= end_column then
			return vim.trim(contents:match("^[^|]+") or "")
		end
		offset = end_column + 1
	end
end

function M.go_to_link()
	local selector = link_under_cursor()
	if not selector or selector == "" then
		vim.notify("No nb wikilink under cursor", vim.log.levels.INFO)
		return
	end

	local path = run({ "nb", "show", selector, "--path", "--no-color" })
	if path and path ~= "" then
		vim.cmd.edit(vim.fn.fnameescape(path))
	end
end

local map = vim.keymap.set
map("n", "<leader>nn", function()
	M.new_note("general")
end, { desc = "Notes: new general note" })
map("n", "<leader>np", function()
	M.new_note("project")
end, { desc = "Notes: new project" })
map("n", "<leader>na", function()
	M.new_note("area")
end, { desc = "Notes: new area" })
map("n", "<leader>nd", M.daily, { desc = "Notes: today's daily note" })
map("n", "<leader>nf", M.find, { desc = "Notes: find" })
map("n", "<leader>ns", M.search, { desc = "Notes: search contents" })
map("n", "<leader>nt", M.tags, { desc = "Notes: search tags" })
map("n", "<leader>no", M.tasks, { desc = "Notes: open tasks" })
map("n", "<leader>nx", M.next_items, { desc = "Notes: next items" })
map("n", "<leader>ni", M.insert_link, { desc = "Notes: insert link" })
map("n", "<leader>ng", M.go_to_link, { desc = "Notes: go to link" })

return M
