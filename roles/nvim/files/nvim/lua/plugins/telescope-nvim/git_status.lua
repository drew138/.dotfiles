local entry_display = require("telescope.pickers.entry_display")
local utils = require("telescope.utils")

local M = {}

local highlight_links = {
	TelescopeResultsDiffAdd = "GitSignsAdd",
	TelescopeResultsDiffChange = "GitSignsChange",
	TelescopeResultsDiffDelete = "GitSignsDelete",
}

local bar = "┃"
local dotted = "┋"

local function tone(added, removed)
	local gained = (added or 0) > 0
	local lost = (removed or 0) > 0

	if gained and not lost then
		return "TelescopeResultsDiffAdd"
	end

	if lost and not gained then
		return "TelescopeResultsDiffDelete"
	end

	return "TelescopeResultsDiffChange"
end

local staged_suffix = "Staged"
local staged_alpha = 0.45

local function blend(fg, bg, alpha)
	local function channel(shift)
		local front = math.floor(fg / shift) % 256
		local back = math.floor(bg / shift) % 256

		return math.floor(front * alpha + back * (1 - alpha) + 0.5)
	end

	return string.format("#%02x%02x%02x", channel(65536), channel(256), channel(1))
end

local function apply_highlights()
	local normal = vim.api.nvim_get_hl(0, { name = "Normal" })
	local background = normal.bg or 0

	for group, link in pairs(highlight_links) do
		vim.api.nvim_set_hl(0, group, { link = link })

		local source = vim.api.nvim_get_hl(0, { name = link, link = false })

		if source.fg then
			vim.api.nvim_set_hl(0, group .. staged_suffix, {
				fg = blend(source.fg, background, staged_alpha),
			})
		end
	end
end

local function numstat(cwd)
	local counts = {}
	local output = utils.get_os_command_output({ "git", "diff", "--numstat", "HEAD" }, cwd)

	for _, line in ipairs(output or {}) do
		local added, removed, path = line:match("^(%S+)%s+(%S+)%s+(.+)$")

		if path then
			counts[path] = { added = tonumber(added), removed = tonumber(removed) }
		end
	end

	return counts
end

local function untracked_added(cwd, path)
	local output = utils.get_os_command_output({ "wc", "-l", path }, cwd)
	local first = (output or {})[1] or ""

	return tonumber(first:match("^%s*(%d+)"))
end

local function counts_for(counts, cwd, status, path)
	if status:find("?", 1, true) then
		return untracked_added(cwd, path), nil
	end

	local entry = counts[path]

	if not entry then
		return nil, nil
	end

	return entry.added, entry.removed
end

-- a blank Y column means the change is wholly staged; anything else leaves work
-- in the tree, so a partially staged file stays at full intensity.
local function marker(status)
	local worktree = status:sub(2, 2)
	local pending = worktree ~= " " and worktree ~= ""
	local untracked = status:find("?", 1, true) ~= nil

	return untracked and dotted or bar, not pending
end

local function entry_maker(opts)
	local cwd = opts.cwd or vim.loop.cwd()
	local counts = numstat(cwd)

	local displayer = entry_display.create({
		separator = " ",
		items = {
			{ width = 2 },
			{ width = 5 },
			{ width = 5 },
			{ remaining = true },
		},
	})

	local function make_display(entry)
		local icon, staged = marker(entry.status)
		local added, removed = counts_for(counts, cwd, entry.status, entry.value)
		local suffix = staged and staged_suffix or ""
		local hl = tone(added, removed)

		return displayer({
			{ icon, hl .. suffix },
			{ added and ("+" .. added) or "", "TelescopeResultsDiffAdd" .. suffix },
			{ removed and ("-" .. removed) or "", "TelescopeResultsDiffDelete" .. suffix },
			utils.transform_path(opts, entry.value),
		})
	end

	return function(line)
		local status, path = line:match("^(..)%s+(.+)$")

		if not path then
			return nil
		end

		return {
			value = path,
			status = status,
			ordinal = path,
			path = cwd .. "/" .. path,
			display = make_display,
		}
	end
end

-- built per invocation rather than once at load, so the line counts are not a
-- snapshot from whenever neovim started.
function M.opts()
	apply_highlights()

	local picker_opts = { previewer = false }

	picker_opts.entry_maker = entry_maker(picker_opts)

	return picker_opts
end

return M
