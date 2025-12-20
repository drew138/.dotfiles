local wezterm = require("wezterm")

-- Extend Lua module path to your dotfiles folder
package.path = package.path .. ";" .. os.getenv("HOME") .. "/.dotfiles/roles/wezterm/files/?.lua"

local config = {}

require("tabline")(config, wezterm)
require("style")(config)
require("keybinds")(config, wezterm)

return config
