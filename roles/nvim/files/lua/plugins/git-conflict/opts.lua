-- local Opts = {
-- 	default_mappings = false,
-- 	default_commands = false,
-- 	disable_diagnostics = true,
-- 	list_opener = "copen",
-- 	highlights = {
-- 		incoming = "DiffAdd",
-- 		current = "DiffText",
-- 	},
-- }

-- return Opts
return {
	default_mappings = false, -- disable buffer local mapping created by this plugin
	default_commands = true, -- disable commands created by this plugin
	disable_diagnostics = true, -- This will disable the diagnostics in a buffer whilst it is conflicted
	list_opener = "copen", -- command or function to open the conflicts list
	highlights = { -- They must have background color, otherwise the default color will be used
		incoming = "DiffAdd",
		current = "DiffText",
	},
}
