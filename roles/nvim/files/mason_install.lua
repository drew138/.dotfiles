local registry = require("mason-registry")
local required = require("plugins.mason-tool-installer-nvim.opts").ensure_installed

local function missing()
	local installed = {}

	for _, name in ipairs(registry.get_installed_package_names()) do
		installed[name] = true
	end

	local pending = {}

	for _, entry in ipairs(required) do
		local name = type(entry) == "table" and entry[1] or entry

		if not installed[name] then
			pending[#pending + 1] = name
		end
	end

	return pending
end

vim.cmd("Lazy! restore")
vim.cmd("MasonToolsUpdate")

local idle = 0
local previous = -1

while true do
	vim.wait(1000)

	local pending = #missing()

	if pending == 0 then
		break
	end

	if pending == previous then
		idle = idle + 1
	else
		idle = 0
		previous = pending
	end

	if idle >= 120 then
		break
	end
end

print("pending=" .. table.concat(missing(), ","))
vim.cmd("qa!")
