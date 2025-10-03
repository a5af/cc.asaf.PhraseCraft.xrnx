--[[============================================================================
main.lua
============================================================================]]--

-- PhraseCraft - Renoise Tool
-- Craft phrase scripts using AI prompts

--------------------------------------------------------------------------------
-- Tool Properties
--------------------------------------------------------------------------------

_AUTO_RELOAD_DEBUG = function()
  -- Set to true during development to auto-reload when files change
end

--------------------------------------------------------------------------------
-- Requires
--------------------------------------------------------------------------------

-- Will be loaded after files are created
local config = nil
local ui = nil
local phrase_utils = nil

--------------------------------------------------------------------------------
-- Tool Registration
--------------------------------------------------------------------------------

-- Add menu entries
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:PhraseCraft...",
  invoke = function()
    show_phrasecraft_dialog()
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:PhraseCraft:Settings...",
  invoke = function()
    show_settings_dialog()
  end
}

-- Add keybinding
renoise.tool():add_keybinding {
  name = "Global:Tools:PhraseCraft",
  invoke = function()
    show_phrasecraft_dialog()
  end
}

--------------------------------------------------------------------------------
-- Main Functions
--------------------------------------------------------------------------------

function show_phrasecraft_dialog()
  -- Load UI module on demand
  if not ui then
    ui = require("ui.prompt_panel")
  end
  ui.show_dialog()
end

function show_settings_dialog()
  -- Load UI module on demand
  if not ui then
    ui = require("ui.prompt_panel")
  end
  ui.show_settings()
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

-- Load configuration
config = require("utils.config")

-- Initialize preferences
config.initialize_preferences()

-- Show notification on first load
print("PhraseCraft v0.2 loaded successfully")
