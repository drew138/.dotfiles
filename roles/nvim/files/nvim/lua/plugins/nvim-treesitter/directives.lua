local html_script_type_languages = {
	["importmap"] = "json",
	["module"] = "javascript",
	["application/ecmascript"] = "javascript",
	["text/ecmascript"] = "javascript",
}

local injection_language_aliases = {
	ex = "elixir",
	pl = "perl",
	sh = "bash",
	uxn = "uxntal",
	ts = "typescript",
}

local M = {}

local function first_node(match, capture_id)
	local nodes = match[capture_id]

	if type(nodes) == "table" then
		return nodes[1]
	end

	return nodes
end

local function language_from_info_string(alias)
	local matched = vim.filetype.match({ filename = "a." .. alias })

	return matched or injection_language_aliases[alias] or alias
end

function M.setup()
	local opts = { force = true }
	local query = vim.treesitter.query

	query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, pred, metadata)
		local node = first_node(match, pred[2])
		if not node then
			return
		end

		local alias = vim.treesitter.get_node_text(node, bufnr):lower()
		metadata["injection.language"] = language_from_info_string(alias)
	end, opts)

	query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, pred, metadata)
		local node = first_node(match, pred[2])
		if not node then
			return
		end

		local mimetype = vim.treesitter.get_node_text(node, bufnr)
		local configured = html_script_type_languages[mimetype]

		if configured then
			metadata["injection.language"] = configured
		else
			local parts = vim.split(mimetype, "/", {})
			metadata["injection.language"] = parts[#parts]
		end
	end, opts)

	query.add_directive("downcase!", function(match, _, bufnr, pred, metadata)
		local id = pred[2]
		local node = first_node(match, id)
		if not node then
			return
		end

		local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ""

		if not metadata[id] then
			metadata[id] = {}
		end

		metadata[id].text = string.lower(text)
	end, opts)
end

return M
