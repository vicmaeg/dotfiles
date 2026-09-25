local M = {}

local function fail(message)
	vim.notify("Herdr review: " .. message, vim.log.levels.ERROR)
end

local function herdr(args, expect_json)
	local command = { "herdr" }
	vim.list_extend(command, args)
	local ok_process, process = pcall(function()
		return vim.system(command, { text = true }):wait()
	end)
	if not ok_process then
		return nil, tostring(process)
	end
	if process.code ~= 0 then
		local message = vim.trim(process.stderr or "")
		return nil, message ~= "" and message or "herdr failed"
	end
	if expect_json == false then
		return true
	end
	local ok, response = pcall(vim.json.decode, process.stdout or "")
	if not ok or type(response) ~= "table" or type(response.result) ~= "table" then
		return nil, "invalid response from herdr"
	end
	return response.result
end

local function agents_nearby()
	if vim.env.HERDR_ENV ~= "1" or not vim.env.HERDR_PANE_ID then
		return nil, "Neovim is not running in a Herdr pane"
	end
	if vim.fn.executable("herdr") ~= 1 then
		return nil, "herdr is not on PATH"
	end

	local current, current_error = herdr({ "pane", "current", "--current" })
	if not current then
		return nil, current_error
	end
	local pane = current.pane
	if type(pane) ~= "table" or not pane.workspace_id or not pane.tab_id then
		return nil, "could not identify this Herdr pane"
	end

	local listed, list_error = herdr({ "agent", "list" })
	if not listed then
		return nil, list_error
	end
	if type(listed.agents) ~= "table" then
		return nil, "could not read the Herdr agent list"
	end

	local workspace_agents = vim.tbl_filter(function(agent)
		return agent.workspace_id == pane.workspace_id and agent.pane_id ~= pane.pane_id
	end, listed.agents)
	local tab_agents = vim.tbl_filter(function(agent)
		return agent.tab_id == pane.tab_id
	end, workspace_agents)
	local candidates = #tab_agents > 0 and tab_agents or workspace_agents
	if #candidates == 0 then
		return nil, "no agent in this Herdr workspace"
	end
	return candidates, nil, pane.workspace_id
end

local function choose_agent(candidates, callback)
	if #candidates == 1 then
		callback(candidates[1])
		return
	end
	vim.ui.select(candidates, {
		prompt = "Send review comment to agent",
		format_item = function(agent)
			local title = agent.terminal_title_stripped or agent.terminal_title or ""
			return ("%s — %s — %s"):format(agent.agent or "agent", agent.pane_id, title)
		end,
	}, callback)
end

local function line_range(visual)
	if not visual then
		local line = vim.api.nvim_win_get_cursor(0)[1]
		return line, line
	end
	local anchor = vim.fn.line("v")
	local cursor = vim.fn.line(".")
	return math.min(anchor, cursor), math.max(anchor, cursor)
end

local function compact_lines(numbers)
	table.sort(numbers)
	local ranges = {}
	local first, last
	for _, number in ipairs(numbers) do
		if not first then
			first, last = number, number
		elseif number == last + 1 then
			last = number
		elseif number ~= last then
			ranges[#ranges + 1] = first == last and tostring(first) or first .. "-" .. last
			first, last = number, number
		end
	end
	if first then
		ranges[#ranges + 1] = first == last and tostring(first) or first .. "-" .. last
	end
	return table.concat(ranges, ",")
end

local function fugitive_file_reference(status, section, filename)
	local file
	if section == "Untracked" then
		for _, entry in ipairs(status.untracked or {}) do
			if entry.filename == filename then
				file = entry
				break
			end
		end
	elseif section == "Staged" or section == "Unstaged" then
		file = status.files[section] and status.files[section][filename]
	end
	local path = file and file.relative and file.relative[1]
	if type(path) ~= "string" or path == "" or path:find("[%c]") or status.work_tree:find("[%c]") then
		return nil, "could not determine the file in the Fugitive status"
	end
	return vim.fs.normalize(status.work_tree .. "/" .. path)
end

local function fugitive_reference(first, last)
	local status = vim.b.fugitive_status
	if type(status) ~= "table" or type(status.files) ~= "table" or not status.work_tree or status.work_tree == "" then
		return nil, "this Fugitive buffer has no file metadata"
	end

	local section, file, old_line, new_line
	local selected_file, selected_section
	local old_numbers, new_numbers = {}, {}
	for row = 1, last do
		local line = vim.fn.getline(row)
		local heading = line:match("^(%a+) %(")
		if heading == "Staged" or heading == "Unstaged" or heading == "Untracked" then
			section, file, old_line, new_line = heading, nil, nil, nil
		elseif line:match("^[A-Z?] ") then
			local filename = line:sub(3)
			if row == first and first == last then
				return fugitive_file_reference(status, section, filename)
			end
			file = section and status.files[section] and status.files[section][filename] or nil
			old_line, new_line = nil, nil
		elseif line:match("^@@ ") then
			local old_start, new_start = line:match("^@@ %-(%d+)[^ ]* %+(%d+)[^ ]* @@")
			old_line, new_line = tonumber(old_start), tonumber(new_start)
		elseif old_line and new_line then
			local prefix = line:sub(1, 1)
			if prefix == " " then
				if row >= first then
					new_numbers[#new_numbers + 1] = new_line
				end
				old_line, new_line = old_line + 1, new_line + 1
			elseif prefix == "+" then
				if row >= first then
					new_numbers[#new_numbers + 1] = new_line
				end
				new_line = new_line + 1
			elseif prefix == "-" then
				if row >= first then
					old_numbers[#old_numbers + 1] = old_line
				end
				old_line = old_line + 1
			end
		end

		if row >= first then
			local prefix = line:sub(1, 1)
			if not file or (prefix ~= " " and prefix ~= "+" and prefix ~= "-") or not (old_line and new_line) then
				return nil, "select code lines inside one expanded Fugitive diff"
			end
			if selected_file and (selected_file ~= file or selected_section ~= section) then
				return nil, "select lines from only one Fugitive file and section"
			end
			selected_file, selected_section = file, section
		end
	end

	local paths = selected_file.relative
	if type(paths) ~= "table" or type(paths[1]) ~= "string" then
		return nil, "could not determine the file in the Fugitive diff"
	end
	if status.work_tree:find("[%c]") then
		return nil, "the Fugitive file path contains a control character"
	end
	for _, path in ipairs(paths) do
		if type(path) ~= "string" or path:find("[%c]") then
			return nil, "the Fugitive file path contains a control character"
		end
	end
	local references = {}
	if #old_numbers > 0 then
		local path = vim.fs.normalize(status.work_tree .. "/" .. paths[#paths])
		references[#references + 1] = ("%s:%s (old side, %s)"):format(
			path,
			compact_lines(old_numbers),
			selected_section:lower()
		)
	end
	if #new_numbers > 0 then
		local path = vim.fs.normalize(status.work_tree .. "/" .. paths[1])
		references[#references + 1] = ("%s:%s (new side, %s)"):format(
			path,
			compact_lines(new_numbers),
			selected_section:lower()
		)
	end
	if #references == 0 then
		return nil, "select code lines inside one expanded Fugitive diff"
	end
	return table.concat(references, "; ")
end

function M.reference(first, last)
	if vim.bo.filetype == "fugitive" then
		return fugitive_reference(first, last)
	end
	if vim.bo.buftype ~= "" then
		return nil, "this buffer is not a file"
	end
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" or path:match("^%a[%w+.-]*://") or path:find("[%c]") then
		return nil, "this buffer has no usable file path"
	end
	path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
	local lines = first == last and tostring(first) or first .. "-" .. last
	return path .. ":" .. lines
end

function M.comment(visual)
	local first, last = line_range(visual)
	local reference, reference_error = M.reference(first, last)
	if not reference then
		fail(reference_error)
		return
	end
	vim.ui.input({ prompt = "Review comment for " .. reference .. ": " }, function(comment)
		if not comment then
			return
		end
		comment = vim.trim(comment:gsub("%s+", " "))
		if comment == "" then
			return
		end
		local candidates, candidates_error, workspace_id = agents_nearby()
		if not candidates then
			fail(candidates_error)
			return
		end
		choose_agent(candidates, function(agent)
			if not agent then
				return
			end
			local latest, latest_error = herdr({ "agent", "list" })
			if not latest then
				fail(latest_error)
				return
			end
			local valid = vim.iter(latest.agents or {}):any(function(current)
				return current.pane_id == agent.pane_id
					and current.workspace_id == workspace_id
					and vim.deep_equal(current.agent_session, agent.agent_session)
			end)
			if not valid then
				fail("the selected agent moved or exited; try again")
				return
			end
			local inserted, insert_error =
				herdr({ "pane", "send-text", agent.pane_id, ("[%s] %s; "):format(reference, comment) }, false)
			if not inserted then
				fail(insert_error)
				return
			end
			vim.notify("Review comment inserted into " .. (agent.agent or "agent") .. " (not submitted)")
		end)
	end)
end

function M.setup()
	vim.keymap.set("n", "<leader>ac", function()
		M.comment(false)
	end, { desc = "Agent: insert review comment" })
	vim.keymap.set("x", "<leader>ac", function()
		M.comment(true)
	end, { desc = "Agent: insert review comment for selection" })
end

return M
