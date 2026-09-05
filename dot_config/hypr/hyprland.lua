-- Hyprland Lua Configuration Entry Point
-- Requires all module files from this directory

hl.config({ ecosystem = { no_update_news = true } })

require("monitors")
require("general")
require("decorations")
require("animations")
require("layouts")
require("misc")
require("env")
require("input")
require("autostart")
require("rules")
require("keybinds")

-- Per-host overrides (optional): ~/.config/hypr-custom/custom.lua
-- pcall keeps hosts without the file loading cleanly.
pcall(dofile, os.getenv("HOME") .. "/.config/hypr-custom/custom.lua")
