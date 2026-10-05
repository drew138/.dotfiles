local sketchybar = require("sketchybar")
local theme = require("theme")
local opts = require("items.herdr.opts")

local M = {}

M.agents = {}
M.slot_mode = {}
M.slot_token = {}
M.slot_frame = {}
M.slot_bounce_up = {}
M.slot_visible = {}
M.slot_width = {}
M.slot_agent = {}
M.key_index = {}
M.slot_state = {}
M.slot_retired = {}
M.shown_last = 0
M.room = nil

local function with_alpha(color, alpha)
	if type(color) ~= "number" then
		return color
	end

	return math.floor(color) % 0x1000000 + alpha * 0x1000000
end

local function transparent(color)
	if type(color) ~= "number" then
		return color
	end

	return math.floor(color) % 0x1000000
end

local function parse_entities(result, collection, id_key)
	local entities = {}
	local payload = (result or ""):match('"' .. collection .. '"%s*:%s*%[(.*)%]')

	if not payload then
		return entities
	end

	for object in string.gmatch(payload, "%b{}") do
		local id = object:match('"' .. id_key .. '"%s*:%s*"(.-)"')

		if id then
			entities[id] = {
				label = object:match('"label"%s*:%s*"(.-)"'),
				number = tonumber(object:match('"number"%s*:%s*(%d+)')),
			}
		end
	end

	return entities
end

local function fit_count(widths, available, total)
	if not available then
		return math.min(#widths, opts.maximum_slots)
	end

	local best = 0
	local used = 0

	for index = 1, math.min(#widths, opts.maximum_slots) do
		used = used + widths[index]

		local reserve = index < total and opts.overflow_width or 0

		if used + reserve > available then
			break
		end

		best = index
	end

	return math.max(best, total > 0 and 1 or 0)
end

local function shorten(text)
	if #text <= opts.label_max_length then
		return text
	end

	return text:sub(1, opts.label_max_length - 1) .. "…"
end

local function parse_agents(result, workspaces, tabs)
	local agents = {}
	local payload = (result or ""):match('"agents"%s*:%s*%[(.*)%]')

	if not payload then
		return agents
	end

	local per_workspace = {}

	for object in string.gmatch(payload, "%b{}") do
		local status = object:match('"agent_status"%s*:%s*"(.-)"')

		if status then
			local pane = object:match('"pane_id"%s*:%s*"(.-)"') or ""
			local workspace = object:match('"workspace_id"%s*:%s*"(.-)"') or ""
			local tab = object:match('"tab_id"%s*:%s*"(.-)"') or ""

			per_workspace[tab] = (per_workspace[tab] or 0) + 1

			table.insert(agents, {
				status = status,
				pane = pane,
				workspace = workspace,
				tab = tab,
				pane_number = pane:match(":p(%d+)") or "",
				key = tab ~= "" and tab or pane,
			})
		end
	end

	local function workspace_order(agent)
		local entity = (workspaces or {})[agent.workspace]

		return entity and entity.number or math.huge
	end

	local function tab_order(agent)
		local entity = (tabs or {})[agent.tab]

		return entity and entity.number or tonumber(agent.tab:match(":t(%d+)")) or math.huge
	end

	table.sort(agents, function(left, right)
		if workspace_order(left) ~= workspace_order(right) then
			return workspace_order(left) < workspace_order(right)
		end

		if left.workspace ~= right.workspace then
			return left.workspace < right.workspace
		end

		if tab_order(left) ~= tab_order(right) then
			return tab_order(left) < tab_order(right)
		end

		return (tonumber(left.pane_number) or 0) < (tonumber(right.pane_number) or 0)
	end)

	for _, agent in ipairs(agents) do
		local workspace_entity = (workspaces or {})[agent.workspace]
		local tab_entity = (tabs or {})[agent.tab]
		local workspace = shorten((workspace_entity and workspace_entity.label) or agent.workspace)
		local tab = (tab_entity and tab_entity.label) or (agent.tab:match(":t(%d+)") or "")

		agent.slot = workspace

		if tab ~= "" then
			agent.slot = agent.slot .. opts.label_separator .. shorten(tab)
		end

		if (per_workspace[agent.tab] or 0) > 1 and agent.pane_number ~= "" then
			agent.slot = agent.slot .. ":" .. agent.pane_number
		end
	end

	return agents
end

local function stagger(index)
	return (opts.maximum_slots - index) % 4
end

local function animate_thinking(index, token)
	if M.slot_mode[index] ~= "working" or token ~= M.slot_token[index] then
		return
	end

	M.slot_frame[index] = (M.slot_frame[index] or 1) % #opts.glyphs.thinking + 1

	local color = opts.state_colors.working
	local shade = M.slot_frame[index] % 2 == 0 and color or with_alpha(color, opts.thinking_dim_alpha)

	sketchybar.animate("sin", opts.thinking_ticks, function()
		M.slots[index]:set({
			icon = { string = opts.glyphs.thinking[M.slot_frame[index]], color = shade },
			label = { color = shade },
		})
	end)

	sketchybar.delay(opts.thinking_interval + stagger(index) * opts.animation_drift, function()
		animate_thinking(index, token)
	end)
end

local function animate_bounce(index, token)
	if M.slot_mode[index] ~= "blocked" or token ~= M.slot_token[index] then
		return
	end

	M.slot_bounce_up[index] = not M.slot_bounce_up[index]

	local offset = M.slot_bounce_up[index] and (opts.icon_y_offset + opts.bounce_offset) or opts.icon_y_offset

	sketchybar.animate("sin", opts.bounce_ticks, function()
		M.slots[index]:set({ icon = { y_offset = offset } })
	end)

	sketchybar.delay(opts.bounce_interval + stagger(index) * opts.animation_drift, function()
		animate_bounce(index, token)
	end)
end

local function set_slot_mode(index, mode)
	if M.slot_mode[index] == mode then
		return
	end

	M.slot_mode[index] = mode
	M.slot_token[index] = (M.slot_token[index] or 0) + 1
	M.slot_frame[index] = (index - 1) % #opts.glyphs.thinking + 1
	M.slot_bounce_up[index] = index % 2 == 0

	local token = M.slot_token[index]

	if mode ~= "blocked" then
		M.slots[index]:set({ icon = { y_offset = opts.icon_y_offset } })
	end

	local phase = stagger(index) * opts.animation_phase

	if mode == "working" then
		sketchybar.delay(phase, function()
			animate_thinking(index, token)
		end)
	elseif mode == "blocked" then
		sketchybar.delay(phase, function()
			animate_bounce(index, token)
		end)
	end
end

local function glyph_for(status)
	if status == "blocked" then
		return opts.glyphs.blocked
	elseif status == "done" then
		return opts.glyphs.done
	elseif status == "working" then
		return opts.glyphs.thinking[1]
	end

	return opts.glyphs.idle
end

local function assign_slots(agents, capacity)
	local wanted = math.min(#agents, capacity)

	local function compact()
		local assignment = {}

		M.key_index = {}

		for position = 1, wanted do
			local agent = agents[position]
			local index = opts.maximum_slots - position + 1

			assignment[index] = agent
			M.key_index[agent.key] = index
		end

		return assignment
	end

	local assignment = {}
	local used = {}
	local held = {}

	local previous = opts.maximum_slots + 1

	for position = 1, wanted do
		local index = M.key_index[agents[position].key]

		if index and index >= 2 and index <= opts.maximum_slots and not used[index] and index < previous then
			held[position] = index
			used[index] = true
			previous = index
		end
	end

	for position = 1, wanted do
		if not held[position] then
			local upper = opts.maximum_slots + 1
			local lower = 1

			for earlier = position - 1, 1, -1 do
				if held[earlier] then
					upper = held[earlier]
					break
				end
			end

			for later = position + 1, wanted do
				if held[later] then
					lower = held[later]
					break
				end
			end

			local chosen

			for candidate = upper - 1, lower + 1, -1 do
				if not used[candidate] and candidate >= 2 then
					chosen = candidate
					break
				end
			end

			if not chosen then
				return compact()
			end

			held[position] = chosen
			used[chosen] = true
		end
	end

	M.key_index = {}

	for position = 1, wanted do
		local agent = agents[position]

		assignment[held[position]] = agent
		M.key_index[agent.key] = held[position]
	end

	return assignment
end

local function show_slot(index, agent)
	local slot = M.slots[index]
	local color = opts.state_colors[agent.status] or theme.colors.grey
	local state = M.slot_state[index]
	local target = opts.slot_base_width + #(agent.slot or "") * opts.slot_character_width

	if state and state.label == agent.slot and state.status == agent.status then
		return
	end

	local label_changed = not state or state.label ~= agent.slot

	slot:set({
		drawing = true,
		click_script = opts.binary .. " agent focus " .. agent.pane,
		icon = { string = glyph_for(agent.status), color = color },
		label = { string = agent.slot, color = color },
	})

	if not M.slot_visible[index] then
		M.slot_visible[index] = true
		M.slot_retired[index] = nil
		M.slot_width[index] = target

		slot:set({
			width = 0,
			icon = { color = transparent(color), y_offset = opts.icon_y_offset - opts.appear_offset },
			label = { color = transparent(color) },
		})

		sketchybar.animate("sin", opts.appear_ticks, function()
			slot:set({
				width = target,
				icon = { color = color, y_offset = opts.icon_y_offset },
				label = { color = color },
			})
		end)

		sketchybar.delay(opts.width_seconds, function()
			if M.slot_visible[index] then
				slot:set({ width = "dynamic" })
			end
		end)
	elseif label_changed and M.slot_width[index] ~= target then
		M.slot_width[index] = target

		sketchybar.animate("sin", opts.width_ticks, function()
			slot:set({ width = target })
		end)

		sketchybar.delay(opts.width_seconds, function()
			if M.slot_visible[index] then
				slot:set({ width = "dynamic" })
			end
		end)
	end

	M.slot_state[index] = { label = agent.slot, status = agent.status }
	set_slot_mode(index, agent.status)
end

local function hide_slot(index)
	local slot = M.slots[index]

	if not M.slot_visible[index] then
		if M.slot_state[index] or not M.slot_retired[index] then
			M.slot_state[index] = nil
			M.slot_retired[index] = true
			slot:set({ drawing = false })
		end

		return
	end

	M.slot_visible[index] = false
	M.slot_width[index] = nil
	M.slot_state[index] = nil
	set_slot_mode(index, "hidden")

	slot:set({
		icon = { string = "", color = theme.colors.transparent },
		label = { string = "", color = theme.colors.transparent },
	})

	sketchybar.animate("sin", opts.disappear_ticks, function()
		slot:set({ width = 0 })
	end)

	-- Left at zero deliberately: a hidden slot asked to size itself again flashes
	-- to full width for a frame the next time it is drawn.
	sketchybar.delay(opts.disappear_seconds, function()
		if not M.slot_visible[index] then
			M.slot_retired[index] = true
			slot:set({ drawing = false })
		end
	end)
end

local function refresh_slots()
	local widths = {}

	for index, agent in ipairs(M.agents) do
		widths[index] = opts.slot_base_width + #(agent.slot or "") * opts.slot_character_width
	end

	local capacity = fit_count(widths, M.room, #M.agents)

	capacity = math.min(capacity, opts.maximum_slots - 1)

	local assignment = assign_slots(M.agents, capacity)
	local shown = 0

	for index = 2, opts.maximum_slots do
		local agent = assignment[index]

		if agent then
			shown = shown + 1
			M.slot_agent[index] = agent.pane
			show_slot(index, agent)
		else
			M.slot_agent[index] = nil
			hide_slot(index)
		end
	end

	local overflow = #M.agents - shown

	local hidden_state = nil
	local ranking = { blocked = 1, working = 2, done = 3, idle = 4, unknown = 5 }

	for position = shown + 1, #M.agents do
		local status = M.agents[position].status

		if not hidden_state or (ranking[status] or 9) < (ranking[hidden_state] or 9) then
			hidden_state = status
		end
	end

	if overflow > 0 then
		local color = opts.state_colors[hidden_state] or theme.colors.grey
		local glyph = glyph_for(hidden_state)
		local label = "+" .. overflow
		local state = M.slot_state[1]

		if not state or state.label ~= label or state.status ~= tostring(hidden_state) then
			M.slots[1]:set({
				drawing = true,
				click_script = "",
				icon = { string = glyph, color = color },
				label = { string = label, color = color },
			})

			M.slot_visible[1] = true
			M.slot_retired[1] = nil
			M.slot_state[1] = { label = label, status = tostring(hidden_state) }
			set_slot_mode(1, hidden_state or "idle")
		end
	else
		hide_slot(1)
	end

	M.shown_last = shown
end

local function read_cache()
	local file = io.open(opts.cache_path, "r")

	if not file then
		return nil
	end

	local contents = file:read("a")
	file:close()

	return contents
end

function M.refresh()
	local cache = read_cache()

	if not cache then
		M.herdr:set({ drawing = true, label = { string = "" } })
		return
	end

	local result = cache:match("AGENTS(.-)\nWORKSPACES")
	local workspaces = parse_entities(cache:match("WORKSPACES(.-)\nTABS"), "workspaces", "workspace_id")
	local tabs = parse_entities(cache:match("TABS(.*)"), "tabs", "tab_id")

	M.agents = parse_agents(result, workspaces, tabs)
	M.room = tonumber(cache:match("ROOM%s+(%-?%d+)")) or M.room

	M.herdr:set({
		drawing = #M.agents == 0,
		icon = { string = opts.glyphs.idle, color = theme.colors.grey },
		label = { string = result == nil and "?" or "", color = theme.colors.grey },
	})

	refresh_slots()
end

function M.setup(components)
	sketchybar.add("event", opts.update_event)

	M.herdr = components.herdr
	M.slots = components.slots
	M.gap = components.gap

	-- The base item stops drawing once there are slots, and sketchybar delivers no events
	-- to an item that is not drawn; the gap is always drawn, so it carries the subscription.
	local function on_event(_)
		M.refresh()
	end

	M.herdr:subscribe({ "routine", "forced", opts.update_event }, on_event)
	M.gap:subscribe({ "routine", "forced", opts.update_event }, on_event)

	sketchybar.exec(opts.poll_command)

	M.refresh()
end

return M
