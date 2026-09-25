local M = {}

local uv = vim.uv or vim.loop
local state_root = vim.fs.joinpath(vim.fn.expand("~"), ".local", "state", "omarchy", "current")
local theme_file = vim.fs.joinpath(state_root, "theme", "neovim.lua")
local colors_file = vim.fs.joinpath(state_root, "theme", "colors.toml")

local setup_modules = {
	["bjarneo/aether.nvim"] = "aether",
	["folke/tokyonight.nvim"] = "tokyonight",
	["rebelot/kanagawa.nvim"] = "kanagawa",
}

-- Replace stock Omarchy plugin schemes with Neovim or mini.nvim schemes.
local colorscheme_overrides = {
	ashen = "default",
	bamboo = "minispring",
	["catppuccin-latte"] = "catppuccin",
	["catppuccin-nvim"] = "catppuccin",
	everforest = "miniwinter",
	["flexoki-light"] = "retrobox",
	gruvbox = "retrobox",
	hackerman = "elflord",
	lumon = "miniwinter",
	matteblack = "unokai",
	nordfox = "miniwinter",
	["retro-82"] = "minischeme",
	["rose-pine-dawn"] = "catppuccin",
}

local fallback = "kanagawa-wave"
local last_hash
local last_error_hash
local reload_timer
local watchers = {}

local function read_file(path)
	local file = io.open(path, "rb")
	if not file then
		return nil
	end
	local contents = file:read("*a")
	file:close()
	return contents
end

local function notify_once(message, hash)
	if last_error_hash == hash then
		return
	end
	last_error_hash = hash
	vim.schedule(function()
		vim.notify(message, vim.log.levels.ERROR, { title = "Omarchy theme" })
	end)
end

local function use_fallback(message, hash)
	pcall(vim.cmd.colorscheme, fallback)
	if message then
		notify_once(message .. ("; using %s"):format(fallback), hash)
	end
end

local function setup_plugin(entry, seen)
	local repo = type(entry) == "string" and entry or entry[1]
	if type(repo) ~= "string" or seen[repo] then
		return
	end
	seen[repo] = true

	local dependencies = type(entry) == "table" and entry.dependencies or nil
	if type(dependencies) == "string" then
		dependencies = { dependencies }
	end
	for _, dependency in ipairs(dependencies or {}) do
		setup_plugin(dependency, seen)
	end

	local module_name = setup_modules[repo]
	if module_name then
		local ok, plugin = pcall(require, module_name)
		if ok and type(plugin.setup) == "function" then
			plugin.setup(type(entry) == "table" and entry.opts or {})
		end
	end
end

local function parse_theme()
	local ok, entries = pcall(dofile, theme_file)
	if not ok then
		return nil, ("cannot read %s: %s"):format(theme_file, entries)
	end
	if type(entries) ~= "table" then
		return nil, ("%s did not return a plugin specification"):format(theme_file)
	end

	local colorscheme
	local plugins = {}
	for _, entry in ipairs(entries) do
		local repo = type(entry) == "table" and entry[1] or nil
		if repo == "LazyVim/LazyVim" then
			colorscheme = entry.opts and entry.opts.colorscheme
		else
			table.insert(plugins, entry)
		end
	end
	if type(colorscheme) ~= "string" or colorscheme == "" then
		return nil, ("%s does not declare a colorscheme"):format(theme_file)
	end
	local replacement = colorscheme_overrides[colorscheme]
	if replacement then
		return { colorscheme = replacement, plugins = {} }
	end
	return { colorscheme = colorscheme, plugins = plugins }
end

local function set_background()
	local colors = read_file(colors_file)
	local mode = colors and colors:match('[\r\n]*%s*mode%s*=%s*"([^"]+)"')
	if mode == "light" or mode == "dark" then
		vim.o.background = mode
	end
end

local function suppress_aether_watcher()
	-- Aether watches the same Omarchy file and delegates non-Aether themes to
	-- lazy.nvim. This config has its own vim.pack-aware watcher, so keep Aether's
	-- colorscheme implementation and replace only its watcher registration.
	package.loaded["aether.hotreload"] = { setup = function() end }
end

function M.reload(opts)
	opts = opts or {}
	local descriptor = read_file(theme_file)
	if not descriptor then
		last_hash = nil
		use_fallback(nil)
		return false
	end

	local colors = read_file(colors_file) or ""
	local hash = vim.fn.sha256(descriptor .. "\0" .. colors)
	if not opts.force and hash == last_hash then
		return true
	end

	local theme, parse_error = parse_theme()
	if not theme then
		use_fallback(parse_error, hash)
		return false
	end

	suppress_aether_watcher()
	local ok, apply_error = pcall(function()
		local seen = {}
		for _, entry in ipairs(theme.plugins) do
			setup_plugin(entry, seen)
		end
		set_background()
		vim.cmd.colorscheme(theme.colorscheme)
	end)
	if not ok then
		use_fallback(("failed to apply %s: %s"):format(theme.colorscheme, apply_error), hash)
		return false
	end

	last_hash = hash
	last_error_hash = nil
	return true
end

local function schedule_reload()
	if reload_timer then
		reload_timer:stop()
		reload_timer:close()
	end
	reload_timer = vim.defer_fn(function()
		reload_timer = nil
		M.reload()
	end, 200)
end

local function watch(path)
	if vim.fn.isdirectory(path) ~= 1 then
		return
	end
	local handle = uv.new_fs_event()
	if handle and handle:start(path, {}, vim.schedule_wrap(schedule_reload)) == 0 then
		table.insert(watchers, handle)
	elseif handle then
		handle:close()
	end
end

local function stop_watchers()
	if reload_timer then
		reload_timer:stop()
		reload_timer:close()
		reload_timer = nil
	end
	for _, handle in ipairs(watchers) do
		if not handle:is_closing() then
			handle:stop()
			handle:close()
		end
	end
	watchers = {}
end

function M.setup(opts)
	opts = opts or {}
	fallback = opts.fallback or fallback

	M.reload({ force = true })
	watch(state_root)

	local group = vim.api.nvim_create_augroup("omarchy-theme", { clear = true })
	vim.api.nvim_create_autocmd("FocusGained", {
		group = group,
		callback = schedule_reload,
		desc = "Refresh the active Omarchy theme",
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = stop_watchers,
		desc = "Close the Omarchy theme watcher",
	})
	vim.api.nvim_create_user_command("OmarchyThemeReload", function()
		M.reload({ force = true })
	end, { desc = "Reload the active Omarchy theme" })
end

return M
